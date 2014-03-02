// impeller parameters
cup_diam = 30;
cup_wall_thickness = 3.2;
impeller_r = 30;
n_cups = 4;
rod_r = 3;
brace_r = 2;
standoff_h = 2*rod_r + 3;

// impeller mount parameters
mount_wall_thickness = 7;
mount_depth = 30;
mount_room = 3; // room between cup and mount
mount_top = 6; // thickness of mounting surface

// reed switch dimensions
reed_length = 17;
reed_depth = 3;
reed_height = 2.3;

// common parameters
axle_r = 4/2;
axle_h = 15;
layer_height = 0.35;

// printer parameters
xy_res = 0.2;

// derived quantities for mount
mount_length = impeller_r + cup_diam/2 + 2*axle_r + mount_top;
mount_h = 2*mount_wall_thickness + cup_diam + 2*mount_room;

module cup() {
    difference() {
        union() {
            // cup body
            translate([impeller_r, 0, 0])
            sphere(r=cup_diam/2);

            // brace
            translate([impeller_r, 0, 0])
            rotate([0,0,-135-18])
            rotate([0,90,0])
            cylinder(r=brace_r, h=2*impeller_r*sin(360/n_cups/2) - 5);

            // rod to center
            rotate([0,90,0])
            cylinder(r=rod_r, h=impeller_r);
        }

        // Cut out interior
        translate([impeller_r, 0, 0]) {
            sphere(r=(cup_diam-cup_wall_thickness)/2);
            translate([-cup_diam/2,0,-cup_diam/2])
            cube([cup_diam, cup_diam, cup_diam]);
        }
    }
}

module impeller() {
    for (i = [1:n_cups]) {
        rotate(i * 360 / n_cups) {
            cup();
        }
    }

    // axle
    cylinder(r=axle_r, h=axle_h, center=true);

    // stand-off
    cylinder(r=2*axle_r, h=standoff_h, center=true);
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
            if (!simple) {
                translate([mount_length - a, 0, 0])
                scale([mount_length - a + 10, mount_depth/2, mount_h/2])
                rotate([0,-90,0])
                half_sphere(r=1, center=true);

                translate([mount_length, 0, 0])
                rotate([0,-90,0])
                scale([mount_h/2, mount_depth/2, 1])
                cylinder(r=1, h=a);
            } else {
                cylinder(r=mount_depth/2, h=mount_h, center=true);
                translate([mount_length/2, 0, 0])
                cube([mount_length, mount_depth, mount_h], center=true);
            }
        }

        // cut out for rod
        cube([2*impeller_r, 2*mount_depth, 2*rod_r + mount_room], center=true);

        // cut out for cup
        rotate_extrude()
        translate([impeller_r, 0])
        rotate([90,0])
        circle(r=cup_diam/2 + mount_room, h=2*mount_depth, center=true);

        // axle
        cylinder(r=1.1 * axle_r, h=2*mount_h, center=true);

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
    mount($fn=40);
}

module tube(r_outer, thickness, h) {
    difference() {
        cylinder(r=r_outer, h=h);
        translate([0, 0, -1])
        cylinder(r=r_outer - thickness, h=h+2);
    }
}
    
module print_plate1() {
    impeller($fn=40);

    translate([0, 0, -cup_diam/2], $fn=10) {
        // raft
        cylinder(r=impeller_r+15, h=layer_height);

        // support for axle 
        tube(axle_r-0.5, xy_res, cup_diam/2 - rod_r - 0.5);

        // support for braces
        for (i = [0:n_cups])
        rotate(360/n_cups*(i+1/2))
        translate([14, 0, 0]) // magic number
        tube(brace_r, xy_res, cup_diam/2 - brace_r);

        // support for cup
        for (i = [0:n_cups])
        rotate(360/n_cups*i)
        translate([impeller_r, 0, 0])
        #difference() {
            for (theta = [-90:30:90])
            rotate(theta)
            translate([0, -cup_diam/2, 0])
            cube([xy_res, cup_diam/2, cup_diam/2]);

            translate([0, 0, cup_diam/2])
            sphere(r=cup_diam/2 + 0.1, $fn=30);
        }
    }
}

module print_plate2() {
    rotate([0, 90, 0])
    mount($fn=40);
}

print_plate1();
//print_plate2();

//projection(cut=true) rotate([90,0,0]) mount($fn=40);

//assembly();
