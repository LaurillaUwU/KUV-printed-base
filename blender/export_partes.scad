// Exporta cada pieza de cubo_v1.scad en su posición de montaje (para Blender).
use <../cubo_v1.scad>
part = "bottom_plate";
sv = ["A", "A", "A", "B"];
if (part == "bottom_plate") bottom_plate();
if (part == "top_ring") top_ring();
for (k = [0 : 3]) if (part == str("column_", k)) rotate(90 * k) corner_column();
for (i = [0 : 3]) {
    if (part == str("holder_side_", i)) place_side(i) holder(sv[i], false);
    if (part == str("panel_side_", i)) place_side(i) panel_ref(sv[i]);
    if (part == str("screws_ok_", i)) place_side(i) screw_marks(sv[i], false);
}
if (part == "screws_ok_top") place_top() screw_marks("B", true);
if (part == "holder_top") place_top() holder("B", true);
if (part == "panel_top") place_top() panel_ref("B");
if (part == "pi") pi_env();
