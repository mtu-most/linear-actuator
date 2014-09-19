// Copyright 2013 Michigan Technological University
// Author: Jerry Anzalone
// This design was developed as part of a project with
// the Michigan Tech Open Sustainability Technology Research Group
// http://www.appropedia.org/Category:MOST
// It is released under CC-BY-SA
// includes may be found at http://github.com/mtu-most/most-scad-libraries

include<fasteners.scad>
include<steppers.scad>
include<bearings.scad>

$fn = 96;

render_part(1);

module render_part(part_to_render) {
	if (part_to_render == 1) end_motor();

	if (part_to_render == 2) end_idler();

	if (part_to_render == 3) carriage();

	if (part_to_render == 4) carriage_syringe_pump();

	if (part_to_render == 5) clamp_syringe_pump();

	if (part_to_render == 6) {
		for (i = [-1, 1])
			translate([i * (d_guide_rod + 2.5), 0, 0])
				syringe_hook();
	}

	if (part_to_render == 7) {syringe_plunger_retainer();}

	if (part_to_render == 8) syringe_bungie();
}

// [x, y, z] = [l, w, t]

/*

No moving motor!
Simple loading
Simple cleaning
Protect motor
Secure plunger

*/

d_nozzle = 0.75;

motor = NEMA17;
cc_guides = 50;

d_lead_screw = d_M5_screw;
d_lead_nut = d_M5_nut;
h_lead_nut = h_M5_nut;
od_antibacklash_spring = 7;
l_antibacklash_spring = 10;

offset_guides = 3.5; // offset from centerline of motor shaft towards top (+y)
d_guide_rod = 6.4; // 6mm guide rods
guide_bearing = bearing_lm6uu;
pad_guide_bearing_radius = 3;

pad_guide_ends = 3; // backing material behind ends of guide rods
pad_guide_radius = 3; // material surrouding guide rods and bearings
t_motor_mount = 12;
w_ends = motor[0];
l_ends = cc_guides + d_guide_rod + 2 * pad_guide_radius;
xy_aspect = l_ends / w_ends; // needed to scale rounded box
t_motor_end = 25;
idler = bearing_625;
t_idler_end = 20;

t_carriage = guide_bearing[2] + 6;

d_clamp_screw = d_M3_screw;
d_clamp_screw_cap = d_M3_cap;
d_clamp_screw_nut = d_M3_nut;

// following for attachments


// syringe pump:
d_plunger = 32; // diameter of the plunger end
d_syringe = 25; // diameter of the syringe body - sets size of syringe holder
t_hook = 5; // thickness of the hook for securing syringe to actuator
d_plunger_max = 32; // this sets the spacing for screws on the plunger retainer and carriage
d_plunger_retainer = d_plunger_max + 12;


module end_motor() {
	difference() {
		union() {
			rod_clamps(t_motor_end, pad_guide_ends);

			// motor plate
			difference () {
				translate([0, 0, (t_motor_mount - t_motor_end) / 2])
					cube([l_ends - (l_ends - cc_guides) - 1, w_ends, t_motor_mount], center = true);

				clamp_relief(t_motor_end, pad_guide_ends);
			}
		}

		// motor mount holes
		translate([0, 0, -t_motor_end / 2])
			rotate([0, 0, 45])
				NEMA_X_mount(
					height = t_motor_end,
					l_slot = 1,
					motor = motor);

		// keyhole opening for motor mount screws
		// for (i = [-1, 1])
		//	translate([i * motor[3] / 2, -motor[3] / 2, 0])
		//		cylinder(r = 2.5, h = 5, center = true);
	}
}

module end_idler() {
	difference() {
		union() {
			rod_clamps(t_idler_end, pad_guide_ends);

			// idler bearing housing

			difference () {
				translate([0, -((w_ends + idler[0]) / 2 - idler[0]) / 2, 0])
					cube([l_ends - (l_ends - cc_guides), (w_ends + idler[0]) / 2, t_idler_end], center = true);

				clamp_relief(t_motor_end, pad_guide_ends);
			}

		}

		// outboard idler bearing
		translate([0, 0, -t_idler_end / 2])
			cylinder(r = idler[0] / 2 + 0.01, h = idler[2] * 2, center = true);

		// inboard idler bearing
		translate([0, 0, t_idler_end / 2])
			cylinder(r = idler[0] / 2 + 0.01, h = idler[2] * 2, center = true);

		// lead screw
		translate([0, 0, idler[2] + 0.2])
			cylinder(r = d_lead_screw / 2, h = t_idler_end, center = true);

		end_mount_holes(t_idler_end + 1, d_M3_screw);
	}	
}

module carriage_body() {
	hull() {
		for (i = [-1, 1])
			translate([i * cc_guides / 2, offset_guides, 0])
				cylinder(r = guide_bearing[0] / 2 + pad_guide_bearing_radius, h = t_carriage, center = true);

		cylinder(r = od_antibacklash_spring / 2 + pad_guide_radius, h = t_carriage, center = true);
	}
}

module carriage_relief() {
	for (i = [-1, 1])
		translate([i * cc_guides / 2, offset_guides, 0]) {
			// guide rods
			cylinder(r = d_guide_rod / 2 + 0.5, h = t_carriage + 2, center = true);

			// guide bearings
			cylinder(r = guide_bearing[0] / 2, h = guide_bearing[2], center = true);

			translate([i * (guide_bearing[0] / 2 - 2), -(guide_bearing[0] / 2 - 2), , 0])
				cylinder(r = guide_bearing[0] / 2, h = guide_bearing[2], center = true);
	}

	// nut trap for fixed nut
	hull()
		for (i = [0, -1])
			translate([0, i * t_carriage, -t_carriage / 2 + 2])
				rotate([0, 0, 30])
					cylinder(r = d_lead_nut / 2, h = h_lead_nut, $fn = 6);

	// lead nuts and anti-backlash spring
	hull()
		for (i = [0, 1])
			translate([0, i * -20, -t_carriage / 2 + h_lead_nut + 4])
				rotate([0, 0, 30])
					cylinder(r = d_lead_nut / 2, h = l_antibacklash_spring + h_lead_nut / 2, $fn = 6);

	translate([0, 0, -t_carriage / 2 + h_lead_nut + 4])
		rotate([0, 0, 30])
			cylinder(r = d_lead_nut / 2, h = l_antibacklash_spring + h_lead_nut, $fn = 6);

	// lead screw
	cylinder(r = d_lead_screw /2 + 0.5, h = t_carriage + 2, center = true);
}

module carriage_support() {
	// floors for holes
	for (i =[-1, 1])
		translate([i * cc_guides / 2, offset_guides, guide_bearing[2] / 2])
			cylinder(r = guide_bearing[0] / 2 - 1, h = 0.2);

	translate([0, 0, -t_carriage / 2 + h_lead_nut + 4 + l_antibacklash_spring + h_lead_nut])
		cylinder(r = d_lead_nut / 2, h = 0.2);

	translate([0, 0, -t_carriage / 2 + h_lead_nut + 4 + l_antibacklash_spring + h_lead_nut / 2])
		cylinder(r = d_lead_nut / 2 + 1, h = 0.2);

	translate([0, 0, -t_carriage / 2 + 2 + h_lead_nut])
		cylinder(r = d_lead_nut / 2 + 1, h = 0.2);

	// filler for gaps
	for (i =[-1, 1])
		translate([i * cc_guides / 2, offset_guides, 0])

			difference() {
				cylinder(r = guide_bearing[0] / 2 + pad_guide_bearing_radius, h = t_carriage, center = true);

				cylinder(r = guide_bearing[0] / 2 + pad_guide_bearing_radius - d_nozzle, h = t_carriage + 2, center = true); 
			}
}

module carriage() {
	union() {
		difference() {
			carriage_body();

			carriage_relief();
		}

		carriage_support();
	}
}

module rounded_box(
	l1,
	l2,
	r_corner,
	height) {

	hull()
		for (i = [-1, 1])
			for (j = [-1, 1])
				translate([i * (l1 / 2 - r_corner), j * (l2 / 2 - r_corner), 0])
					cylinder(r = r_corner, h = height, center = true);
}

module clamp_body(thickness) {
	union() {
		for (i = [-1, 1])
			translate([i * cc_guides / 2, 0, 0])
				rounded_box(
					l1 = (l_ends - cc_guides),
					l2 = w_ends,
					r_corner = 3,
					height = thickness);

		// bottom
		//translate([0, (4 - w_ends) / 2, 0]) cube([cc_guides, 4, thickness], center = true);
	}
}

module clamp_relief(
	thickness,
	pad_ends) {
			// guide rods have backing, so are off the end of the body
			for (i = [-1, 1])
				translate([i * cc_guides / 2, offset_guides, pad_ends])
					cylinder(r = d_guide_rod / 2, h = thickness, center = true);

			// slots for clamping guide rods
			for (i = [-1, 1])
				translate([i * cc_guides / 2, offset_guides, 0])
					hull()
						for (j = [-0.25, 1])
							translate([0, j * w_ends, 0])
								cylinder(r = 0.5, h = thickness + 2, center = true);

			// holes for clamp screws
			translate([0, w_ends / 4 + offset_guides, 0]) {
				for (i = [-1, 1])
					for (j = [1]) {
						translate([i * cc_guides / 2, 0, j * (thickness - pad_ends) / 4])
							rotate([0, 90, 0])
								cylinder(r = d_clamp_screw / 2, h = (l_ends - cc_guides) * 2, center = true);

						translate([i * l_ends / 2, 0, j * (thickness - pad_ends) / 4])
							rotate([0, 90, 0])
								cylinder(r = d_clamp_screw_cap / 2, h = 8, center = true);

						translate([0, 0, j * (thickness - pad_ends) / 4])
							rotate([0, 90, 0])
								cylinder(r = d_clamp_screw_nut / 2, h = cc_guides - (l_ends - cc_guides) / 2, $fn = 6, center = true);
					}
			}

}

module rod_clamps(
	thickness,
	pad_ends) {
	difference() {
		clamp_body(thickness);

		clamp_relief(thickness, pad_ends);
	}
}

module end_mount_holes(
	thickness,
	diameter,
	fn = $fn) {
	// screw holes for retaining items against clamp
	for (i = [-1, 1])
		for (j = [-1, 0])
			translate([i * (cc_guides - idler[0] - d_lead_nut) / 2, offset_guides + j * w_ends / 2, 0])
				cylinder(r = diameter / 2, h = thickness, $fn = fn, center = true);
}

/****************************

 following are attachments for the base linear actuator

****************************/

// renders a carriage with a pusher attachement and place to fix a locking cam
module carriage_syringe_pump() {
	t_holder = 6; // thickness of the cylindrical portion of the pusher

	union() {
		difference() {
			union() {
				carriage_body();

				// pusher for the plunger
				translate([0, (idler[0] + d_syringe) / 2, (t_holder - t_carriage) / 2])
					rounded_box(
						l1 = cc_guides - d_guide_rod,
						l2 = d_syringe,
						r_corner = 3,
						height = t_holder);

				translate([0, guide_bearing[0] / 2 + pad_guide_bearing_radius + offset_guides, t_holder / 2])
					cylinder(r1 = d_syringe / 2, r2 = 0, h = t_carriage - t_holder, center = true);

			}

			// lead screw, bearings, etc.
			carriage_relief();

			// screw hole for plunger lock
			for (i = [-1, 1])
					translate([i * ((d_plunger_retainer - (d_plunger_retainer - d_plunger_max) + d_M3_screw) / 2), (idler[0] + d_syringe) / 2, (t_holder - t_carriage) / 2]) {
						cylinder(r = d_M3_screw / 2, h = t_holder + 1, center = true);

						translate([0, 0, t_holder - 2 * h_M3_nut])
							rotate([0, 0, 30])
								cylinder(r = d_M3_nut / 2, h = 2 * h_M3_nut, $fn = 6);
					}
		}

		// support structure to facilitate printing
		carriage_support();
	}
}

// renders a clamping fixture for holding the syringe body in place
module clamp_syringe_pump() {
	t_syringe_clamp = 8;

	difference() {
				union() {
					clamp_body(t_syringe_clamp);

					// idler bearing housing
					translate([0, -((w_ends + idler[0]) / 2 - idler[0]) / 2, 0])
						cube([l_ends - 2 * (l_ends - cc_guides), (w_ends + idler[0]) / 2, t_syringe_clamp], center = true);

					translate([0, (idler[0] + d_syringe) / 2, 0])
						hull()
							for (i = [0, -1])
								translate([0, i * d_syringe / 2, 0])
									cylinder(r = d_syringe / 2 + 4, h = t_syringe_clamp, center = true);

				translate([0, -((w_ends + idler[0]) / 2 - idler[0]) / 2 - (w_ends + idler[0]) / 4 + (d_M3_nut + 2) / 2, 1])
					cube([l_ends - 2 * (l_ends - cc_guides), d_M3_nut + 2, t_syringe_clamp + 2], center = true);
		}

		// lead screw
		hull()
			for (i = [0, -1])
				translate([0, i * w_ends, 0])
					cylinder(r = d_lead_nut / 2 + 1, h = t_syringe_clamp + 6, center = true);

		// screw holes for retaining syringe against clamp
		end_mount_holes(t_syringe_clamp + 1, d_M3_screw);

		translate([0, 0, t_syringe_clamp / 2])
			end_mount_holes(h_M3_nut * 2, d_M3_nut, 6);

		// guide rods
		for (i = [-1, 1])
				translate([i * cc_guides / 2, offset_guides, 0])
					cylinder(r = d_guide_rod / 2, h = t_syringe_clamp + 1, center = true);

		// syringe
		translate([0, (idler[0] + d_syringe) / 2, 0])
			cylinder(r = d_syringe / 2, h = t_syringe_clamp + 1, center = true);

		for (i = [-1, 1])
			translate([i * (cc_guides / 2 + 1.5), -w_ends / 2 + offset_guides - d_guide_rod / 2 + 2, 0])
				rounded_box(
					l1 = (l_ends - cc_guides + 3),
					l2 = w_ends,
					r_corner = 3,
					height = t_syringe_clamp + 1);
	}
}

module syringe_hook() {
	offset_hook = 15;

	difference() {
		hull()
			for (i = [0, 1])
				translate([0, i * offset_hook, 0])
					cylinder(r = (l_ends - cc_guides) / 2 - d_nozzle, h = t_hook, center = true);

		cylinder(r = d_guide_rod / 2, h = 6, center = true);

		translate([0, offset_hook, 0])
			rotate([0, 0, -30])
				hull()
					for (i = [0, 1])
						translate([i * 10, 0, 0])
							cylinder(r = d_M3_screw / 2, h = t_hook + 1, center = true);
	}
}

module syringe_plunger_retainer() {
	t_retainer = 8;

	// yoke
	difference() {
		hull()
			for (i = [0, 1])
				translate([0, i * (d_plunger / 2 + 5), 0])
					cylinder(r = d_plunger_retainer / 2, h = t_retainer, center = true);

		// notch for plunger
		hull()
			for (i = [0, 1])
				translate([0, i * (d_plunger / 2 + 5), 0])
					cylinder(r1 = d_plunger / 4, r2 = d_plunger / 2 + 0.1, h = t_retainer, center = true);

		translate([-(d_plunger_retainer + 2) / 2, d_syringe / 2, -t_retainer / 2 - 1])
			cube([d_plunger_retainer + 2, d_plunger_retainer + 2, t_retainer + 2]);

		// mounting holes
		for (i = [-1,1])
				translate([i * ((d_plunger_retainer - (d_plunger_retainer - d_plunger_max) + d_M3_screw) / 2), 0, 0]) {
					translate([0, 0, h_M3_cap + 0.25])
						cylinder(r = d_M3_screw / 2, h = t_retainer, center = true);

					translate([0, 0, -t_retainer / 2])
						cylinder(r = d_M3_cap / 2, h = 2 * h_M3_cap, center = true);
				}

		// lead screw
		translate([0, -(idler[0] + d_syringe) / 2, 0])
		cylinder(r = d_lead_nut / 2 + 1, h = t_retainer + 1, center = true);
	}

	// wedge
	translate([d_plunger_retainer, 0, -1.5])
		difference() {
			hull()
				for (i = [0, 1])
					translate([0, i * (d_plunger / 2 + 5), 0])
						cylinder(r2 = d_plunger / 4, r1 = d_plunger / 2 + 0.1, h = t_retainer, center = true);

//			translate([-(d_plunger_retainer + 2) / 2, d_syringe / 2, -t_retainer / 2 - 1])
//				cube([d_plunger_retainer + 2, d_plunger_retainer + 2, t_retainer + 2]);

			hull()
				for (i = [0, -1])
					translate([0, i * d_plunger, 0])
						cylinder(r = d_plunger / 4, h = t_retainer, center = true);

			translate([0, 0, -t_retainer / 2])
				cube([d_plunger_retainer * 2, d_plunger_retainer * 2, 3], center = true);

			translate([0, d_plunger / 2 + 5, 12])
				sphere(10);
		}
}

module syringe_bungie() {
	difference() {
		union() {
			for (i = [-1, 1])
				translate([i * (cc_guides / 2 - 5), 0, 0])
					cylinder(r = t_hook * 1.5, h = t_hook, center = true);

			cube([cc_guides - 10, t_hook * 2, t_hook], center = true);
		}

		for (i = [-1, 1])
			translate([i * (cc_guides / 2 - 5), 0, 0])
				cylinder(r = t_hook / 2 + 0.5, h = t_hook + 1, center = true);

	}
}
