translate([0, 0, 7]) rotate(a=[0,180,0]) difference() {
	union() {
		// Big cylinder for placement inside the machine.
		cylinder(h = 7, r = 17);

		// Outer cylinder; any sewing information would go here.
		translate([0, 0, 1]) cylinder(h = 3.5, r = 21.5);
	}

	// Subtract the inner hole. Be very generous.
	translate([0, 0, 4])
		cylinder(h = 10, r = 8.5, center=true);

	// Subtract the lower cone.
	cylinder(h = 2.01, r = 10);

	// Subtract the diagonal layer the disk rests on.
	translate([0, 0, 2])
		cylinder(h = 1.5, r1 = 10, r2 = 8.5);

	// Transport hole
	union() {
		translate([0, 12.25, -0.05])
			cylinder(h = 5.6, r=1.75);
		translate([0, 12.75, -0.05])
			cylinder(h = 5.6, r=1.75);
		translate([0, 12.5, -0.05])
			cube(size = [1.75, 0.5, 5.6]);
	}
}
