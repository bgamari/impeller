// impeller parameters
cup_diam = 30;
cup_wall_thickness = 3;
impeller_r = 30;
n_cups = 5;
rod_r = 3;
brace_r = 2;
standoff_h = 2*rod_r + 3;

// impeller mount parameters
mount_wall_thickness = 7;
mount_depth = 30;
mount_room = 4;
mount_top = 6; // thickness of mounting surface

// reed switch dimensions
reed_length = 17;
reed_depth = 3;
reed_height = 2.3;

// common parameters
axle_r = 3/2; // now using a screw instead of an axle
axle_h = 15;
layer_height = 0.35;

// laura's changes
rodaxel_h=36;
topplate_r=20;
topplate_h=3;
case_h=20;
case_r=41;
cap_r=56/2;

magnet_h=1;
magnet_r=1.5 + 0.5;


// derived quantities for mount
mount_length = impeller_r + cup_diam/2 + 2*axle_r + mount_top;
mount_h = 2*mount_wall_thickness + cup_diam + 2*mount_room;

module cup() {
    difference() {
        union() {
            difference(){
                // cup body
                translate([impeller_r, 0, 0])
                sphere(r=cup_diam/2);
    
                // bed for the magnet
                translate([impeller_r,-2, -impeller_r/2+1])
                    cylinder(r=magnet_r, h=magnet_h);
            }

            // brace
            translate([impeller_r, 0, 0])
            rotate([0,0,-135-18])
            rotate([0,90,0])
            cylinder(r=brace_r, h=2*impeller_r*sin(360/n_cups/2) - 5);

            // rod to center
            rotate([0,90,0])
            cylinder(r=rod_r, h=impeller_r); 

         

        }

        // axle
        cylinder(r=1.1 * axle_r, h=2*mount_h, center=true);

        // Cut out interior
        translate([impeller_r, 0, 0]) {
            sphere(r=(cup_diam-cup_wall_thickness)/2);
            translate([-cup_diam/2,0,-cup_diam/2])
            cube([cup_diam, cup_diam, cup_diam]);
        }

        // magnet
        color([1,0,0]) {
            translate([impeller_r,-2, -impeller_r/2 +1])
                cylinder(r=magnet_r, h=magnet_h);
        }
    }
}

module impeller() {
    for (i = [1:n_cups]) {
        rotate(i * 360 / n_cups) {
            cup();
        }
    }

    
    difference(){
    // stand-off
    cylinder(r=2*axle_r, h=standoff_h, center=true);

    // axle
    cylinder(r=1.1*axle_r, h=rodaxel_h, center=true);
    }

}

module bottom_case() {
    bottom_standoff_diff=0.2;
    bottom_standoff_h=(rodaxel_h- standoff_h)/2 - bottom_standoff_diff;
    bottom_case_plate_h=reed_height*2;

    // stand-off bottom  
    difference(){
        translate([0,0,-(standoff_h)/2-bottom_standoff_h/2 -bottom_standoff_diff])  
        cylinder(r2=2*axle_r, r1=6*axle_r, h=bottom_standoff_h, center=true);

        // axle
        cylinder(r=axle_r, h=rodaxel_h, center=true);
    }
    // fake axle, will be replace by screw
    //% cylinder(r=axle_r, h=rodaxel_h, center=true);

    
    // case
    difference() {
        translate([0,0,-(rodaxel_h/2+case_h/2)])	
        union() {
            translate([0,0,(case_h-bottom_case_plate_h)/2]) cylinder(r=case_r, h=bottom_case_plate_h, center=true);

            translate([0,0,-bottom_case_plate_h/2]) cylinder(r2=case_r, r1=cap_r, case_h-bottom_case_plate_h, center=true);

            
    	}

        
        // reed switch bed in case
        translate([impeller_r, 0, -rodaxel_h/2-reed_height/2])
            rotate([90,0,0]) rotate([0,90,0])
                cube([2*reed_height, reed_depth, reed_length+2], center=true);

        // second reed switch bed in case
        translate([impeller_r, 0, -rodaxel_h/2-reed_height/2])
            rotate([90,0,0]) //rotate([0,90,0])
                cube([2*reed_height, reed_depth, reed_length+2], center=true);

        // circular groove to bring out the reed switch cable
        translate([impeller_r, 0, -rodaxel_h/2-0.66])
        rotate_extrude()
        translate([reed_length/2,0])
        circle(1);
        
        // cabel connection of reed switch towards cap
        connect([0,0,-rodaxel_h/2-case_h], [impeller_r-reed_length/2,0,-rodaxel_h/2], 3)
        circle(r=2);

        // drill axel into the case
        cylinder(r=1.1*axle_r, h=rodaxel_h+20, center=true);


    }

    
}

module connect(r1, r2, extra=0) {
    dr = r2 - r1;
    d = sqrt(dr*dr);
    dxy = [dr[0], dr[1], 0];
    theta = atan2(dr[1], dr[0]);
    phi = acos(dr[2] / d);
    
    translate(r1)
    rotate([0, 0, 90+theta])
    rotate([phi, 0, 0])
    translate([0,0,-extra])
    linear_extrude(height=d + 2*extra)
    child();
}

module half_sphere(r) {
    difference() {
        sphere(r, center=true);
        translate([0, 0, -r])
        cube([3*r, 3*r, 2*r], center=true);
    }
}
    
module mount(simple=false) {
    a = mount_top + cup_diam/2 + mount_room;

    difference() {
        union() {
            translate([mount_length - a, 0, 0])
            scale([mount_length - a + 10, mount_depth/2, mount_h/2])
            rotate([0,-90,0])
            half_sphere(r=1, center=true);

            translate([mount_length, 0, 0])
            rotate([0,-90,0])
            scale([mount_h/2, mount_depth/2, 1])
            cylinder(r=1, h=a);
        }


         // axle
         cylinder(r=1.1 * axle_r, h=2*mount_h, center=true);

        // cut out for rod
        cube([2*impeller_r, 2*mount_depth, 2*rod_r + mount_room], center=true);

        // cut out for cup
        rotate_extrude()
            translate([impeller_r, 0])
            rotate([90,0])
            circle(r=cup_diam/2 + mount_room, h=2*mount_depth, center=true);


        // screw holes
        for (s = [-1,+1])
        translate([mount_h, 0, s*mount_depth/2])
        rotate([0, -90, 0]) {
            translate([0, 0, -10])
            cylinder(r=(3+0.2)/2, h=20);
    
            translate([0, 0, 3])
            cylinder(r=(5.6+0.2)/2, h=20);
        }

        // reed switch hole
        translate([mount_length - mount_top, 5, 0])
        cube([2*reed_height, reed_depth, reed_length+2], center=true);

        // reed switch wire hole
        translate([mount_length - mount_top, 5, 20/2 - 1.5])
        rotate([-90,0,0])
        cylinder(r=3/2, h=10);
    }
}
    
module assembly() {
    impeller($fn=36);
    bottom_case($fn=36);
    //mount($fn=40);
}

module tube(r_outer, r_inner, h) {
    difference() {
        cylinder(r=r_outer, h=h);

        translate([0, 0, -1])
        cylinder(r=r_inner, h=h+2);
    }
}
    
module print_plate1() {
    impeller($fn=40);

    translate([0, 0, -cup_diam/2], $fn=10) {
        // raft
        cylinder(r=impeller_r+15, h=layer_height);

        // support for axle 
        tube(axle_r-0.3, axle_r-0.3-0.3, cup_diam/2 - rod_r);

        // support for braces
        for (i = [0:n_cups])
        rotate(360/n_cups*(i+1/2))
        translate([14, 0, 0]) // magic number
        tube(brace_r, brace_r-0.3, cup_diam/2 - brace_r);

        // support for cup
        for (i = [0:n_cups])
        rotate(360/n_cups*i)
        translate([impeller_r, 0, 0])
        difference() {
            translate([0, -7, 0])
            tube(2, 2-0.3, 4);
            translate([0, 0, cup_diam/2])
            sphere(r=cup_diam/2);
        }
    }
}

module print_plate2() {
    rotate([0, 90, 0])
    mount($fn=40);
}

//print_plate1();
//print_plate2();

assembly();
//connect([0,0,0], [10,20,30])
//circle(r=10);

//rotate([0, 0, $t*-360]) impeller();
