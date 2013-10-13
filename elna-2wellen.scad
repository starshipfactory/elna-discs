// Rotate the disc by 180 degrees to flip it upside down, which
// makes it easier to print the hole, etc. Lift it up by 7mm to bring
// it back above the axis // (the entire body is 7mm high).
translate([0, 0, 7]) rotate(a=[0,180,0]) difference() {
	union() {
		// Big cylinder for placement inside the machine.
		cylinder(h = 7, r = 17);

		// Outer cylinder; any sewing information would go here.
		translate([0, 2.5, 1]) cylinder(h = 3.5, r = 19);
		translate([0, -2.5, 1]) cylinder(h = 3.5, r = 19);
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

	// Mark the 18 stitches.
	// This is where the needle is at its deepest point.
	// Only for modelling, remove before print!
//	for (z=[0 : 17]) // 18 times
//	{
//		rotate(a=[0, 0, z*20]) { 
//   		translate([0, 17, 7])
//				cylinder(h= 1, r=1, center=true);
//		}
//	}
}
