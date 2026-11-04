// =============================================================================
//  CUBO LED GIRATORIO — 5 matrices HUB75 64x64 (P3) — MODELO PRELIMINAR v0.2
//  Archivo único, sin bibliotecas externas. Probado con OpenSCAD 2021.01.
//
//  ESTADO: modelo de revisión de proporciones, montaje y disposición.
//          NO es un diseño validado para fabricación ni para uso comercial.
//
//  Sufijos de parámetros:
//    _TBD   dato pendiente de medir/verificar (valor provisional)
//    _FOTO  estimado a partir de la fotografía (±3 mm) -> MEDIR con calibre
//    _ENV   envolvente provisional de un componente comercial NO elegido
//    _STD   dimensión normalizada o publicada -> confirmar con la pieza comprada
//
//  Origen: z = 0 en el borde inferior de los paneles laterales; eje de giro = Z.
//  Unidades: mm. Ver el documento técnico para justificación de cada valor.
// =============================================================================

/* [Vista] */
view = "assembly"; // [assembly, exploded, section, rotor_only, base_only, part_side_frame, part_top_frame, part_carrier_side_A, part_carrier_side_B, part_carrier_top, part_hook, part_bottom_cover, part_bearing_housing, part_motor_mount, part_slipring_bracket, part_electronics_tray, part_base_wall, part_base_lid, part_calibration]
explode = 70;              // separación en la vista explotada
show_commercial = true;    // envolventes de componentes comerciales (azul)
show_keepouts = false;     // zonas de exclusión (rojo translúcido)
side_variants = ["A", "A", "A", "B"];   // variante de matriz en cada cara lateral 0..3
top_variant = "B";                       // 3x A + 2x B en total

/* [Matriz LED] */
panel_w = 192;               // CONFIRMADO: 64 px x paso 3 mm (rotulado P3 / L3) + medida del usuario
panel_h = 192;
panel_pcb_t_TBD = 1.5;       // dato del usuario; medir con calibre
panel_led_h_TBD = 1.0;       // altura de LED 2121 sobre PCB; medir
panel_back_h_TBD = 11;       // componente trasero más alto (caja IDC 2x8 / electrolítico 220 µF); medir
panel_plug_h_TBD = 20;       // caja IDC + clavija de cinta insertada; medir
// Conectores [x, y, ancho, alto] en vista trasera desde la esquina inferior izquierda.
// Orden: HUB75 entrada, HUB75 salida, alimentación 4 polos.
conn_A_FOTO = [[30,140,14,36], [140,140,14,36], [ 95,150,16,22]];  // "P3-64X64-32S-2020"
conn_B_FOTO = [[30,122,14,36], [150,122,14,36], [ 72, 52,16,22]];  // "L3-B 32S 64x64 2121-V2.8"
// Agujeros de fijación de la carcasa original (12 almohadillas visibles en la variante B)
fix_B_FOTO = [[7,7],[96,7],[183,7],[7,79],[96,79],[183,79],[7,99],[96,99],[183,99],[7,183],[96,183],[183,183]];
fix_A_TBD  = fix_B_FOTO;     // variante A: agujeros visibles pero retícula no confirmada
fix_hole_d_TBD = 3.0;

/* [Pila de montaje] */
standoff_h = 13;             // PCB -> portapanel (≥ componente trasero + 1.5)
standoff_d = 7;
carrier_t = 6;               // portapanel: suelo + nervios (incluye inserto de 5.7)
carrier_floor = 2.5;
frame_w = 12;                // perfil del marco de cara
frame_d = 8;
gap_c = 1.5;                 // holgura entre piezas de caras vecinas
fit_clear = 0.25;            // holgura de ajuste — CALIBRAR con la probeta
hook_lift = 6;               // elevación necesaria para desenganchar
hook_w = 16;

/* [Imanes e insertos] */
magnet_d = 5;                // nominal 5 x 2 (usuario)
magnet_h = 2;
magnet_clear_d = 0.20;       // CALIBRAR
magnet_skin = 0.6;           // piel impresa sobre el imán (imán cautivo, pausa de impresión)
insert_hole_d_TBD = 4.0;     // según el inserto M3 comprado
insert_len_TBD = 5.7;
m3_clear = 3.4;

/* [Rotor] */
post_s = 15;                 // tubo cuadrado de aluminio 15x15x1.5 (fabricado) — TBD
hub_plate_t = 5;             // placa cubo de aluminio (fabricada)
hub_z = 18;                  // cara superior de la placa cubo
bottom_cover_t = 3;
vent_slot_w = 4;             // ranura accesible (verificar con ISO 13857)

/* [Eje y transmisión] */
shaft_od_TBD = 12;           // tubo de acero 12x2 (ver cálculo)
shaft_id_TBD = 8;            // paso de cables hacia el rotor
bearing_od_STD = 28;         // 6001 (12x28x8). Sustituir por el rodamiento comprado
bearing_w_STD = 8;
bearing_spacing = 60;
column_od = 44;
rotor_base_gap = 25;         // hueco cubo-base: orden de magnitud para dedos — VERIFICAR norma
flange_d_ENV = 32;           // brida rígida para eje Ø12 — modelo pendiente
flange_h_ENV = 8;
pulley_big_d_ENV = 38.2;     // GT2 60T (diámetro primitivo = 60·2/π)
pulley_small_d_ENV = 12.7;   // GT2 20T
pulley_h_ENV = 14;
belt_center_dist = 70;       // ajustable ±6 con ranuras
nema_s_STD = 42.3;           // NEMA 17
nema_l_ENV = 40;             // longitud según el motor elegido
nema_hole_pitch_STD = 31.0;
slipring_d_ENV = 22;         // slip ring de cápsula — NO elegido
slipring_l_ENV = 40;

/* [Base] */
base_w = 320;                // ver cálculo de vuelco: fijar o lastrar
base_h = 170;
base_wall = 3;
base_plate_t_TBD = 5;        // placa chasis (aluminio 5 mm o tablero) — pendiente
psu_ENV = [160, 98, 38];     // fuente 24 V encapsulada certificada
ctrl_ENV = [70, 50, 25];     // microcontrolador + driver TMC
inlet_ENV = [50, 30, 30];    // entrada IEC con fusible e interruptor
pi_STD = [85.6, 56.5, 20];   // Raspberry Pi 4 (85.6 x 56.5) + altura con adaptador HUB75 (ENV)
buck_ENV = [60, 40, 20];     // reductor 24 V -> 5 V (x3)

/* [Impresora] */
bed_x_TBD = 220;
bed_y_TBD = 220;
bed_z_TBD = 250;

$fn = 48;
eps = 0.01;

// ============================================================ derivados
panel_t      = panel_pcb_t_TBD + panel_led_h_TBD;
cube_w       = panel_w + panel_t;                      // disposición en molinete
stack_d      = panel_t + standoff_h + carrier_t + frame_d;
corner_keep  = stack_d + gap_c;                        // exclusión en cada esquina (local de panel)
inner_half   = cube_w / 2 - stack_d;                   // cara interior de los marcos
carrier_w    = panel_w - 2 * corner_keep;
side_y0      = 2;                                      // portapanel lateral, z inferior
side_y1      = panel_h - 2;                            // portapanel lateral, z superior
top_frame_z  = panel_h - (standoff_h + carrier_t + frame_d);   // cara inferior del marco superior
side_frame_z0 = hub_z - 2;
side_frame_z1 = top_frame_z - 14;                      // borde superior = labio de los ganchos
hook_y       = side_frame_z1;                         // y=0 local del gancho
hook_hole_z  = side_frame_z1 + 8;                     // inserto M3 del gancho en el portapanel
zc           = panel_pcb_t_TBD + standoff_h;           // cara del portapanel hacia la PCB (local)
zb           = zc + carrier_t;                         // cara trasera del portapanel (local)
mag_z_side   = [side_frame_z0 + frame_w / 2, (side_frame_z0 + side_frame_z1) / 2];
mag_x_side   = [corner_keep + 12, panel_w - corner_keep - 12];
hook_x_side  = [corner_keep + 30, panel_w - corner_keep - 30];

base_top_z   = -rotor_base_gap;
lid_t        = 3;
housing_top  = hub_z - hub_plate_t - flange_h_ENV - 2;
bearing_top_z = housing_top - 3 - bearing_w_STD;
housing_bot  = bearing_top_z - bearing_spacing - 3;
pulley_z     = housing_bot - 20;
motor_floor_z = pulley_z + pulley_h_ENV + 2;           // cara de la brida del motor (eje hacia abajo)
shaft_bot_z  = pulley_z - 10;
slipring_z   = shaft_bot_z - 2 - slipring_l_ENV;
floor_top_z  = base_top_z - base_h;

// ============================================================ validaciones
assert(standoff_h >= panel_back_h_TBD + 1.5, "standoff_h no deja holgura sobre los componentes traseros");
assert(carrier_t >= insert_len_TBD, "El portapanel no admite el inserto: aumentar carrier_t");
assert(carrier_w > 60, "Portapanel demasiado estrecho: revisar la pila");
assert(shaft_id_TBD < shaft_od_TBD - 2, "Pared de eje insuficiente");
assert(motor_floor_z + nema_l_ENV <= base_top_z - base_plate_t_TBD, "El motor choca con la placa chasis");
assert(slipring_z > floor_top_z + 5, "El slip ring no cabe en la altura de la base");

function fix_ok(p)     = p[0] >= corner_keep && p[0] <= panel_w - corner_keep;
function fix_ok_top(p) = fix_ok(p) && p[1] >= corner_keep && p[1] <= panel_h - corner_keep;
function fixes_of(v)   = v == "A" ? fix_A_TBD : fix_B_FOTO;
function conns_of(v)   = v == "A" ? conn_A_FOTO : conn_B_FOTO;

fix_side = [for (p = fix_B_FOTO) if (fix_ok(p) && p[1] >= side_y0 + 3 && p[1] <= side_y1 - 3) p];
fix_top  = [for (p = fix_B_FOTO) if (fix_ok_top(p)) p];

echo(str("== Cubo: lado ", cube_w, " mm, alto visible ", panel_h + panel_t, " mm; pila ", stack_d,
         " mm; exclusión de esquina ", corner_keep, " mm; portapanel ", carrier_w, " mm"));
echo(str("== Fijaciones válidas: laterales ", len(fix_side), "/12, superior ", len(fix_top), "/12"));
if (len(fix_top) < 3) echo("ADVERTENCIA: <3 fijaciones válidas en el panel superior (ver documento, decisión D2)");
echo(str("== Diámetro barrido por las esquinas: ", round(cube_w * sqrt(2)), " mm"));
belt_len = 2 * belt_center_dist + PI * (pulley_big_d_ENV + pulley_small_d_ENV) / 2
           + pow(pulley_big_d_ENV - pulley_small_d_ENV, 2) / (4 * belt_center_dist);
echo(str("== Correa GT2 aprox.: ", round(belt_len), " mm -> elegir lazo comercial y ajustar belt_center_dist"));
echo(str("== Altura total aprox.: ", round(panel_h + panel_t - floor_top_z + 13), " mm"));
module bed_check(name, sx, sy, sz) {
    if (sx > bed_x_TBD || sy > bed_y_TBD || sz > bed_z_TBD)
        echo(str("ADVERTENCIA DE IMPRESIÓN: ", name, " ", sx, "x", sy, "x", sz, " excede el volumen -> segmentar"));
    else echo(str("OK impresión: ", name, " ", sx, "x", sy, "x", sz));
}

C_PRINT = [0.13, 0.13, 0.14];
C_METAL = [0.72, 0.74, 0.77];
C_COMM  = [0.25, 0.45, 0.75, 0.85];
C_PCB   = [0.10, 0.22, 0.12];
C_LED   = [0.03, 0.03, 0.03];
C_KEEP  = [1, 0, 0, 0.25];

// =============================================================================
//  UTILIDADES
// =============================================================================
module magnet_pocket() {                      // abierto hacia -z, cerrado por magnet_skin
    translate([0, 0, magnet_skin]) cylinder(d = magnet_d + magnet_clear_d, h = magnet_h + 0.2);
}
module rrect(x, y, h, r = 3) {
    hull() for (i = [r, x - r], j = [r, y - r]) translate([i, j, 0]) cylinder(r = r, h = h);
}

// =============================================================================
//  MATRIZ DE REFERENCIA — local: vista trasera; LEDs en z<0, PCB z∈[0,pcb_t]
// =============================================================================
module panel_reference(v = "A") {
    color(C_LED) translate([0, 0, -panel_led_h_TBD]) cube([panel_w, panel_h, panel_led_h_TBD]);
    color(C_PCB) difference() {
        cube([panel_w, panel_h, panel_pcb_t_TBD]);
        for (p = fixes_of(v)) translate([p[0], p[1], -1]) cylinder(d = fix_hole_d_TBD, h = 5);
    }
    color([0.2, 0.2, 0.2]) for (c = conns_of(v))
        translate([c[0], c[1], panel_pcb_t_TBD]) cube([c[2], c[3], panel_back_h_TBD]);
    if (show_keepouts) color(C_KEEP) for (c = conns_of(v))
        translate([c[0] - 3, c[1] - 3, panel_pcb_t_TBD]) cube([c[2] + 6, c[3] + 6, panel_plug_h_TBD]);
}

// =============================================================================
//  PORTAPANEL — unidad sustituible (matriz fijada en banco al portapanel)
//  Local idéntico al de la matriz. Cara hacia PCB en z=zc, cara trasera en z=zb.
// =============================================================================
module panel_carrier(v = "A", is_top = false) {
    x0 = corner_keep;
    y0 = is_top ? corner_keep : side_y0;
    w  = carrier_w;
    h  = is_top ? panel_h - 2 * corner_keep : side_y1 - side_y0;
    fixes = is_top ? fix_top : fix_side;
    mags = is_top ? [for (x = mag_x_side, y = [corner_keep + 12, panel_h - corner_keep - 12]) [x, y]]
                  : [for (x = mag_x_side, y = mag_z_side) [x, y]];
    hooks = is_top ? [] : [for (x = hook_x_side) [x, hook_hole_z]];
    pins  = is_top ? [[corner_keep + 10, panel_h / 2], [panel_w - corner_keep - 10, panel_h / 2]] : [];
    difference() {
        union() {
            translate([x0, y0, zc]) difference() {
                rrect(w, h, carrier_t, 4);
                translate([5, 5, carrier_floor]) rrect(w - 10, h - 10, carrier_t, 2);
            }
            // nervios en cruz
            translate([x0, y0 + h / 2 - 3, zc]) cube([w, 6, carrier_t]);
            translate([x0 + w / 2 - 3, y0, zc]) cube([6, h, carrier_t]);
            // bosses de imán, inserto de gancho y pasador
            for (p = concat(mags, hooks, pins)) translate([p[0], p[1], zc]) cylinder(d = 11, h = carrier_t);
            // separadores en puntos de fijación válidos
            for (p = fixes) translate([p[0], p[1], panel_pcb_t_TBD]) cylinder(d = standoff_d, h = standoff_h + eps);
            // apoyos de borde (con espuma de 1-2 mm: evitan vibración sin presionar componentes)
            for (i = [x0 + 8, x0 + w - 8], j = [y0 + 8, y0 + h - 8])
                translate([i, j, panel_pcb_t_TBD + 2]) cylinder(d = 8, h = standoff_h - 2 + eps);
        }
        for (c = conns_of(v)) translate([c[0] - 4, c[1] - 4, zc - 1]) cube([c[2] + 8, c[3] + 8, carrier_t + 2]);
        for (i = [0 : 1], j = [0 : 2])     // ventanas de aire en cuadrantes
            translate([x0 + 14 + i * (w / 2), y0 + 14 + j * (h - 28) / 3, zc - 1])
                rrect(w / 2 - 28, (h - 28) / 3 - 14, carrier_t + 2, 3);
        for (p = fixes) translate([p[0], p[1], -1]) cylinder(d = 2.6, h = 40);
        for (p = mags) translate([p[0], p[1], zb + eps]) mirror([0, 0, 1]) magnet_pocket();
        for (p = hooks) translate([p[0], p[1], zb - insert_len_TBD - 0.3]) cylinder(d = insert_hole_d_TBD, h = 10);
        for (p = pins) translate([p[0], p[1], zc - 1]) cylinder(d = 4 + 2 * fit_clear, h = 20);
        // ojal para eslinga de seguridad (cable de acero con terminal)
        translate([x0 + w / 2, y0 + h - 14, zb - 3]) rotate([0, 90, 0]) cylinder(d = 3.2, h = 20, center = true);
    }
}

// =============================================================================
//  GANCHO DESMONTABLE — se atornilla a la cara trasera del portapanel, por encima
//  del marco. Su base apoya en el borde superior del marco (soporta el peso) y la
//  uña cae por detrás del larguero superior (impide la salida hacia fuera).
//  Para retirar: levantar hook_lift mm y tirar. Local: z=0 cara trasera portapanel,
//  y=0 borde superior del marco.
// =============================================================================
module panel_retention_hook() {
    difference() {
        union() {
            translate([-hook_w / 2, 0.5, 0]) cube([hook_w, 14, frame_d + 5]);                 // cuerpo (apoya en el marco)
            translate([-hook_w / 2, -hook_lift - 2, frame_d + 1]) cube([hook_w, hook_lift + 16.5, 3]); // uña
        }
        translate([0, 8, -1]) cylinder(d = m3_clear, h = 30);                 // M3 x 16 a inserto
        translate([0, 8, frame_d + 1.5]) cylinder(d = 6.2, h = 10);           // alojamiento de cabeza
    }
}

// =============================================================================
//  MARCO DE CARA LATERAL — local: x horizontal (0 = cara interior del poste),
//  y = z global - side_frame_z0, z hacia el interior del cubo
// =============================================================================
module side_face_frame() {
    fw = 2 * inner_half;
    fh = side_frame_z1 - side_frame_z0;
    mid = (mag_z_side[1]) - side_frame_z0;
    difference() {
        union() {
            difference() {
                cube([fw, fh, frame_d]);
                translate([frame_w, frame_w, -1]) cube([fw - 2 * frame_w, fh - 2 * frame_w, frame_d + 2]);
            }
            translate([0, mid - frame_w / 2, 0]) cube([fw, frame_w, frame_d]);
            for (p = mag_x_side) translate([p - (cube_w / 2 - inner_half), mid, 0]) cylinder(d = 11, h = frame_d);
        }
        for (x = mag_x_side, y = mag_z_side)
            translate([x - (cube_w / 2 - inner_half), y - side_frame_z0, -eps]) magnet_pocket();
        for (x = [post_s / 2, fw - post_s / 2], y = [10, mid, fh - 10])
            translate([x, y, -1]) cylinder(d = m3_clear, h = frame_d + 2);
        for (x = [fw * 0.35, fw * 0.65]) translate([x - 10, -1, 3]) cube([20, 5, frame_d]);  // pasacables
    }
}
module place_side_frame(i) {
    rotate([0, 0, 90 * i]) translate([-inner_half, inner_half + frame_d, side_frame_z0]) rotate([90, 0, 0]) children();
}

// =============================================================================
//  MARCO SUPERIOR — centrado en el eje, con escotaduras para las uñas de los ganchos
// =============================================================================
module top_face_frame() {
    s = 2 * inner_half;
    difference() {
        union() {
            difference() {
                translate([-s / 2, -s / 2, 0]) cube([s, s, frame_d]);
                translate([-s / 2 + frame_w, -s / 2 + frame_w, -1]) cube([s - 2 * frame_w, s - 2 * frame_w, frame_d + 2]);
            }
            translate([-s / 2, -frame_w / 2, 0]) cube([s, frame_w, frame_d]);
        }
        for (i = [0 : 3]) rotate(90 * i) for (x = hook_x_side)   // escotaduras de ganchos
            translate([-cube_w / 2 + x - hook_w / 2 - 2, s / 2 - frame_d - 6, -1]) cube([hook_w + 4, 20, frame_d + 2]);
        for (x = [-1, 1]) translate([x * (panel_w / 2 - corner_keep - 10), 0, -1]) cylinder(d = 3.9, h = frame_d + 2); // pasador Ø4 a presión
        for (x = mag_x_side, y = [corner_keep + 12, panel_h - corner_keep - 12])
            translate([x - panel_w / 2, y - panel_w / 2, frame_d + eps]) mirror([0, 0, 1]) magnet_pocket();
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * (s / 2 - post_s / 2), sy * (s / 2 - post_s / 2), -1])
            cylinder(d = m3_clear, h = frame_d + 2);
    }
}

// =============================================================================
//  CHASIS GIRATORIO
// =============================================================================
module corner_posts() {
    color(C_METAL) for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (inner_half - post_s / 2) - post_s / 2, sy * (inner_half - post_s / 2) - post_s / 2, hub_z])
            difference() { cube([post_s, post_s, top_frame_z - hub_z]); translate([1.5, 1.5, -1]) cube([post_s - 3, post_s - 3, 500]); }
}
module hub_plate() {
    s = 2 * inner_half - 1;
    color(C_METAL) translate([0, 0, hub_z - hub_plate_t]) difference() {
        translate([-s / 2, -s / 2, 0]) cube([s, s, hub_plate_t]);
        cylinder(d = shaft_id_TBD + 2, h = 30, center = true);
        for (a = [0 : 90 : 270]) rotate(a) translate([12, 0, 0]) cylinder(d = m3_clear + 0.6, h = 30, center = true);
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * (inner_half - post_s / 2), sy * (inner_half - post_s / 2), 0])
            cylinder(d = 4.5, h = 30, center = true);
        for (a = [45 : 90 : 315]) rotate(a) translate([42, 0, 0]) cylinder(d = 16, h = 30, center = true);
    }
}
// Tapa inferior giratoria: cierra el acceso al interior (justifica no dejar el fondo abierto).
module bottom_cover() {
    s = 2 * (inner_half + frame_d) - 1;
    difference() {
        translate([-s / 2, -s / 2, 0]) cube([s, s, bottom_cover_t]);
        cylinder(d = column_od + 6, h = 20, center = true);
        for (i = [-6 : 6]) if (abs(i) > 2)
            translate([i * 10 - vent_slot_w / 2, -s / 2 + 18, -1]) cube([vent_slot_w, s - 36, 10]);
        for (sx = [-1, 1], sy = [-1, 1]) translate([sx * (inner_half - 20), sy * (inner_half - 20), -1]) cylinder(d = m3_clear, h = 10);
    }
}
module electronics_tray() {
    difference() {
        translate([-62, -62, 0]) cube([124, 124, 3]);
        cylinder(d = shaft_id_TBD + 8, h = 10, center = true);
        for (a = [0 : 90 : 270]) rotate(a) translate([12, 0, -1]) cylinder(d = m3_clear, h = 10);
    }
    // Raspberry Pi 4: taladros 58 x 49 (dato publicado de la placa)
    for (x = [0, 58], y = [0, 49]) translate([-57 + 3.5 + x, 3 + 3.5 + y, 3])
        difference() { cylinder(d = 6, h = 5); cylinder(d = 2.2, h = 6); }
    for (x = [-58, 4], y = [-58]) translate([x, y, 3]) difference() { cube([buck_ENV[0] - 6, 4, 6]); }
}
module rotor_electronics_env() {
    color(C_COMM) {
        translate([-57, 3, hub_z + 8]) cube(pi_STD);
        translate([-58, -54, hub_z + 3]) cube([54, buck_ENV[1], buck_ENV[2]]);
        translate([4, -54, hub_z + 3]) cube([54, buck_ENV[1], buck_ENV[2]]);
        translate([36, 4, hub_z + 3]) cube([22, 48, 20]);   // portafusibles / distribución
    }
}

module place_side(i) {     // panel lateral i: LEDs hacia fuera, molinete
    rotate([0, 0, 90 * i]) translate([-cube_w / 2, cube_w / 2, 0]) rotate([90, 0, 0])
        translate([0, 0, panel_led_h_TBD]) children();
}
module place_top() {
    translate([-panel_w / 2, panel_w / 2, panel_h]) rotate([180, 0, 0]) children();
}

module rotating_chassis(ex = 0) {
    for (i = [0 : 3]) {
        rotate([0, 0, 90 * i]) translate([0, ex, 0]) rotate([0, 0, -90 * i]) place_side(i) {
            translate([0, 0, -ex * 0.5]) panel_reference(side_variants[i]);
            color(C_PRINT) panel_carrier(side_variants[i], false);
            color(C_PRINT) for (x = hook_x_side) translate([x, hook_y, zb + ex * 0.2]) panel_retention_hook();
        }
        rotate([0, 0, 90 * i]) translate([0, ex * 0.4, 0]) rotate([0, 0, -90 * i])
            place_side_frame(i) color(C_PRINT) side_face_frame();
    }
    translate([0, 0, ex * 1.3]) place_top() {
        translate([0, 0, -ex * 0.4]) panel_reference(top_variant);
        color(C_PRINT) panel_carrier(top_variant, true);
    }
    translate([0, 0, top_frame_z + ex * 0.6]) color(C_PRINT) top_face_frame();
    corner_posts();
    hub_plate();
    translate([0, 0, hub_z]) color(C_PRINT) electronics_tray();
    if (show_commercial) rotor_electronics_env();
    translate([0, 0, hub_z - hub_plate_t - bottom_cover_t - ex * 0.5]) color(C_PRINT) bottom_cover();
    if (show_keepouts) for (i = [0 : 3]) rotate(90 * i)
        color(C_KEEP) translate([-cube_w / 2, cube_w / 2 - corner_keep, 0]) cube([corner_keep, corner_keep, panel_h]);
}

// =============================================================================
//  EJE, RODAMIENTOS, TRANSMISIÓN Y SLIP RING (estáticos salvo eje/polea)
// =============================================================================
module shaft() {       // tubo de acero: comercial cortado a medida (fabricado)
    color(C_METAL) translate([0, 0, shaft_bot_z]) difference() {
        cylinder(d = shaft_od_TBD, h = hub_z - hub_plate_t - shaft_bot_z);
        translate([0, 0, -1]) cylinder(d = shaft_id_TBD, h = 1000);
    }
}
module commercial_drive_env() {
    color(C_COMM) {
        translate([0, 0, hub_z - hub_plate_t - flange_h_ENV]) difference() {
            cylinder(d = flange_d_ENV, h = flange_h_ENV); translate([0, 0, -1]) cylinder(d = shaft_id_TBD, h = 20); }
        for (z = [bearing_top_z, bearing_top_z - bearing_spacing]) translate([0, 0, z]) difference() {
            cylinder(d = bearing_od_STD, h = bearing_w_STD); translate([0, 0, -1]) cylinder(d = shaft_od_TBD, h = 20); }
        translate([0, 0, pulley_z]) cylinder(d = pulley_big_d_ENV + 2, h = pulley_h_ENV);
        translate([belt_center_dist, 0, pulley_z]) cylinder(d = pulley_small_d_ENV + 2, h = pulley_h_ENV);
        translate([belt_center_dist - nema_s_STD / 2, -nema_s_STD / 2, motor_floor_z]) cube([nema_s_STD, nema_s_STD, nema_l_ENV]);
        translate([0, 0, slipring_z]) cylinder(d = slipring_d_ENV, h = slipring_l_ENV);
    }
    color([0.05, 0.05, 0.05]) translate([0, 0, pulley_z + 4]) hull() {
        cylinder(d = pulley_big_d_ENV + 2.5, h = 6);
        translate([belt_center_dist, 0, 0]) cylinder(d = pulley_small_d_ENV + 2.5, h = 6);
    }
}
// Columna-alojamiento de rodamientos. Recomendado: aluminio torneado. Impreso solo
// para el prototipo, con inspección de holgura de rodamientos (fluencia).
module bearing_housing() {
    flange_z = base_top_z + lid_t;
    difference() {
        union() {
            translate([0, 0, housing_bot]) cylinder(d = column_od, h = housing_top - housing_bot);
            translate([0, 0, flange_z]) cylinder(d = column_od + 44, h = 6);
        }
        translate([0, 0, housing_bot - 1]) cylinder(d = shaft_od_TBD + 2, h = 300);
        for (z = [bearing_top_z, bearing_top_z - bearing_spacing])
            translate([0, 0, z - 0.2]) cylinder(d = bearing_od_STD + fit_clear * 0.4, h = bearing_w_STD + 0.4);
        // ranura para retén en la parte alta (protección de polvo; opcional)
        for (a = [0 : 90 : 270]) rotate(a) translate([column_od / 2 + 12, 0, flange_z - 1]) cylinder(d = 4.5, h = 10);
    }
}
module motor_mount() {      // cuelga bajo la placa chasis; ranuras de tensado de correa
    wall_h = (base_top_z - base_plate_t_TBD) - motor_floor_z;
    s = nema_s_STD + 8;
    difference() {
        union() {
            translate([-s / 2, -s / 2, -5]) cube([s, s, 5]);                             // suelo (brida motor)
            for (y = [-s / 2, s / 2 - 4]) translate([-s / 2, y, -5]) cube([s, 4, wall_h + 5]);
            for (y = [-s / 2 - 12, s / 2]) translate([-s / 2, y, wall_h - 5]) cube([s, 12, 5]);  // orejetas
        }
        cylinder(d = 23, h = 30, center = true);
        for (x = [-1, 1], y = [-1, 1]) translate([x * nema_hole_pitch_STD / 2, y * nema_hole_pitch_STD / 2, -10])
            cylinder(d = m3_clear, h = 20);
        for (x = [-12, 12], y = [-s / 2 - 6, s / 2 + 6]) hull() for (d = [-6, 6])
            translate([x + d, y, wall_h - 10]) cylinder(d = 4.5, h = 20);                // tensado ±6 mm
    }
}
module slipring_bracket() {   // estator del slip ring fijo; el rotor se arrastra con lengüeta flexible
    h = slipring_z - floor_top_z + 10;
    difference() {
        union() {
            cylinder(d = slipring_d_ENV + 10, h = h);
            translate([-32, -8, 0]) cube([64, 16, 5]);
        }
        translate([0, 0, h - 10]) cylinder(d = slipring_d_ENV + 2 * fit_clear, h = 20);
        translate([0, 0, -1]) cylinder(d = 10, h = h + 2);                    // salida de cables del estator
        translate([-1.5 - 5, -50, 3]) cube([3, 100, h]);                     // ranura de cable lateral
        for (x = [-26, 26]) translate([x, 0, -1]) cylinder(d = m3_clear, h = 10);
    }
}

// =============================================================================
//  BASE ESTÁTICA
// =============================================================================
module base_wall_segment(len = base_w) {
    difference() {
        cube([len, base_wall, base_h]);
        for (i = [2 : floor(len / 12) - 3]) translate([i * 12, -1, 20]) cube([vent_slot_w, base_wall + 2, 35]);
        for (x = [12, len - 12], z = [8, base_h - 8]) translate([x, -1, z]) rotate([-90, 0, 0]) cylinder(d = m3_clear, h = 10);
    }
}
module base_lid() {          // tapa superior: impide el acceso a eje, poleas y correa
    difference() {
        translate([-base_w / 2, -base_w / 2, 0]) cube([base_w, base_w, lid_t]);
        cylinder(d = column_od + 1, h = 10, center = true);
        for (a = [0 : 90 : 270]) rotate(a) translate([column_od / 2 + 12, 0, -1]) cylinder(d = 4.5, h = 10);
    }
}
module base_plate() {
    color(C_METAL) translate([0, 0, base_top_z - base_plate_t_TBD]) difference() {
        translate([-base_w / 2 + base_wall, -base_w / 2 + base_wall, 0]) cube([base_w - 2 * base_wall, base_w - 2 * base_wall, base_plate_t_TBD]);
        cylinder(d = column_od + 1, h = 30, center = true);
        translate([-base_w / 2 + 20, -base_w / 2 + 20, -1]) cube([psu_ENV[0], 40, 10]);   // paso de aire/cables
    }
}
module base_structure(ex = 0) {
    color(C_PRINT) for (a = [0 : 90 : 270]) rotate(a) translate([-base_w / 2, -base_w / 2 - ex * 0.3, floor_top_z]) base_wall_segment();
    color(C_PRINT) translate([0, 0, base_top_z + ex * 0.3]) base_lid();
    color(C_PRINT) translate([-base_w / 2, -base_w / 2, floor_top_z - 3]) cube([base_w, base_w, 3]);
    color([0.2, 0.2, 0.2]) for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * (base_w / 2 - 22), sy * (base_w / 2 - 22), floor_top_z - 13]) cylinder(d = 28, h = 10);
    base_plate();
}
module electronics_enclosure_env() {
    color(C_COMM) {
        translate([-base_w / 2 + 12, -base_w / 2 + 12, floor_top_z + 4]) cube(psu_ENV);
        translate([base_w / 2 - 12 - ctrl_ENV[0], -base_w / 2 + 12, floor_top_z + 4]) cube(ctrl_ENV);
        translate([base_w / 2 - inlet_ENV[0] - 20, base_w / 2 - inlet_ENV[1] - base_wall, floor_top_z + 30]) cube(inlet_ENV);
    }
    // barrera interna entre la zona de red y la de baja tensión
    color(C_PRINT) translate([-base_w / 2 + 8, -base_w / 2 + 14 + psu_ENV[1], floor_top_z]) cube([psu_ENV[0] + 10, 2, psu_ENV[2] + 25]);
}

// =============================================================================
//  PROBETA DE CALIBRACIÓN — imprimir primero con el material definitivo
// =============================================================================
module calibration_coupon() {
    difference() {
        cube([90, 34, 8]);
        for (i = [0 : 4]) translate([9 + i * 9, 9, 8 - magnet_h - 0.2]) cylinder(d = magnet_d + 0.05 * i, h = 5);  // +0.00…+0.20
        for (i = [0 : 3]) translate([60 + i * 8, 9, 8 - insert_len_TBD - 0.5]) cylinder(d = insert_hole_d_TBD - 0.2 + 0.1 * i, h = 9);
        for (i = [0 : 4]) translate([9 + i * 9, 25, -1]) cylinder(d = 3.8 + 0.1 * i, h = 10);   // pasador Ø4
        for (i = [0 : 3]) translate([60 + i * 8, 25, -1]) cylinder(d = 3.2 + 0.1 * i, h = 10);  // paso M3
    }
}

// Accesores para verificacion_interferencias.scad (use<> no exporta variables)
function hook_x_side_v() = hook_x_side;
function hook_y_v() = hook_y;
function zb_v() = zb;
module top_frame_placed() translate([0, 0, top_frame_z]) top_face_frame();
module bottom_cover_placed() translate([0, 0, hub_z - hub_plate_t - bottom_cover_t]) bottom_cover();

// =============================================================================
//  ENSAMBLAJE Y SELECTOR
// =============================================================================
module stationary(ex = 0) {
    translate([0, 0, -ex]) base_structure(ex);
    if (show_commercial) translate([0, 0, -ex]) electronics_enclosure_env();
    color(C_PRINT) bearing_housing();
    shaft();
    if (show_commercial) commercial_drive_env();
    color(C_PRINT) translate([belt_center_dist, 0, motor_floor_z]) motor_mount();
    color(C_PRINT) translate([0, 0, floor_top_z - ex * 0.5]) slipring_bracket();
}
module assembly(ex = 0) { translate([0, 0, ex]) rotating_chassis(ex); stationary(ex); }

if (view == "assembly")       assembly(0);
else if (view == "exploded")  assembly(explode);
else if (view == "section")   difference() { assembly(0); translate([0, -1000, -1000]) cube(2000); }
else if (view == "rotor_only") rotating_chassis(0);
else if (view == "base_only")  stationary(0);
else if (view == "part_side_frame")     { side_face_frame(); bed_check("marco lateral", 2 * inner_half, side_frame_z1 - side_frame_z0, frame_d); }
else if (view == "part_top_frame")      { top_face_frame(); bed_check("marco superior", 2 * inner_half, 2 * inner_half, frame_d); }
else if (view == "part_carrier_side_A") { translate([0, 0, -zc]) panel_carrier("A", false); bed_check("portapanel lateral", carrier_w, side_y1 - side_y0, standoff_h + carrier_t); }
else if (view == "part_carrier_side_B") translate([0, 0, -zc]) panel_carrier("B", false);
else if (view == "part_carrier_top")    translate([0, 0, -zc]) panel_carrier("B", true);
else if (view == "part_hook")           rotate([0, 90, 0]) panel_retention_hook();
else if (view == "part_bottom_cover")   bottom_cover();
else if (view == "part_bearing_housing") translate([0, 0, -(base_top_z + lid_t) - 6]) mirror([0, 0, 1]) translate([0, 0, -(base_top_z + lid_t) - 6]) bearing_housing();
else if (view == "part_motor_mount")    mirror([0, 0, 1]) motor_mount();
else if (view == "part_slipring_bracket") slipring_bracket();
else if (view == "part_electronics_tray") electronics_tray();
else if (view == "part_base_wall")      { rotate([90, 0, 0]) base_wall_segment(); bed_check("pared de base", base_w, base_h, base_wall); }
else if (view == "part_base_lid")       { base_lid(); bed_check("tapa de base", base_w, base_w, lid_t); }
else if (view == "part_calibration")    calibration_coupon();
