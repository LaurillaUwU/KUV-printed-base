// =============================================================================
//  CUBO LED GIRATORIO — v1 (solo el cubo; la base se diseñará después)
//  5 matrices HUB75 64x64 P3 (4 laterales + 1 superior). Sin bibliotecas externas.
//  Probado con OpenSCAD 2021.01.
//
//  PIEZAS IMPRESAS (11):
//    1x placa inferior   — cierra el fondo; labio = moldura de las 4 aristas inferiores;
//                          rieles inferiores; soportes de la Raspberry Pi 4
//    4x columna de esquina — poste estructural + moldura vertical (todas iguales)
//    1x anillo superior  — marco con cruz de refuerzo + molduras de las 4 aristas superiores
//                          + rieles superiores para las caras laterales
//    5x portamatriz      — sustituye la base plástica original (3 variante A, 2 variante B)
//
//  RETENCIÓN DE CADA MATRIZ LATERAL (de dentro hacia fuera):
//    a) la matriz se atornilla al portamatriz con sus tornillos originales (desde atrás)
//    b) uña inferior: el portamatriz cuelga del riel inferior. ORDEN DE ARMADO (verificado con
//       blender/montaje_secuencia.py): placa + columnas -> cada cara BAJA en vertical desde arriba hasta
//       colgar del riel -> anillo superior -> cara superior. Con el anillo puesto la cara no se puede sacar
//       (la uña necesita subir ≈3.6 mm y la moldura solo deja 0.4 mm; inclinarla tampoco funciona):
//       para cambiar una matriz hay que quitar antes la cara superior y el anillo
//    c) 8 imanes portamatriz <-> estructura (estabilizan, eliminan vibración)
//    d) 1 tornillo M3 de seguridad en la parte alta, apretado desde el interior
//  MATRIZ SUPERIOR: gravedad + 2 pasadores integrados + 16 imanes. El giro no puede
//  levantarla; solo se retira tirando hacia arriba con la mano.
//
//  SUFIJOS:  _TBD = pendiente de medir/elegir (valor marcador, NO usar para fabricar)
//            _FOTO = estimado en fotografía (±3 mm)    _STD = dato publicado/normalizado
//  Origen: z = 0 bajo la placa inferior; eje de giro = Z. Unidades: mm.
// =============================================================================

/* [Vista] */
view = "assembly"; // [assembly, exploded, section, structure_only, part_bottom_plate, part_corner_column, part_top_ring, part_holder_side_A, part_holder_side_B, part_holder_top_A, part_holder_top_B, part_calibration, part_template_A, part_template_B]
explode = 60;
show_panels = true;
show_pi = true;
side_variants = ["A", "A", "A", "B"];   // variante de matriz en cada cara lateral 0..3
top_variant   = "B";                    // total: 3 A + 2 B

/* [Matriz LED — datos del usuario] */
panel_w = 192;          // usuario: 192 x 192
pcb_t   = 1.5;          // usuario
led_h   = 1.0;          // usuario
comp_h  = 10;           // usuario: componente trasero más alto
pcb_hole_d = 0.9;       // usuario: agujero de la PCB para el tornillo original
pcb_screw_d = 1.0;      // usuario: tornillo original (desde atrás)

/* [Matriz LED — pendientes de medir] */
// Posiciones de los tornillos originales [x, y] en mm, vista TRASERA, origen esquina inf. izq.
// Foto del usuario (03-nov, huecos marcados en verde en la base original): anillo de 4 agujeros por lado (esquinas incluidas)
// con separación de 60 mm entre centros (dato del usuario, aprox.) => borde a (192 - 3*60)/2 = 6 mm, + 2 en la viga central a la altura
// de los agujeros intermedios (supuesto). Los insertos amarillos NO llevan tornillo. Verificar con la plantilla de prueba (view = part_template).
// (11-nov) Prueba de la plantilla impresa con paso 60 sobre la matriz A: el 3.º agujero desviado ≈0.5 mm y el 4.º ≈1 mm, hacia fuera,
// igual en los 4 lados. Con la misma cinta: esquina a esquina 179 mm en la matriz y 178 mm en la plantilla => la plantilla impresa
// sale 1 mm más corta en 3 pasos. Se diseña con 181 mm (medida relativa: absorbe a la vez el error de la cinta y el de la impresora).
screw_pitch = 181 / 3;           // 60.33
screw_ring = [for (i = [0 : 3]) (panel_w - 3 * screw_pitch) / 2 + i * screw_pitch];
screws_B_FOTO = concat([for (x = screw_ring, y = [screw_ring[0], screw_ring[3]]) [x, y]],               // bordes superior e inferior (4 + 4)
                       [for (y = [screw_ring[1], screw_ring[2]], x = [screw_ring[0], screw_ring[3]]) [x, y]],  // laterales intermedios (2 + 2)
                       [for (y = [screw_ring[1], screw_ring[2]]) [panel_w / 2, y]]);       // viga central (2)
screws_A_FOTO = screws_B_FOTO;   // usuario (03-nov): A y B tienen los tornillos en las mismas posiciones y en igual cantidad
pcb_screw_head_d = 2.0;          // usuario (03-nov): cabeza ≈ 2 mm (aproximado, medir con calibre)
pcb_screw_grip_TBD   = 3.0;      // espesor de plástico bajo la cabeza en la base original (supuesto; el tornillo mide 5 mm: usuario)
pcb_screw_len = 5;               // usuario (03-nov): largo del tornillo original ≈ 5 mm
// Tolerancia de posición SIN arandelas: agujero de paso algo holgado (la cabeza de 2 mm apoya en su borde) + plantilla de prueba 1:1
// para comprobar las posiciones antes de imprimir el portamatriz (view = part_template).
screw_tol  = 0.25;               // error de posición que absorbe el agujero de paso, en cualquier dirección (mm)
// (11-nov) Los agujeros son ranuras cortas orientadas hacia el centro de la matriz: un error de escala (paso mal medido, impresora que
// encoge) desplaza cada agujero en esa dirección. Absorben ±(screw_slot + screw_tol) en dirección radial; la cabeza apoya igual que antes.
screw_slot = 0.5;                // medio recorrido extra de la ranura en dirección radial (mm)
screw_well_d = 3.6;              // pozo sobre la cabeza en los separadores: varilla de destornillador ≤ 3.4 mm
// Aro bajo: placa plana pegada a la cara trasera de la PCB (como la base original) que recibe los tornillos que los separadores no alcanzan
edge_out = 92.5;                 // borde exterior del aro (u, v): deja ≥ 1 mm a la aleta diagonal de la columna de esquina
edge_in  = 79;                   // borde interior del aro; entre edge_in y hl el aro se une al marco con muros
link_len = 16;                   // largo de cada muro de enlace aro–marco
link_pos = [0, 60, -60];         // posiciones de los muros en los lados izquierdo y derecho
link_top_u = [27, -29.5];        // muros en los lados superior e inferior, entre las ventanas de conectores (el de -29.5 sujeta el trozo de barra que dejan las ventanas de la variante A)
edge_t = pcb_screw_grip_TBD;     // espesor del aro bajo = agarre: la cabeza apoya en su cara superior
// (11-nov) Prueba de la plantilla en la matriz A: el aro (3.5–17 mm del borde) quedaba sobre componentes. Usuario: empiezan a 15 mm
// del borde y miden ≈ 3 mm. El aro se escalona: franja baja junto al borde (donde apoyan las cabezas), muro, y repisa elevada
// sobre los componentes que lo une al marco. Todo lo que está a más de edge_free - edge_free_margin del borde queda por encima de edge_relief_h.
edge_free = 15;                  // usuario: distancia del borde de la PCB a la que empiezan los componentes (cinta)
edge_free_margin = 3;            // margen por la medida con cinta
edge_comp_h = 3;                 // usuario: altura aproximada de esos componentes
edge_low_w = 9;                  // ancho (desde el borde de la PCB) de la franja baja; ≥ 1.25 mm más que la ranura, para el destornillador
                                 // (con 8.5 el escalón quedaba tangente a los separadores de la fila inferior: aristas no manifold)
// Conectores [x, y, ancho, alto], vista trasera (HUB75 entrada, HUB75 salida, alimentación)
conn_A_FOTO = [[30,140,14,36], [140,140,14,36], [ 95,150,16,22]];
// B, alimentación: corregida el 03-nov con la foto (carcasa medida ≈ x 80–90, y 39–56 mm; antes y = 52–74). Caja algo mayor que la carcasa;
// su ventana (+conn_margin) debe quedar a ≥ 0 mm del separador del tornillo de la viga en (96, 66).
conn_B_FOTO = [[30,122,14,36], [150,122,14,36], [ 77, 38,16,19]];
conn_margin = 6;                 // holgura alrededor de cada conector y su cable
// (03-nov) Se quitaron los 4 apoyos con espuma de 1 mm a 22 mm de cada esquina: caían sobre chips de la PCB (foto de la
// variante A) y ya no hacen falta porque la PCB queda sujeta por sus 14 tornillos, incluidos 2 en el centro.

/* [Diseño — ajustables] */
gap_g     = 0.8;    // holgura matriz–moldura. (12-nov) Antes 0.4: no dejaba margen si la impresora imprime un 0.5 % pequeño
                    // (la abertura quedaba por debajo de 192), y la cara colgada de sus uñas (0.4 mm más abajo) apoyaba el borde en el labio
trim_t    = 5;      // ancho visible de la moldura en cada cara, además de gap_g
mold_leg  = 2;      // espesor del ala de la moldura (cara exterior a ras de los LED)
fin_t     = 3;      // aleta diagonal que une moldura y poste
standoff_extra = 1.5;  // holgura sobre el componente más alto
holder_t  = 3;      // espesor del marco del portamatriz
frame_bar = 14;     // ancho de las barras del portamatriz (perímetro y cruz)
post_s    = 12;     // sección del poste de esquina
bottom_t  = 4;      // espesor de la placa inferior
ring_t    = 3;      // espesor del anillo superior
ring_bar  = 16;     // ancho de las barras del anillo
rail_t    = 4;      // espesor de rieles inferior y superior
rail_h_bottom = 18; // altura del riel inferior sobre la placa
rail_top_len  = 33; // cuánto baja el riel superior desde el anillo
hook_w    = 16;
hook_drop = 4;      // cuánto baja la uña por detrás del riel
hook_clear = 0.7;   // holgura uña–riel (la cara de la uña que mira al riel se imprime sobre soportes)
clear     = 0.4;    // holgura general entre piezas
vent_slot_w = 4;    // ranuras de ventilación (no pasa un dedo)
peg_d     = 4;      // pasadores del panel superior
peg_h     = 4;

/* [Imanes e insertos] */
magnet_d = 5;  magnet_h = 2;     // usuario: 5 x 2, unión imán-imán
magnet_clear_d = 0.2;            // calibrar con la probeta
magnet_skin = 0.6;               // piel que deja el imán cautivo (pausa de impresión)
mag_boss_h = 4;                  // refuerzo bajo cada imán del portamatriz, medido desde su cara trasera
// (12-nov) Sin insertos térmicos: el tornillo de seguridad también rosca en el plástico (ver safety_len)
m3_tap_d = 2.6;  m3_tap_len = 7;     // agujero guía para que el M3 rosque directamente en el plástico (extremos de las columnas)
m3_clear = 3.6;  m3_head_d = 6.2;   // 3.6: los agujeros impresos salen algo pequeños y hay que alinear 4 columnas con el anillo a la vez
safety_hole_d = 3.8;  safety_slot = 1;             // paso del tornillo de seguridad en el riel: ±0.4 mm de lado; en vertical de -1.4 a +0.4 mm (ranura hacia abajo)
m3_head_h = 3.0;                 // cabeza Allen M3 (ISO 4762); con cabeza abombada (ISO 7380, 1.65 mm) sobra
plate_boss = 2;                  // engrosamiento de la placa bajo cada poste (la cabeza M3 va embutida por debajo)
ring_boss  = 3;                  // engrosamiento del anillo bajo cada poste (la cabeza M3 va embutida por arriba)
ring_mag_boss = 2;               // engrosamiento del anillo bajo cada imán de la cara superior (deja 2.2 mm bajo el imán)
m3_seat_min = 2;                 // plástico mínimo bajo la cabeza M3 embutida

/* [Interfaces pendientes (slip ring, eje, rodamiento)] */
center_hole_d_TBD = undef;       // agujero central para eje / slip ring — sin elegir
rot_bolt_circle_TBD = undef;     // círculo de tornillos del soporte de giro — sin elegir
rot_bolt_n_TBD = 4;
rot_bolt_d_TBD = undef;

/* [Raspberry Pi 4] */
pi_board_STD = [85.6, 56.5];     // dimensiones publicadas
pi_holes_STD = [58, 49];         // separación de taladros publicada
pi_hole_inset_STD = 3.5;
pi_boss_h = 5;
pi_boss_hole = 2.2;              // tornillo M2.5 autorroscante; calibrar
pi_height_ENV = 25;              // altura con adaptador HUB75 (solo visual)

/* [Impresora] */
bed_TBD = undef;                 // [x, y, z] cuando se elija la impresora

$fn = 40;
eps = 0.01;

// ============================================================ DERIVADOS
panel_t = pcb_t + led_h;                       // 2.5
so      = comp_h + standoff_extra;             // separador PCB -> marco
edge_relief_in = panel_w / 2 - (edge_free - edge_free_margin);   // desde aquí hacia dentro, nada toca la PCB por debajo de edge_relief_h
edge_relief_h  = edge_comp_h + standoff_extra;                   // hueco sobre los componentes del borde
edge_top       = edge_relief_h + edge_t;                         // altura del muro y de la repisa del aro sobre la PCB
D       = panel_t + so + holder_t;             // profundidad hasta la cara trasera del portamatriz
W       = panel_w + 2 * (gap_g + trim_t);      // lado exterior del cubo
H       = W;                                   // cubo
h2      = W / 2;
sk      = h2 - D;                              // cara exterior de la estructura interior
hl      = sk - fin_t;                          // límite lateral del portamatriz
z0      = trim_t + gap_g;                      // borde inferior de la PCB lateral
zc      = z0 + panel_w / 2;                    // centro de la cara lateral
ring_z  = H - D - ring_t;                      // cara inferior del anillo
holder_v_lo = (bottom_t + 1) - zc;             // límite inferior del portamatriz lateral (local)
holder_v_hi = ring_z - zc;                     // límite superior
post_c  = sk - post_s / 2;                     // centro del poste
mag_lat = post_c - 1.5;                        // imanes de esquina sobre el poste (lejos de la aleta)
rail_top_z = bottom_t + rail_h_bottom;
z_mag   = [bottom_t + 8, zc, ring_z - 8];      // filas de imanes laterales (abajo, centro, arriba)
// Tornillo de seguridad lateral. Antes en u = 0, z = ring_z - 18: quedaba justo debajo de la cruz del anillo y la llave en L no
// podía bajar en vertical hasta él. Fuera de la cruz la llave baja por la ventana del anillo (|x| de 8 a 68 mm); el agujero
// guía va en la barra superior del marco del portamatriz (v de vhi - frame_bar a vhi), no en la ventana del marco.
// (18-nov) De u = -30 a u = 33: con las muescas del riel, en u = -30 el tornillo quedaba en un trozo de riel de 17 mm colgado
// 33 mm del anillo (se podía romper por las capas antes que la rosca); en u = 33 está en el trozo largo (u de 7 a 46 en A).
safety_u = 33;
// (12-nov) El M3×8 atraviesa el riel (rail_t = 4) y entra 4 mm en el portamatriz: rosca en un agujero guía de 4 mm. Antes era un
// inserto de 5.7 mm cuyo refuerzo bajaba a 7.8 mm de la PCB, por debajo del componente más alto (comp_h = 10).
safety_len = 8 - rail_t;
z_screw = ring_z - frame_bar / 2;              // centro de la barra superior del marco del portamatriz lateral
col_z0  = bottom_t + plate_boss;               // base de la columna (poste, aleta y moldura): apoya en el engrosamiento de la placa
hook_u  = [-40, 40];
// Imanes de la cara superior (portamatriz superior + cara de arriba del anillo). (11-nov) 16 en vez de 8: con 8 N35 la cara
// aguantaba 2.6 veces su peso boca abajo; los 8 nuevos van en el perímetro, fuera de las ventanas de conectores de B, de los
// pasadores y de los tornillos del anillo. En los lados izquierdo y derecho las ventanas HUB75 de B (v de 20 a 68) no son simétricas:
// la de u < 0 llega a u = -74 y dejaba 0.3 mm de pared a un imán en (-76.9, 36.5); ese imán y su simétrico (giro de 180°)
// pasan a los lados de arriba y abajo. Todo el conjunto es simétrico con un giro de 180° (la cara entra en las dos posiciones).
// (12-nov) Esos dos, de u = ∓55 a u = ∓18: en ∓55 el refuerzo bajo el imán (en el anillo) quedaba justo encima del HUB75 de la
// cara lateral de debajo y tapaba la salida de su cable.
top_mag = concat([[-73,-73],[0,-mag_lat],[73,-73],[-mag_lat,0],[mag_lat,0],[-73,73],[0,mag_lat],[73,73]],
                 [for (s = [-1, 1], t = [-1, 1]) [s * 36.5, t * mag_lat]],
                 [[mag_lat, 36.5], [-mag_lat, -36.5], [-18, mag_lat], [18, -mag_lat]]);

// ============================================================ VALIDACIONES
// La aleta diagonal pasa entre la PCB de una cara y la de la vecina:
fin_gap_pcb = (h2 - panel_t - panel_w / 2) / sqrt(2) - fin_t / 2;     // a la esquina trasera de la PCB
assert(fin_gap_pcb >= 0.4, str("La aleta toca la PCB (", fin_gap_pcb, " mm): aumentar trim_t o reducir fin_t"));
assert(mold_leg <= led_h + pcb_t, "La moldura no debe sobresalir del plano de los LED");
assert(holder_v_hi >= z_screw - zc + 5, "No cabe el tornillo de seguridad");
assert(min([for (u = [-mag_lat, 0, mag_top_u("A"), mag_lat]) norm([u - safety_u, z_mag[2] - z_screw])]) >= 10,
       "El refuerzo del tornillo de seguridad choca con el de un imán superior");
assert(bottom_t + plate_boss - (m3_head_h + 0.3) >= m3_seat_min, "Placa: queda poco plástico bajo la cabeza M3 embutida");
assert(ring_t + ring_boss - (m3_head_h + 0.3) >= m3_seat_min, "Anillo: queda poco plástico bajo la cabeza M3 embutida");
screw_pass_d = pcb_screw_d + 2 * screw_tol;      // agujero de paso holgado: el tornillo puede desviarse screw_tol en cualquier dirección
assert((pcb_screw_head_d - screw_pass_d) / 2 >= 0.2, str("La cabeza (", pcb_screw_head_d, " mm) apoya menos de 0.2 mm alrededor del agujero de paso (", screw_pass_d, " mm)"));
assert(panel_t + pcb_screw_grip_TBD - pcb_screw_len <= led_h, "El tornillo no atraviesa la PCB: su punta queda por encima de ella");
assert(edge_out < panel_w / 2 - 3, "El aro bajo debe quedar dentro de la PCB");
// pared entre la ranura del tornillo más exterior y el borde del aro bajo (o de la plantilla)
slot_wall = min([for (q = all_pts("A")) edge_out - (max(abs(q[0]), abs(q[1])) + screw_slot * max(abs(q[0]), abs(q[1])) / norm(q) + screw_pass_d / 2)]);
assert(slot_wall >= 0.7, str("Queda poca pared (", slot_wall, " mm) entre la ranura de un tornillo y el borde del aro bajo"));
slot_reach = max([for (q = all_pts("A")) let(m = max(abs(q[0]), abs(q[1]))) if (m > edge_relief_in)     // tornillos del borde: hasta dónde llega su ranura desde el borde
                  panel_w / 2 - m + screw_slot * m / norm(q) + screw_pass_d / 2]);
assert(edge_low_w - slot_reach >= 1.25, "La franja baja del aro es demasiado angosta para el destornillador");
assert(panel_w / 2 - edge_low_w - edge_relief_in >= 2, "El muro del aro escalonado queda demasiado delgado");
assert(edge_in < edge_relief_in, "La repisa del aro no llega por encima de los componentes del borde");
assert(screw_well_d / 2 >= pcb_screw_head_d / 2 + screw_slot + screw_tol, "El pozo no deja pasar la cabeza cuando el tornillo está al final de la ranura");
assert((6 - screw_well_d) / 2 >= 1.2, "Pared del separador demasiado delgada alrededor del pozo");
assert(trim_t < col_z0, "La columna debe empezar por encima del labio de la placa");
assert(so + holder_t - mag_boss_h >= comp_h + 0.5, "El refuerzo de los imanes del portamatriz baja hasta los componentes de la matriz");
assert(mag_boss_h - magnet_skin - magnet_h - 0.2 >= 0.8, "Queda poco plástico bajo el imán del portamatriz");
assert(so + holder_t - safety_len >= comp_h + 0.5, "El refuerzo del tornillo de seguridad baja hasta los componentes de la matriz");
echo(str("Aro escalonado: franja baja ", edge_low_w, " mm desde el borde, nada toca la PCB a más de ", edge_free - edge_free_margin,
         " mm del borde (hueco de ", edge_relief_h, " mm sobre los componentes)"));
echo(str("Ranuras de tornillo: ±", screw_slot + screw_tol, " mm hacia el centro, ±", screw_tol, " mm de lado; pared al borde del aro ", round(slot_wall * 100) / 100, " mm"));
echo(str("== Cubo: ", W, " x ", W, " x ", H, " mm; moldura visible por cara ", gap_g + trim_t, " mm"));
echo(str("== Profundidad matriz->estructura ", D, " mm; separador ", so, " mm; portamatriz ", 2 * hl, " mm"));
echo(str("== Holgura aleta-PCB: ", round(fin_gap_pcb * 100) / 100, " mm"));
echo(str("== Diámetro barrido por las esquinas al girar: ", round(W * sqrt(2)), " mm"));
if (is_undef(center_hole_d_TBD)) echo("PENDIENTE: agujero central (eje/slip ring) sin definir -> placa sin agujero central");
if (is_undef(rot_bolt_circle_TBD)) echo("PENDIENTE: interfaz del soporte de giro sin definir -> sin taladros");
echo("PENDIENTE: agarre del tornillo original (pcb_screw_grip_TBD); posiciones y cabeza vienen de foto/usuario: verificar con la plantilla de prueba");
echo(str("Tolerancia de posición de los tornillos: ±", screw_tol, " mm (agujero de paso ", screw_pass_d, " mm)"));
echo("PENDIENTE: confirmar en la variante B que los componentes del borde empiezan a ≥ ", edge_free, " mm (medido en A el 11-nov)");
module bed_check(name, s) {
    if (is_undef(bed_TBD)) echo(str("Tamaño de ", name, ": ", s[0], " x ", s[1], " x ", s[2], " mm (impresora sin elegir)"));
    else if (s[0] > bed_TBD[0] || s[1] > bed_TBD[1] || s[2] > bed_TBD[2])
        echo(str("ADVERTENCIA: ", name, " no cabe en la impresora -> dividir"));
}

C_PRINT = [0.13, 0.13, 0.14];
C_HOLD  = [0.22, 0.22, 0.25];
C_PCB   = [0.10, 0.22, 0.12];
C_LED   = [0.02, 0.02, 0.02];
C_ENV   = [0.25, 0.45, 0.75, 0.8];

// =============================================================================
//  UTILIDADES
// =============================================================================
// Alojamiento de imán cautivo. La piel queda en la cara de contacto (z = 0),
// el imán queda dentro (z negativa). Se inserta en una pausa de impresión.
// 'flat' (dirección en el plano local xy que apunta HACIA ARRIBA al imprimir): para imanes que se imprimen de canto.
// Un hueco redondo de canto no deja meter el imán en la pausa (arriba solo queda una rendija de ~1.4 mm);
// en forma de "D" con el lado plano hacia arriba la abertura es de todo el diámetro. Techo 0.2 mm por encima del imán
// para que la pausa siempre caiga por encima de él con capas de 0.2 mm.
module magnet_pocket_into(depth_dir = -1, flat = undef) {
    r = (magnet_d + magnet_clear_d) / 2;
    translate([0, 0, depth_dir < 0 ? -magnet_skin - magnet_h - 0.2 : magnet_skin])
        linear_extrude(magnet_h + 0.2) union() {
            circle(r = r);
            if (!is_undef(flat)) rotate(atan2(flat[1], flat[0])) translate([0, -r]) square([r + 0.2, 2 * r]);
        }
}
function screws_of(v) = v == "A" ? screws_A_FOTO : screws_B_FOTO;
// Imán superior central de la cara lateral: en la variante A caía dentro de la ventana del conector de alimentación
// (el portamatriz A se quedaba con 7 imanes); se desplaza a u = 20, fuera de esa ventana.
function mag_top_u(v) = v == "A" ? 20 : 0;
function conns_of(v)  = v == "A" ? conn_A_FOTO  : conn_B_FOTO;
// Conversión de vista trasera (x desde la izquierda mirando la espalda) a coordenadas
// de cara vistas desde fuera: u hacia la derecha, v hacia arriba, centradas.
function back2u(x) = panel_w / 2 - x;
function back2v(y) = y - panel_w / 2;

// Coordenadas de cara: u (derecha vista desde fuera), v (arriba), w (hacia dentro, 0 = plano de LED)
module place_side(i) {
    rotate([0, 0, 90 * i]) multmatrix([[-1, 0, 0, 0], [0, 0, -1, h2], [0, 1, 0, zc], [0, 0, 0, 1]]) children();
}
module place_top() {
    multmatrix([[1, 0, 0, 0], [0, 1, 0, 0], [0, 0, -1, H], [0, 0, 0, 1]]) children();
}

// Tornillos originales de la PCB que el portamatriz sí alcanza (coordenadas de cara u, v)
function holder_pts(v, is_top) =
    let(vlo = is_top ? -hl : holder_v_lo, vhi = is_top ? hl : holder_v_hi)
    [for (p = screws_of(v)) let(u = back2u(p[0]), vv = back2v(p[1]))
        if (abs(u) <= hl - 4 && vv >= vlo + 4 && vv <= vhi - 4) [u, vv]];

// Los demás tornillos (contorno de la PCB) los recibe el aro bajo del portamatriz
function all_pts(v) = [for (p = screws_of(v)) [back2u(p[0]), back2v(p[1])]];
function ring_pts(v, is_top) =
    let(pts = holder_pts(v, is_top))
    [for (q = all_pts(v)) if (len([for (r = pts) if (norm(r - q) < 0.01) 1]) == 0) q];

// Agujero de tornillo de la PCB en q = [u, v] (desde z = 0, altura h): ranura de diámetro d orientada hacia el centro de la matriz
module screw_slot_hole(q, d, h) {
    r = norm(q) > 0.01 ? q / norm(q) : [0, 0];
    hull() for (s = [-1, 1]) translate([q[0] + s * screw_slot * r[0], q[1] + s * screw_slot * r[1], 0]) cylinder(d = d, h = h, $fn = 24);
}

// Marcadores (solo visualización): los 14 tornillos de la PCB; altos = en separador del marco, bajos = en el aro bajo
module screw_marks(v, is_top) {
    for (q = holder_pts(v, is_top)) translate([q[0], q[1], panel_t]) cylinder(d = 3, h = D - panel_t + 3, $fn = 16);
    for (q = ring_pts(v, is_top))   translate([q[0], q[1], panel_t]) cylinder(d = 3, h = edge_t + 3, $fn = 16);
}

// =============================================================================
//  MATRIZ (referencia simplificada, en coordenadas de cara)
// =============================================================================
module panel_ref(v) {
    color(C_LED) translate([-panel_w / 2, -panel_w / 2, 0]) cube([panel_w, panel_w, led_h]);
    // PCB con sus agujeros de tornillo (mismas posiciones en A y B)
    color(C_PCB) difference() {
        translate([-panel_w / 2, -panel_w / 2, led_h]) cube([panel_w, panel_w, pcb_t]);
        for (p = screws_of(v)) translate([back2u(p[0]), back2v(p[1]), led_h - 1]) cylinder(d = pcb_hole_d, h = pcb_t + 2, $fn = 16);
    }
    color([0.3, 0.3, 0.3]) for (c = conns_of(v))
        translate([back2u(c[0] + c[2]), back2v(c[1]), panel_t]) cube([c[2], c[3], comp_h]);
}

// =============================================================================
//  PORTAMATRIZ — una pieza por matriz (sustituye la base plástica original)
// =============================================================================
module holder(v = "A", is_top = false) {
    vlo = is_top ? -hl : holder_v_lo;
    vhi = is_top ?  hl : holder_v_hi;
    vmid = is_top ? 0 : 0;
    w0 = panel_t + so;                // cara delantera del marco
    w1 = w0 + holder_t;               // cara trasera (contacto con la estructura)
    pts = holder_pts(v, is_top);      // tornillos con separador hasta el marco
    rpts = ring_pts(v, is_top);       // tornillos del contorno, en el aro bajo
    assert(len(pts) + len(rpts) == len(screws_of(v)), "Algún tornillo de la PCB no queda asignado");
    echo(str("portamatriz ", v, is_top ? " superior" : " lateral", ": ", len(screws_of(v)), " tornillos de la PCB sujetos (",
             len(pts), " con separador, ", len(rpts), " en el aro bajo)"));
    mags = is_top ? top_mag
                  : [for (u = [-mag_lat, 0, mag_lat], z = z_mag) if (!(u == 0 && z == zc))
                        [(u == 0 && z == z_mag[2]) ? mag_top_u(v) : u, z - zc]];
    difference() {
        union() {
            // marco: perímetro + cruz (rigidez frente al peso; ver dibujo del usuario)
            translate([0, 0, w0]) linear_extrude(holder_t) difference() {
                translate([-hl, vlo]) square([2 * hl, vhi - vlo]);
                for (sx = [-1, 1], sy = [-1, 1]) {
                    x1 = sx < 0 ? -hl + frame_bar : frame_bar / 2;
                    x2 = sx < 0 ? -frame_bar / 2 : hl - frame_bar;
                    y1 = sy < 0 ? vlo + frame_bar : vmid + frame_bar / 2;
                    y2 = sy < 0 ? vmid - frame_bar / 2 : vhi - frame_bar;
                    translate([x1, y1]) offset(r = 3) offset(delta = -3) square([x2 - x1, y2 - y1]);
                }
            }
            // separadores en los tornillos originales (cada uno con su pastilla de unión al marco)
            for (p = pts) translate([p[0], p[1], panel_t]) {
                cylinder(d = 6, h = so + eps);
                translate([0, 0, so]) cylinder(d = 11, h = holder_t);
            }
            // aro bajo, escalonado (ver edge_free): franja baja junto al borde que recibe los tornillos del contorno (la cabeza apoya
            // en su cara superior, como en la base original), muro, y repisa elevada sobre los componentes del borde
            translate([0, 0, panel_t]) difference() {
                linear_extrude(edge_top) difference() {
                    square(2 * edge_out, center = true);
                    square(2 * edge_in, center = true);
                    for (c = conns_of(v)) translate([back2u(c[0] + c[2]) - conn_margin, back2v(c[1]) - conn_margin])
                        square([c[2] + 2 * conn_margin, c[3] + 2 * conn_margin]);
                }
                translate([0, 0, edge_t]) linear_extrude(edge_top) difference() {     // franja baja: solo edge_t de alto
                    square(2 * edge_out + 2, center = true);
                    square(2 * (panel_w / 2 - edge_low_w), center = true);
                }
                translate([0, 0, -1]) linear_extrude(edge_relief_h + 1) square(2 * edge_relief_in, center = true);   // hueco sobre los componentes
            }
            // muros de enlace aro-marco (entre edge_in y el borde del marco), elevados sobre los componentes
            translate([0, 0, panel_t + edge_relief_h]) linear_extrude(so - edge_relief_h + eps) {
                for (s = link_pos, sx = [-1, 1])        // lados izquierdo y derecho
                    translate([sx * (edge_in + hl) / 2 - (hl - edge_in) / 2, s - link_len / 2]) square([hl - edge_in, link_len]);
                for (sy = [-1, 1], tu = link_top_u)     // lados superior e inferior: muros fuera de las ventanas de conectores
                    translate([tu - link_len / 2, sy * (edge_in + hl) / 2 - (hl - edge_in) / 2]) square([link_len, hl - edge_in]);
            }
            // refuerzos locales bajo los imanes y el tornillo de seguridad
            // (d = 8.8: con 9 el cilindro rozaba justo el borde del marco en x = ±hl y dejaba aristas no manifold)
            // (12-nov) desde w1 - 4 (antes w1 - 5): así terminan a 10.5 mm de la PCB, por encima del componente más alto (comp_h = 10),
            // y dejan 1.2 mm de plástico bajo el imán
            for (m = mags) translate([m[0], m[1], w1 - mag_boss_h]) cylinder(d = 8.8, h = mag_boss_h);
            if (!is_top) translate([safety_u, z_screw - zc, w1 - safety_len]) cylinder(d = 10, h = safety_len);
            // uñas inferiores (cuelgan del riel inferior)
            if (!is_top) for (u = hook_u) {
                vh = rail_top_z + clear - zc;
                // zócalo que une la uña a la barra inferior del marco (antes quedaba flotando 3.4 mm por encima de la barra)
                translate([u - hook_w / 2, vlo + frame_bar - 1, w0]) cube([hook_w, vh + 3 - (vlo + frame_bar - 1), holder_t]);
                // la uña se imprime sobre soportes: holgura al riel hook_clear (mayor que clear) para que las marcas no la cierren
                translate([u - hook_w / 2, vh, w1 - eps]) cube([hook_w, 3, rail_t + hook_clear + 3]);
                translate([u - hook_w / 2, vh - hook_drop, w1 + rail_t + hook_clear]) cube([hook_w, hook_drop + 3, 3]);
            }
        }
        // tornillos originales: paso holgado (absorbe screw_tol); la cabeza apoya en el escalón a panel_t + agarre
        for (p = pts) {
            screw_slot_hole(p, screw_pass_d, w1 + 1);
            // pozo hasta la cabeza: 11.5 mm de hondo; redondo y ancho para que entre la varilla del destornillador
            // (antes 2.4 mm: no entraba un destornillador de precisión normal)
            translate([p[0], p[1], panel_t + pcb_screw_grip_TBD]) cylinder(d = screw_well_d, h = w1, $fn = 24);
        }
        for (p = rpts) screw_slot_hole(p, screw_pass_d, panel_t + edge_t + 1);   // en el aro la cabeza apoya en su cara superior
        // ventanas de conectores (el cable sale hacia el interior)
        for (c = conns_of(v)) translate([back2u(c[0] + c[2]) - conn_margin, back2v(c[1]) - conn_margin, panel_t + 1])
            cube([c[2] + 2 * conn_margin, c[3] + 2 * conn_margin, 30]);
        // imanes (piel en la cara de contacto)
        for (m = mags) translate([m[0], m[1], w1]) magnet_pocket_into(-1);
        // agujero guía del tornillo de seguridad (lateral): pasante, la punta del M3 llega justo a la cara inferior del refuerzo
        if (!is_top) translate([safety_u, z_screw - zc, w1 - safety_len - 1]) cylinder(d = m3_tap_d, h = safety_len + 2, $fn = 24);
        // agujeros de los pasadores (superior)
        if (is_top) for (x = [-40, 40]) translate([x, 0, w0 - 1]) cylinder(d = peg_d + 2 * clear, h = 10);
    }
}

// =============================================================================
//  PLANTILLA DE PRUEBA 1:1 — se apoya sobre la cara trasera de la PCB para comprobar que los 14 agujeros coinciden
//  antes de imprimir el portamatriz (un tornillo original debe entrar por cada agujero). Deja libres los conectores.
//  El marco solo ocupa la franja libre de componentes del borde (como la parte que apoya del aro escalonado).
//  4 lengüetas llegan exactamente al borde de la PCB: si quedan cortas, la impresora imprime más pequeño (≈1 mm corta = 1 %).
// =============================================================================
// Grosor = edge_t (agarre bajo la cabeza, igual que el aro del portamatriz): con 2 mm el tornillo de 5 mm entraba 1 mm más
// en la matriz que en el montaje real y podía tocar la máscara de los LED.
module screw_template(v = "B") {
    difference() {
        linear_extrude(edge_t) union() {
            difference() { square(2 * edge_out, center = true); square(2 * edge_relief_in, center = true); }
            translate([-7, -edge_out]) square([14, 2 * edge_out]);        // viga central
            for (a = [0 : 90 : 270]) rotate(a) translate([edge_out - 1, -5]) square([panel_w / 2 - edge_out + 1, 10]);   // lengüetas al borde
        }
        for (q = all_pts(v)) translate([0, 0, -1]) screw_slot_hole(q, screw_pass_d, edge_t + 2);
        for (c = conns_of(v)) translate([back2u(c[0] + c[2]) - conn_margin, back2v(c[1]) - conn_margin, -1])
            cube([c[2] + 2 * conn_margin, c[3] + 2 * conn_margin, edge_t + 2]);
    }
}

// =============================================================================
//  COLUMNA DE ESQUINA — poste + aleta + moldura vertical (4 iguales)
//  Dibujada para la esquina (+x, +y); las demás se obtienen girando 90°.
// =============================================================================
module corner_column() {
    difference() {
        union() {
            // poste estructural (entre los engrosamientos de la placa y del anillo)
            translate([sk - post_s, sk - post_s, bottom_t + plate_boss]) cube([post_s, post_s, ring_z - ring_boss - bottom_t - plate_boss]);
            // aleta diagonal (del poste a la arista exterior); no invade los engrosamientos de placa y anillo
            translate([0, 0, col_z0]) linear_extrude(ring_z - ring_boss - col_z0)
                hull() { translate([sk, sk]) circle(d = fin_t);                 // espesor real = fin_t
                         translate([h2 - fin_t / 2, h2 - fin_t / 2]) circle(d = fin_t); }
            // moldura: dos alas a ras de los LED. Empieza a col_z0, como el poste y la aleta: así la columna apoya entera
            // en la cama al imprimirla (antes el poste quedaba 1 mm en el aire y la columna de 193 mm se sostenía sobre 16 mm²)
            translate([0, 0, col_z0]) linear_extrude(H - trim_t - col_z0) {
                translate([panel_w / 2 + gap_g, h2 - mold_leg]) square([h2 - panel_w / 2 - gap_g, mold_leg]);
                translate([h2 - mold_leg, panel_w / 2 + gap_g]) square([mold_leg, h2 - panel_w / 2 - gap_g]);
            }
        }
        // agujero guía en ambos extremos del poste: el M3 hace su propia rosca en el plástico. (12-nov) Antes eran insertos
        // térmicos a 1.2 mm de los imanes de las columnas: el soldador (230 °C) los habría desimantado (N35: máx. ≈ 80 °C).
        for (z = [col_z0 - eps, ring_z - ring_boss - m3_tap_len])
            translate([post_c, post_c, z]) cylinder(d = m3_tap_d, h = m3_tap_len + eps, $fn = 24);
        // imanes en las dos caras exteriores del poste (piel hacia el portamatriz)
        for (z = z_mag) {
            // la columna se imprime de pie: arriba = +z (local -y en la primera, local -x en la segunda)
            translate([mag_lat, sk, z]) rotate([-90, 0, 0]) magnet_pocket_into(-1, flat = [0, -1]);
            translate([sk, mag_lat, z]) rotate([0, 90, 0]) magnet_pocket_into(-1, flat = [-1, 0]);
        }
    }
}

// =============================================================================
//  PLACA INFERIOR — fondo cerrado + labio-moldura + rieles + soportes de la Pi
// =============================================================================
pi_origin = [-pi_board_STD[0] / 2, 12];
module bottom_plate() {
    difference() {
        union() {
            translate([-h2, -h2, 0]) cube([W, W, bottom_t]);
            // labio exterior = moldura de las aristas inferiores (a ras de los LED)
            linear_extrude(trim_t) difference() { square(W, center = true); square(W - 2 * mold_leg, center = true); }
            // en las esquinas el labio sube hasta col_z0, debajo de las alas de la moldura de cada columna
            for (i = [0 : 3]) rotate(90 * i) translate([0, 0, trim_t - eps]) linear_extrude(col_z0 - trim_t + eps) {
                translate([panel_w / 2 + gap_g, h2 - mold_leg]) square([h2 - panel_w / 2 - gap_g, mold_leg]);
                translate([h2 - mold_leg, panel_w / 2 + gap_g]) square([mold_leg, h2 - panel_w / 2 - gap_g]);
            }
            // rieles inferiores (las uñas de los portamatrices cuelgan de ellos)
            for (i = [0 : 3]) rotate(90 * i)
                translate([-(sk - post_s - clear), sk - rail_t, 0]) cube([2 * (sk - post_s - clear), rail_t, rail_top_z]);
            // soportes de la Raspberry Pi 4
            if (true) for (x = [0, pi_holes_STD[0]], y = [0, pi_holes_STD[1]])
                translate([pi_origin[0] + pi_hole_inset_STD + x, pi_origin[1] + pi_hole_inset_STD + y, 0])
                    cylinder(d = 6, h = bottom_t + pi_boss_h);
            // engrosamientos bajo los postes: dejan m3_seat_min de plástico bajo la cabeza embutida (antes quedaba 1 mm)
            for (sx = [-1, 1], sy = [-1, 1]) translate([sx * post_c - post_s / 2, sy * post_c - post_s / 2, bottom_t - eps])
                cube([post_s, post_s, plate_boss + eps]);
        }
        // tornillos a las columnas (desde abajo, cabeza embutida)
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * post_c, sy * post_c, -1]) {
            cylinder(d = m3_clear, h = bottom_t + plate_boss + 2);
            cylinder(d = m3_head_d, h = 1 + m3_head_h + 0.3);
        }
        // imanes del centro inferior de cada cara (en el riel)
        for (i = [0 : 3]) rotate(90 * i) translate([0, sk, z_mag[0]]) rotate([-90, 0, 0]) magnet_pocket_into(-1, flat = [0, -1]);   // placa: arriba = +z
        // ranuras de ventilación (4 mm: no pasa un dedo)
        for (x = [-60 : 9 : 60]) translate([x - vent_slot_w / 2, -62, -1]) cube([vent_slot_w, 62, bottom_t + 2]);
        // (18-nov) también debajo de la Raspberry Pi, entre sus dos filas de soportes (antes no había ventilación bajo ella)
        for (x = [-60 : 9 : 60]) translate([x - vent_slot_w / 2, pi_origin[1] + pi_hole_inset_STD + 6, -1])
            cube([vent_slot_w, pi_holes_STD[1] - 12, bottom_t + 2]);
        // taladros de la Pi
        for (x = [0, pi_holes_STD[0]], y = [0, pi_holes_STD[1]])
            translate([pi_origin[0] + pi_hole_inset_STD + x, pi_origin[1] + pi_hole_inset_STD + y, 1])
                cylinder(d = pi_boss_hole, h = 20);
        // interfaces pendientes
        if (!is_undef(center_hole_d_TBD)) translate([0, 0, -1]) cylinder(d = center_hole_d_TBD, h = 20);
        if (!is_undef(rot_bolt_circle_TBD) && !is_undef(rot_bolt_d_TBD))
            for (a = [0 : 360 / rot_bolt_n_TBD : 359]) rotate(a) translate([rot_bolt_circle_TBD / 2, 0, -1])
                cylinder(d = rot_bolt_d_TBD, h = 20);
    }
}

// =============================================================================
//  ANILLO SUPERIOR — marco + cruz + molduras superiores + rieles superiores
// =============================================================================
module top_ring() {
    difference() {
        union() {
            // marco con cruz (apoyo de la matriz superior y unión de las 4 columnas)
            translate([0, 0, ring_z]) linear_extrude(ring_t) difference() {
                square(2 * sk, center = true);
                for (sx = [-1, 1], sy = [-1, 1])            // 4 ventanas entre marco y cruz
                    translate([sx > 0 ? ring_bar / 2 : -(sk - ring_bar), sy > 0 ? ring_bar / 2 : -(sk - ring_bar)])
                        offset(r = 3) offset(delta = -3) square(sk - 1.5 * ring_bar);
            }
            // engrosamientos bajo el anillo sobre cada poste (asiento de la cabeza M3 embutida)
            for (sx = [-1, 1], sy = [-1, 1]) translate([sx * post_c - post_s / 2, sy * post_c - post_s / 2, ring_z - ring_boss])
                cube([post_s, post_s, ring_boss + eps]);
            // pasadores para la matriz superior
            for (x = [-40, 40]) translate([x, 0, H - D - eps]) cylinder(d = peg_d, h = peg_h);
            // refuerzos bajo los imanes de la cara superior: el anillo mide 3 mm y el hueco (piel + imán) 2.8 mm, así que
            // por debajo quedaba una sola capa de 0.2 mm cerrando el imán (en las esquinas ya lo cubre el engrosamiento del poste)
            for (m = top_mag) translate([m[0], m[1], ring_z - ring_mag_boss]) cylinder(d = 8.8, h = ring_mag_boss + eps);
            // rieles superiores de las caras laterales (reciben imán y tornillo de seguridad)
            for (i = [0 : 3]) rotate(90 * i)
                translate([-(sk - post_s - clear), sk - rail_t, ring_z - rail_top_len]) cube([2 * (sk - post_s - clear), rail_t, rail_top_len + eps]);
            // molduras de las aristas superiores + aletas hacia el anillo
            for (i = [0 : 3]) rotate(90 * i) {
                // ala superior y ala lateral (inglete a 45° con la vecina)
                intersection() {
                    union() {
                        translate([-h2, panel_w / 2 + gap_g, H - mold_leg]) cube([W, h2 - panel_w / 2 - gap_g, mold_leg]);
                        translate([-h2, h2 - mold_leg, H - trim_t]) cube([W, mold_leg, trim_t]);
                    }
                    miter_zone();
                }
                // aleta diagonal en el plano y-z
                intersection() {
                    rotate([90, 0, 90]) linear_extrude(W, center = true)
                        hull() { translate([sk, H - D]) circle(d = fin_t);
                                 translate([h2 - fin_t / 2, H - fin_t / 2]) circle(d = fin_t); }
                    miter_zone();
                }
            }
        }
        // tornillos a las columnas: cabeza embutida desde arriba. (Antes el rebaje empezaba en la cara inferior del anillo
        // y no quedaba material bajo la cabeza: el tornillo no apretaba el anillo.)
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * post_c, sy * post_c, 0]) {
            translate([0, 0, ring_z - ring_boss - 1]) cylinder(d = m3_clear, h = 20);
            translate([0, 0, ring_z + ring_t - m3_head_h - 0.3]) cylinder(d = m3_head_d, h = 20);
        }
        // imanes para la matriz superior (cara superior del anillo)
        for (m = top_mag) translate([m[0], m[1], H - D]) magnet_pocket_into(-1);
        // imanes centro-superior y tornillo de seguridad en cada riel
        for (i = [0 : 3]) rotate(90 * i) {
            // en coordenadas de cara u = -x: el imán sigue al del portamatriz (desplazado en la variante A)
            // el anillo se imprime boca abajo: arriba al imprimir = -z del montaje = local +y
            translate([-mag_top_u(side_variants[i]), sk, z_mag[2]]) rotate([-90, 0, 0]) magnet_pocket_into(-1, flat = [0, 1]);
            // agujero holgado, centrado con la cara colgada: cuelga de las uñas `clear` (0.4 mm) por debajo de su posición nominal.
            // (18-nov) Ranura vertical de ±safety_slot: la altura del agujero de la cara viene de medidas en XY del portamatriz y la del
            // riel de medidas en Z (columnas); si la impresora encoge un 0.5 % en XY, quedan ≈0.85 mm desalineados (el agujero solo daba ±0.6)
            // (18-nov, 2) La ranura de ±1 y 4.2 mm dejaba a la cabeza Ø5.5 solo 3.4 mm² de apoyo (redondo: 9.9). Ahora 3.8 mm de ancho y
            // alargada solo hacia abajo (el encogimiento baja el agujero de la cara): 8.6 mm² de apoyo, sin arandela (el usuario no las quiere)
            hull() for (dz = [-safety_slot, 0])
                translate([-safety_u, sk + 1, z_screw - clear + dz]) rotate([90, 0, 0]) cylinder(d = safety_hole_d, h = rail_t + 2);
        }
        // (12-nov) Muescas en los rieles detrás de las ventanas de conectores de cada cara lateral (las mismas medidas, ±conn_margin).
        // El riel apoya en la cara trasera del portamatriz: tapaba los HUB75 y la alimentación de A, y 13 mm de los HUB75 de B, y el
        // enchufe con su cable chocaba con él. Por la muesca el cable sale recto hacia el interior, mida lo que mida el enchufe.
        for (i = [0 : 3]) rotate(90 * i) for (c = conns_of(side_variants[i])) {
            lim = sk - post_s - 12;                  // si la muesca deja menos de 12 mm de riel hasta su extremo, llega hasta el extremo
                                                     // (con 3 quedaba en A un trozo de 8 × 4 × 33 mm que no sujetaba nada y se podía romper)
            u0 = back2u(c[0] + c[2]) - conn_margin;  u1 = back2u(c[0]) + conn_margin;
            a0 = u0 < -lim ? -(sk - post_s - 0.2) : u0;  a1 = u1 > lim ? sk - post_s - 0.2 : u1;   // sin tocar el engrosamiento del poste
            if (back2v(c[1] + c[3]) + conn_margin + zc > ring_z - rail_top_len)
                translate([-a1, sk - rail_t - 0.05, ring_z - rail_top_len - 1]) cube([a1 - a0, rail_t + 1, rail_top_len + 1]);   // u = -x
        }
        // (12-nov) Lo mismo bajo la cara superior: el anillo queda abierto bajo cada ventana de conector del portamatriz superior,
        // en sus dos posiciones (giro de 180°). Antes la cruz del anillo quedaba bajo el conector de alimentación de B.
        for (r = [0, 180]) rotate(r) for (c = conns_of("B"))
            translate([back2u(c[0] + c[2]) - conn_margin, back2v(c[1]) - conn_margin, ring_z - ring_mag_boss - 1])
                cube([c[2] + 2 * conn_margin, c[3] + 2 * conn_margin, ring_t + ring_mag_boss + 2]);
    }
}
// Región en cuña que corta las molduras superiores en inglete a 45°
module miter_zone() {
    linear_extrude(H + 1) polygon([[0, 0], [h2 + 1, h2 + 1], [-h2 - 1, h2 + 1]]);
}

// =============================================================================
//  PROBETA DE CALIBRACIÓN (imprimir primero)
// =============================================================================
module calibration_coupon() {
    difference() {
        cube([84, 30, 8]);
        for (i = [0 : 4]) translate([8 + i * 8, 8, 8 - magnet_skin - magnet_h - 0.2]) cylinder(d = magnet_d + 0.1 + 0.1 * i, h = magnet_h + 0.2);   // imán 5.1 … 5.5 (el diseño usa 5.2)
        // guía M3 (2.4 … 2.7; el diseño usa 2.6). Pasantes: con fondo, el M3×8 tocaba el fondo y cualquier agujero parecía firme
        for (i = [0 : 3]) translate([52 + i * 8, 8, -1]) cylinder(d = m3_tap_d - 0.2 + 0.1 * i, h = 10, $fn = 24);
        for (i = [0 : 3]) translate([8 + i * 8, 22, -1]) cylinder(d = screw_pass_d - 0.2 + 0.1 * i, h = 10);     // paso tornillo original (1.3 … 1.6; el diseño usa screw_pass_d)
        for (i = [0 : 3]) translate([52 + i * 8, 22, -1]) cylinder(d = peg_d + 2 * clear - 0.4 + 0.2 * i, h = 10);   // pasador (4.4 … 5.0; el diseño usa 4.8)
        // (12-nov) esquina cortada junto al hueco más pequeño: los pasos de 0.1 mm no se distinguen a simple vista
        translate([0, 0, -1]) rotate(45) cube([6, 6, 20], center = true);
    }
}

// =============================================================================
//  ENSAMBLAJE
// =============================================================================
module pi_env() {
    color(C_ENV) translate([pi_origin[0], pi_origin[1], bottom_t + pi_boss_h])
        cube([pi_board_STD[0], pi_board_STD[1], pi_height_ENV]);
}
module structure(ex = 0) {
    color(C_PRINT) translate([0, 0, -ex]) bottom_plate();
    for (k = [0 : 3]) rotate(90 * k) color(C_PRINT) translate([ex * 0.5, ex * 0.5, 0]) corner_column();
    color(C_PRINT) translate([0, 0, ex * 1.2]) top_ring();
}
module faces(ex = 0) {
    for (i = [0 : 3]) rotate(90 * i) translate([0, ex * 1.5, 0]) rotate(-90 * i) place_side(i) {
        if (show_panels) translate([0, 0, -ex * 0.5]) panel_ref(side_variants[i]);
        color(C_HOLD) holder(side_variants[i], false);
    }
    translate([0, 0, ex * 2.2]) place_top() {
        if (show_panels) translate([0, 0, -ex * 0.5]) panel_ref(top_variant);
        color(C_HOLD) holder(top_variant, true);
    }
}
module assembly(ex = 0) {
    structure(ex);
    faces(ex);
    if (show_pi) translate([0, 0, -ex]) pi_env();
}

// Accesores para la verificación de interferencias
module side_unit(i) place_side(i) { panel_ref(side_variants[i]); holder(side_variants[i], false); }
module top_unit() place_top() { panel_ref(top_variant); holder(top_variant, true); }
module columns_all() for (k = [0 : 3]) rotate(90 * k) corner_column();

if (view == "assembly")            assembly(0);
else if (view == "exploded")       assembly(explode);
else if (view == "section")        difference() { assembly(0); translate([0, -500, -500]) cube(1000); }
else if (view == "structure_only") structure(0);
else if (view == "part_bottom_plate")  { bottom_plate(); bed_check("placa inferior", [W, W, rail_top_z]); }
else if (view == "part_corner_column") { translate([-sk + post_s, -sk + post_s, -col_z0]) corner_column(); bed_check("columna", [h2 - sk + post_s, h2 - sk + post_s, H - trim_t - col_z0]); }
// (12-nov) Las vistas de impresión deben ser giros, nunca espejos: un espejo imprime la pieza "al revés" (como la mano izquierda
// frente a la derecha) y no hay forma de girarla para que coincida. El anillo se voltea girándolo 180° sobre X (antes mirror).
else if (view == "part_top_ring")      { translate([0, 0, H]) rotate([180, 0, 0]) top_ring(); bed_check("anillo superior", [W, W, H - ring_z + rail_top_len]); }
// Portamatrices: se imprimen con la cara que toca la PCB sobre la cama (plana y precisa; asientos de tornillo hacia arriba).
// Antes se imprimían con el marco abajo y las uñas quedaban 7.4 mm por debajo de la cama. Necesitan soportes bajo el marco.
// (12-nov) Las coordenadas de cara (u, v, w) son de mano izquierda (place_side y place_top tienen determinante −1): holder() y
// screw_template() dibujados tal cual salían en espejo y las ventanas de conectores no coincidían con la matriz real.
// mirror([1, 0, 0]) compensa: la pieza impresa es la del montaje girada (comprobado con blender/verificar_orientacion.py).
else if (view == "part_holder_side_A") { translate([0, 0, -panel_t]) mirror([1, 0, 0]) holder("A", false); bed_check("portamatriz lateral", [2 * edge_out, edge_out - holder_v_lo, D + rail_t + hook_clear + 3 - panel_t]); }
else if (view == "part_holder_side_B") translate([0, 0, -panel_t]) mirror([1, 0, 0]) holder("B", false);
else if (view == "part_holder_top_A")  translate([0, 0, -panel_t]) mirror([1, 0, 0]) holder("A", true);
else if (view == "part_holder_top_B")  { translate([0, 0, -panel_t]) mirror([1, 0, 0]) holder("B", true); bed_check("portamatriz superior", [2 * edge_out, 2 * edge_out, D - panel_t]); }
else if (view == "part_calibration")   calibration_coupon();
else if (view == "part_template_A")    { mirror([1, 0, 0]) screw_template("A"); bed_check("plantilla de prueba", [panel_w, panel_w, edge_t]); }
else if (view == "part_template_B")    mirror([1, 0, 0]) screw_template("B");
