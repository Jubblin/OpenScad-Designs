# RJ45 T568B wire feeding jig

OpenSCAD model for loading eight Ethernet conductors into an 8P8C (RJ45) plug in **T568B** order before crimping.

## Files

| File | Purpose |
|------|---------|
| `rj45_t568b_feeder.scad` | Parametric model — customize in OpenSCAD Customizer |

## T568B wire order

Left to right when the plug **contacts face you** and the **latch tab is down** (normal crimp orientation):

| Pin | Pair color (T568B) |
|-----|-------------------|
| 1 | White / Orange |
| 2 | Orange |
| 3 | White / Green |
| 4 | Blue |
| 5 | White / Blue |
| 6 | Green |
| 7 | White / Brown |
| 8 | Brown |

The rear of the jig is labeled `WO O WG BL WBl G WBr Br` with pin numbers `1`–`8`.

## How to use

1. **Print** the jig flat on the bed (wire channels facing up). PETG or PLA, ~0.2 mm layers.
2. **Insert** an RJ45 plug into the front cradle until it seats (contacts visible at the front).
3. **Prepare cable** — strip jacket, untwist pairs, straighten conductors (~12 mm bare).
4. **Load wires** — place each conductor in the matching labeled channel at the rear.
5. **Feed forward** — push all eight wires through the tapered comb into the plug slots.
6. **Trim** conductors flush with the front of the plug.
7. **Remove** the plug from the jig and **crimp** as usual.

## Customizer parameters

- **wire_diameter** — default `0.65` mm for 24 AWG solid; increase slightly for stranded.
- **plug_clearance** — loosen or tighten plug fit.
- **guide_length** — longer rear section = easier wire placement.
- **channel_pitch_top** — wider rear spacing makes loading less fiddly.

## Preview / export

```bash
# Install OpenSCAD, then:
openscad -o rj45_t568b_feeder.stl rj45_t568b_feeder.scad
```

Or open `rj45_t568b_feeder.scad` in the OpenSCAD GUI, press **F6** to render, then **File → Export → STL**.

## Dimensions reference

Based on typical 8P8C modular plug specs (ANSI/TIA-1096-A):

- Contact pitch: 1.02 mm  
- Plug body: 11.68 × 8.00 mm (width × height)  
- Suitable for 24–26 AWG solid or stranded conductors  

Measure your plugs and tweak `plug_body_width`, `plug_body_height`, and `plug_clearance` if the fit is tight or loose.
