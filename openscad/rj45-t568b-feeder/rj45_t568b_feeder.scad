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
wire_diameter = 0.5;
wire_clearance = 0.30;

/* [Plug — 8P8C] */
plug_body_width = 11.68;
plug_body_height = 8.00;
plug_insert_depth = 14;
plug_clearance = 1;
pin_pitch = 1.02;

/* [Guide] */
guide_length = 38;
channel_pitch_top = 2.35;
channel_width_top = 2.10;
channel_depth = 2.2;
taper_length = 1;
plug_comb_length = 10;
outlet_comb_length = 4;

/* [Structure] */
wall = 1.8;
base_thickness = 2.4;
cradle_wall = 1.6;
comb_inner_margin = 2.0;
comb_rib_min = 0.8;
label_size = 2.0;
label_depth = 0.55;

/* [Hidden] */
$fn = 48;
num_wires = 8;
center_offset = (num_wires - 1) / 2;
top_span = (num_wires - 1) * channel_pitch_top;
channel_width_bottom = wire_diameter + wire_clearance;
comb_width = top_span + channel_width_top + 2 * comb_inner_margin + 2 * wall;
cradle_width = plug_body_width + plug_clearance + 2 * cradle_wall;
cradle_height = plug_body_height + plug_clearance + 2 * cradle_wall;
plug_face_y = -(plug_insert_depth + cradle_wall);
comb_channel_h = channel_depth + wall;
comb_roof_z = base_thickness + channel_depth;
comb_enclosure_h = base_thickness + comb_channel_h + wall;
// Slots pierce channel bay only — solid floor slab stays below base_thickness.
comb_slot_z0 = base_thickness - 0.01;
comb_slot_z1 = comb_roof_z + wall + 0.01;
comb_slot_h = comb_slot_z1 - comb_slot_z0;
comb_slot_zc = (comb_slot_z0 + comb_slot_z1) / 2;
channel_bay_w = top_span + channel_width_top;

function groove_cut_w(w, pitch) = max(channel_width_bottom, min(w, pitch - comb_rib_min));

module comb_slot_cut(x, y, w, dy) {
  translate([x, y, comb_slot_zc])
    cube([w, dy, comb_slot_h], center = true);
}

t568b_short = ["WO", "O", "WG", "BL", "WBl", "G", "WBr", "Br"];
t568b_pins = ["1", "2", "3", "4", "5", "6", "7", "8"];

function pin_x(index, pitch) = (index - center_offset) * pitch;
function lerp(a, b, t) = a + (b - a) * t;

// Groove along Y; pin spacing at plug end (y=0), wider spacing at rear (+Y).
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
    pitch_at = lerp(pin_pitch, channel_pitch_top, taper_t);
    x = lerp(pin_x(index, pin_pitch), pin_x(index, channel_pitch_top), taper_t);
    w = groove_cut_w(lerp(channel_width_bottom, channel_width_top, t), pitch_at);
    dy = (y1 - y0) + 0.05;
    comb_slot_cut(x, ym, w, dy);
  }
}

// Cradle-side comb: pin pitch from y=0 into the plug region.
module plug_comb_groove(index) {
  steps = max(8, ceil(plug_comb_length / 1.5));
  for (s = [0:steps - 1]) {
    t0 = s / steps;
    t1 = (s + 1) / steps;
    y0 = -plug_comb_length + t0 * plug_comb_length;
    y1 = -plug_comb_length + t1 * plug_comb_length;
    ym = (y0 + y1) / 2;
    dy = (y1 - y0) + 0.05;
    comb_slot_cut(pin_x(index, pin_pitch), ym,
      groove_cut_w(channel_width_bottom, pin_pitch), dy);
  }
}

// Front trim comb: short guides past plug contacts (−Y) for pull-through / flush trim.
module outlet_comb_groove(index) {
  steps = max(6, ceil(outlet_comb_length / 1.0));
  y_start = plug_face_y - outlet_comb_length;
  for (s = [0:steps - 1]) {
    t0 = s / steps;
    t1 = (s + 1) / steps;
    y0 = y_start + t0 * outlet_comb_length;
    y1 = y_start + t1 * outlet_comb_length;
    ym = (y0 + y1) / 2;
    dy = (y1 - y0) + 0.05;
    comb_slot_cut(pin_x(index, pin_pitch), ym,
      groove_cut_w(channel_width_bottom, pin_pitch), dy);
  }
}

module embossed_label(str, size = label_size) {
  linear_extrude(height = label_depth + 0.02)
    text(str, size = size, font = "Liberation Sans:style=Bold",
         halign = "center", valign = "center");
}

module wire_labels() {
  y_color = guide_length - 10;
  y_pin = guide_length - 5.5;
  z = comb_roof_z + wall - label_depth;
  for (i = [0:num_wires - 1]) {
    x = pin_x(i, channel_pitch_top);
    translate([x, y_color, z]) embossed_label(t568b_short[i], label_size * 0.85);
    translate([x, y_pin, z]) embossed_label(t568b_pins[i], label_size * 0.72);
  }
  translate([0, guide_length - 2, z]) embossed_label("T568B", label_size * 0.75);
}

module plug_pocket() {
  w = plug_body_width + plug_clearance;
  h = plug_body_height + plug_clearance;
  // Pocket must cut through the front cradle wall (−Y) so the plug can enter.
  pocket_depth = plug_insert_depth + cradle_wall + 0.4;
  translate([0, -pocket_depth / 2 + 0.2, base_thickness + h / 2])
    cube([w, pocket_depth, h], center = true);
  // Latch tab faces −Z (toward the bed); relief in the cradle floor.
  translate([0, -plug_insert_depth + 4.5, base_thickness / 2])
    cube([5.2, 8, base_thickness + 0.4], center = true);
}

// Solid comb block; optional open ends cut a window in the channel bay.
module enclosed_comb(y0, length, open_front = false, open_rear = false) {
  bay_w = channel_bay_w + 2 * comb_inner_margin;
  difference() {
    translate([-comb_width / 2, y0, 0])
      cube([comb_width, length, comb_enclosure_h]);
    if (open_front)
      translate([-bay_w / 2, y0 - 0.01, base_thickness])
        cube([bay_w, wall + 0.02, comb_channel_h + wall]);
    if (open_rear)
      translate([-bay_w / 2, y0 + length - wall - 0.01, base_thickness])
        cube([bay_w, wall + 0.02, comb_channel_h + wall]);
  }
}

module body_solid() {
  cradle_z = base_thickness + cradle_height;

  union() {
    // Rear comb (+Y): boxed channels, open back for wire loading.
    enclosed_comb(0, guide_length, open_front = true, open_rear = true);
    // Cradle approach comb: boxed tunnel open at both ends for pull-through.
    enclosed_comb(-plug_comb_length, plug_comb_length, open_front = true, open_rear = true);
    // Front outlet comb (−Y): boxed channels, open front for trim access.
    enclosed_comb(plug_face_y - outlet_comb_length, outlet_comb_length, open_front = true);
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
  for (i = [0:num_wires - 1]) plug_comb_groove(i);
  for (i = [0:num_wires - 1]) outlet_comb_groove(i);
  wire_labels();
}
