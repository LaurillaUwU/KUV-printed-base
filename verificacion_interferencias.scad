// Verificación automática de interferencias entre piezas vecinas.
// Uso (línea de comandos):
//   openscad --render -o /tmp/x.stl -D 'test=1' verificacion_interferencias.scad
// Si el resultado es un objeto vacío ("Current top level object is empty") NO hay interferencia.
// Comprueba solo geometría nominal; no sustituye la prueba física de montaje.
use <cubo_led.scad>
test = 1;
// 1: portapanel cara 0 ∩ portapanel+marco cara 1 (esquina)
// 2: portapanel cara 0 ∩ marco cara 0 (deben tocarse, no solaparse)
// 3: ganchos cara 0 ∩ marco superior
// 4: portapanel superior ∩ portapaneles laterales
// 5: marcos laterales ∩ postes de esquina
// 6: eje/brida ∩ tapa inferior giratoria
module side_parts(i, with_frame = true) {
    place_side(i) { panel_carrier(i == 3 ? "B" : "A", false); }
    if (with_frame) place_side_frame(i) side_face_frame();
}
if (test == 1) intersection() { side_parts(0); side_parts(1); }
if (test == 2) intersection() { place_side(0) panel_carrier("A", false); place_side_frame(0) side_face_frame(); }
if (test == 3) intersection() { place_side(0) for (x = hook_x_side_v()) translate([x, hook_y_v(), zb_v()]) panel_retention_hook(); top_frame_placed(); }
if (test == 4) intersection() { place_top() panel_carrier("B", true); union() for (i = [0 : 3]) side_parts(i); }
if (test == 5) intersection() { union() for (i = [0 : 3]) place_side_frame(i) side_face_frame(); corner_posts(); }
if (test == 6) intersection() { bottom_cover_placed(); union() { shaft(); bearing_housing(); } }
