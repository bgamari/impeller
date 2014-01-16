// impeller parameters
cup_diam = 25;
cup_wall_thickness = 2;
impeller_r = 30;
n_cups = 4;
rod_r = 3;
brace_r = 2;
standoff_h = 2*rod_r + 2;

// impeller mount parameters
mount_wall_thickness = 5;
mount_depth = 20;

// common parameters
axle_r = 3/2;
axle_h = 14;
layer_height = 0.35;

module cup() {
    difference() {
        union() {
            // cup body
            translate([impeller_r, 0, 0])
            sphere(r=cup_diam/2);

            // brace
            translate([impeller_r, 0, 0])
            rotate([0,0,-45-90-15])
            rotate([0,90,0])
            cylinder(r=brace_r, h=2*impeller_r*sin(360/n_cups/2));

            // rod to center
            rotate([0,90,0])
            cylinder(r=rod_r, h=impeller_r);
        }

        // Cut out interior
        translate([impeller_r, 0, 0]) {
            sphere(r=(cup_diam-cup_wall_thickness)/2);
            translate([-cup_diam,0,-cup_diam])
            cube([2*cup_diam, 2*cup_diam, 2*cup_diam]);
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

    cylinder(r=2*axle_r, h=standoff_h, center=true);
}

module mount() {
    mount_length = impeller_r + cup_diam/2 + 2*axle_r;
    mount_h = 2*mount_wall_thickness + cup_diam;

    difference() {
        union() {
            cylinder(r=mount_depth/2, h=mount_h, center=true);
            translate([mount_length/2, 0, 0])
            cube([mount_length, mount_depth, mount_h], center=true);
        }

        // cut out for rod
        cube([2*impeller_r, 2*mount_depth, 3*rod_r], center=true);

        // cut out for cup
        translate([impeller_r, 0, 0])
        rotate([90,0,0])
        cylinder(r=cup_diam/2 + 1, h=2*mount_depth, center=true);

        // axle
        cylinder(r=1.1 * axle_r, h=2*mount_h, center=true);
    }
}
    
module assembly() {
    impeller($fn=36);
    %mount($fn=40);
}

module tube(r_outer, r_inner, h) {
    difference() {
        cylinder(r=r_outer, h=h);
        translate([0, 0, -1])
        cylinder(r=r_inner, h=h+2);
    }
}
    
module print_plate1() {
    impeller($fn=20);

    translate([0, 0, -cup_diam/2]) {
        // raft
        cylinder(r=impeller_r+10, h=layer_height);

        // support for rods 
        tube(axle_r, axle_r-0.2, cup_diam/2 - rod_r);

        // support for braces
        for (i = [0:n_cups])
        rotate(360/n_cups*(i+1/2))
        translate([15, 0, 0])
        tube(brace_r, brace_r-0.2, cup_diam/2 - brace_r);
    }
}

print_plate1();
//assembly();
