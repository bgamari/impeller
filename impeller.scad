module impeller() {
    n_fins = 5;
    cylinder(r=7, h=9);

    for (i = [0:n_fins])
    rotate([0, 0, 360/n_fins * i]) {
        translate([6, -1, 4.8])
        rotate([180-3, 0, 0])
        scale(10)
        import("blade.stl");
    }
}

scale(2)
difference() {
    impeller();
    translate([0, 0, -1])
    cylinder(r=3/2, h=20, $fn=16);
}
