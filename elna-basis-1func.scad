difference() {
	union() {
		// Big cylinder for placement inside the machine.
		cylinder(h = 7, r = 34);

		// Outer cylinder; any sewing information would go here.
		translate([0, 0, 1]) cylinder(h = 3.5, r = 44);
	}

	// Subtract the inner hole. Be very generous.
	translate([0, 0, 4])
		cylinder(h = 10, r = 17, center=true);

	// Subtract the lower cone.
	cylinder(h = 2, r = 20);

	// Subtract the diagonal layer the disk rests on.
	translate([0, 0, 2.005])
		cylinder(h = 1.51, r1 = 20, r2 = 17);

	// Transport hole
	union() {
		translate([0, 24.5,-0.1])
			cylinder(h = 5.6, r=3);
		translate([0, 25.5,-0.1])
			cylinder(h = 5.6, r=3);
		translate([0, 25, -0.1])
			cube(size = [3, 1, 5.6]);
	}
}
