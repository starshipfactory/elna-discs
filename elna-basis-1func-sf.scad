module letter(l,font="font.dxf",h=100,i=0) {
	union() {
		linear_extrude( height=h) import(font, layer=l[i]);
		translate([dxf_dim(file=font, name="advx",layer=l[i]),
			dxf_dim(file=font, name="advy",layer=l[i]),
			0])
			child();
	}
}

module word(wrd,font="font.dxf",h=100,i=0) {
	if(i < len(wrd)) {
		letter(wrd,font,h,i) word(wrd,font,h,i+1);
	} else {
		child();
	}
}

difference() {
	union() {
		// Big cylinder for placement inside the machine.
		cylinder(h = 7, r = 17);

		// The initials of the Starship Factory to be
		// displayed on top.
		translate([-2.5, 10, 7]) scale(0.003) letter("s");
		translate([-1.5, -15, 7]) scale(0.002) letter("f");

		// Outer cylinder; any sewing information would go here.
		translate([0, 0, 1]) cylinder(h = 3.5, r = 22);
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
