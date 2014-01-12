// impeller parameters
cup_diam = 20;
cup_wall_thickness = 1.5;
impeller_r = 30;
n_cups = 4;
rod_r = 3;
brace_r = 2;
standoff_h = 2*rod_r + 2;

// impeller mount parameters
mount_wall_thickness = 3;

// common parameters
axle_r = 3/2;
axle_h = 14;

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
    mount_depth = 10;

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

assembly();