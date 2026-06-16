// RJ45 T568B wire feeding jig for 8P8C modular plugs
//
// Holds an RJ45 plug and guides eight stripped conductors into the correct
// slots in T568B order before crimping.
//
// Print flat on the bed (base down). Rear wire-loading end is at +Y.
// Plug contacts face −Y. Latch tab faces −Z.
//
// Usage:
//   1. Seat plug in front cradle (contacts visible at −Y).
//   2. Lay stripped wires in rear labeled grooves (pin 1 = left).
//   3. Push wires toward the plug, trim flush, remove, crimp.

/* [Wire] */
wire_diameter = 0.65;
wire_clearance = 0.30;

/* [Plug — 8P8C] */
plug_body_width = 11.68;
plug_body_height = 8.00;
plug_insert_depth = 14;
plug_clearance = 0.35;
pin_pitch = 1.02;

/* [Guide] */
guide_length = 38;
channel_pitch_top = 2.35;
channel_width_top = 2.10;
channel_depth = 2.2;
taper_length = 18;

/* [Structure] */
wall = 1.8;
base_thickness = 2.4;
cradle_wall = 1.6;
label_size = 2.0;
label_depth = 0.55;

/* [Hidden] */
$fn = 48;
num_wires = 8;
center_offset = (num_wires - 1) / 2;
top_span = (num_wires - 1) * channel_pitch_top;
channel_width_bottom = wire_diameter + wire_clearance;
comb_width = top_span + channel_width_top + 2 * wall;
cradle_width = plug_body_width + plug_clearance + 2 * cradle_wall;
cradle_height = plug_body_height + plug_clearance + 2 * cradle_wall;

t568b_short = ["WO", "O", "WG", "BL", "WBl", "G", "WBr", "Br"];
t568b_pins = ["1", "2", "3", "4", "5", "6", "7", "8"];

function pin_x(index, pitch) = (index - center_offset) * pitch;
function lerp(a, b, t) = a + (b - a) * t;

// Groove along Y; pin spacing at plug end (y=0), wider spacing at rear.
module wire_groove(index) {
  steps = 24;
  for (s = [0:steps - 1]) {
    t0 = s / steps;
    t1 = (s + 1) / steps;
    y0 = t0 * guide_length;
    y1 = t1 * guide_length;
    ym = (y0 + y1) / 2;
    t = ym / guide_length;
    taper_t = min(1, ym / taper_length);
    x = lerp(pin_x(index, pin_pitch), pin_x(index, channel_pitch_top), taper_t);
    w = lerp(channel_width_bottom, channel_width_top, t);
    dy = (y1 - y0) + 0.05;
    translate([x, ym, base_thickness + channel_depth / 2])
      cube([w, dy, channel_depth + 0.12], center = true);
  }
}

module embossed_label(str, size = label_size) {
  linear_extrude(height = label_depth + 0.02)
    text(str, size = size, font = "Liberation Sans:style=Bold",
         halign = "center", valign = "center");
}

module wire_labels() {
  y = guide_length - 2.2;
  z = base_thickness + channel_depth - label_depth;
  for (i = [0:num_wires - 1]) {
    x = pin_x(i, channel_pitch_top);
    translate([x, y, z]) embossed_label(t568b_short[i], label_size * 0.85);
    translate([x, y + 3.8, z]) embossed_label(t568b_pins[i], label_size * 0.72);
  }
  translate([0, y + 7.5, z]) embossed_label("T568B", label_size);
}

module plug_pocket() {
  w = plug_body_width + plug_clearance;
  h = plug_body_height + plug_clearance;
  translate([0, -plug_insert_depth / 2, base_thickness + h / 2])
    cube([w, plug_insert_depth + 0.4, h], center = true);
  translate([0, -plug_insert_depth + 4.5, base_thickness + 0.35])
    cube([5.2, 8, 2.6], center = true);
}

module body_solid() {
  comb_y = guide_length + wall;
  cradle_z = base_thickness + cradle_height;

  union() {
    translate([-comb_width / 2, 0, 0])
      cube([comb_width, comb_y, base_thickness + channel_depth + wall]);
    translate([-cradle_width / 2, -plug_insert_depth - cradle_wall, 0])
      cube([cradle_width, plug_insert_depth + cradle_wall, cradle_z]);
    translate([-cradle_width / 2, -cradle_wall, base_thickness])
      cube([cradle_width, cradle_wall, cradle_height - base_thickness]);
  }
}

difference() {
  body_solid();
  plug_pocket();
  translate([-cradle_width / 2, -cradle_wall - 0.6, base_thickness - 0.01])
    cube([cradle_width, cradle_wall + 0.8, cradle_height]);
  for (i = [0:num_wires - 1]) wire_groove(i);
  wire_labels();
}
