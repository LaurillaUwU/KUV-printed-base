#!/usr/bin/env python3
"""
Cálculos de retención del cubo v1: imanes, tornillos originales de la PCB, tornillo M3 de seguridad, uñas y tornillos
columna–estructura. Lee la geometría de los STL exportados (blender/stl) para masas y centros de gravedad.
Ejecutar:  python calculos_retencion.py      (requiere numpy y scipy)

Los valores marcados ESCENARIO o SUPUESTO son hipótesis razonables, no medidas: el resultado es un orden de magnitud
y un factor de seguridad (FS) indicativo. Sustituirlos por datos reales cuando se tengan.
"""
import math, pathlib, re
import numpy as np
from scipy.special import ellipk, ellipe

g = 9.81
mu0 = 4e-7 * math.pi
aqui = pathlib.Path(__file__).resolve().parent
stl_dir = aqui / "blender" / "stl"

# ------------------------------------------------------------------ geometría (de cubo_v1.scad)
h2 = 101.4e-3          # m, distancia del eje a la cara exterior (LED)
zc = 101.4e-3          # m, altura del centro de la cara lateral
D = 17e-3              # m, profundidad matriz -> cara trasera del portamatriz (= plano de los rieles)
z_hook = 22e-3         # m, apoyo de la uña sobre el riel inferior (rail_top_z): eje de vuelco de la cara
z_mag = [12e-3, 101.4e-3, 174.8e-3]   # filas de imanes (abajo, centro, arriba)
z_m3 = 164.8e-3        # tornillo M3 de seguridad
z_top_edge = 197.4e-3  # borde superior de la matriz
n_pcb_screws = 14

# ------------------------------------------------------------------ datos y escenarios
m_panel = 0.35         # kg, ESCENARIO: peor caso de calculos_preliminares.py (dato con base original; sin ella pesa menos)
rho_petg = 1.27e3      # kg/m³ (PETG). La masa sale del volumen del STL = relleno 100 % (cota superior)
rpm_max = 20           # ESCENARIO: tope de calculos_preliminares.py
Br = {"N35": 1.17, "N52": 1.43}       # T, remanencia típica. SUPUESTO: grado de los imanes desconocido -> se usa N35
mag_d, mag_h = 5e-3, 2e-3
# separación imán–imán: piel de 0.6 mm en cada pieza (1.2 mm); el bolsillo es 0.2 mm más hondo que el imán
gaps = {"nominal 1.2 mm": 1.2e-3, "imanes al fondo del bolsillo 1.6 mm": 1.6e-3, "pieza mal asentada 2.0 mm": 2.0e-3}

# ------------------------------------------------------------------ fuerza entre dos imanes cilíndricos coaxiales
def f_espiras(a, b, z, I1, I2):
    """Fuerza axial entre dos espiras coaxiales de radios a, b separadas z (atractiva > 0 con corrientes del mismo sentido)."""
    k2 = 4 * a * b / ((a + b) ** 2 + z ** 2)
    return mu0 * I1 * I2 * z / math.sqrt((a + b) ** 2 + z ** 2) * (
        -ellipk(k2) + (a * a + b * b + z * z) / ((a - b) ** 2 + z * z) * ellipe(k2))

def f_imanes(gap, br, d=mag_d, h=mag_h, n=60):
    """Cada imán = solenoide de corriente superficial K = Br/mu0. Suma la fuerza entre todas las parejas de espiras."""
    K = br / mu0
    dz = h / n
    zs = (np.arange(n) + 0.5) * dz
    F = 0.0
    for z1 in zs:
        for z2 in zs:
            F += f_espiras(d / 2, d / 2, (h + gap + z2) - z1, K * dz, K * dz)
    return F

def f_dipolo(dist, br, d=mag_d, h=mag_h):
    m = br / mu0 * math.pi * (d / 2) ** 2 * h
    return 3 * mu0 * m * m / (2 * math.pi * dist ** 4)

# ------------------------------------------------------------------ masa y centro de gravedad desde el STL (ASCII)
def stl_masa_cdg(nombre):
    txt = (stl_dir / f"{nombre}.stl").read_text(errors="ignore")
    v = np.array(re.findall(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", txt), dtype=float).reshape(-1, 3, 3) / 1000
    a, b, c = v[:, 0], v[:, 1], v[:, 2]
    dv = np.einsum("ij,ij->i", a, np.cross(b, c)) / 6
    vol = dv.sum()
    cdg = ((a + b + c) / 4 * dv[:, None]).sum(axis=0) / vol
    return abs(vol), cdg

def fs(cap, dem): return cap / dem if dem > 0 else float("inf")
def linea(txt, cap, dem, unidad):
    s = fs(cap, dem)
    nota = "OK" if s >= 2 else ("JUSTO" if s >= 1 else "NO AGUANTA")
    print(f"  {txt:58s} demanda {dem:8.3f} {unidad} | capacidad {cap:8.3f} {unidad} | FS {s:6.1f}  {nota}")
    return s

print("=" * 110)
print("0) VALIDACIÓN DEL MODELO DE IMANES (a gran distancia debe coincidir con la aproximación de dipolos)")
print("=" * 110)
for dist in (10e-3, 20e-3):
    F_m = f_imanes(dist - mag_h, Br["N35"])
    print(f"  centros a {dist*1000:.0f} mm: modelo de espiras {F_m*1000:.3f} mN | dipolos {f_dipolo(dist, Br['N35'])*1000:.3f} mN")
print(f"  En contacto (0 mm): {f_imanes(1e-6, Br['N35']):.2f} N con N35. Referencia de catálogo 5x2 mm sobre acero: ~5–7 N (N35–N45).")

print()
print("=" * 110)
print("1) FUERZA DE UNA PAREJA DE IMANES 5x2 mm, imán contra imán, según la separación")
print("=" * 110)
F_par = {}
for nombre, gp in gaps.items():
    F_par[nombre] = {gr: f_imanes(gp, br) for gr, br in Br.items()}
    print(f"  {nombre:38s}: N35 {F_par[nombre]['N35']:5.2f} N   N52 {F_par[nombre]['N52']:5.2f} N")
print("  (Desalineación lateral y temperatura alta reducen algo más la fuerza; los imanes N soportan hasta ~80 °C.)")

# ------------------------------------------------------------------ caras
V_h, c_h = stl_masa_cdg("holder_side_0")        # cara 0 mira a +Y: w = h2 - y
V_t, c_t = stl_masa_cdg("holder_top")
m_h, m_t = V_h * rho_petg, V_t * rho_petg
w_h = h2 - c_h[1]
z_h = c_h[2]
w_p = 2.0e-3                                      # SUPUESTO: cdg de la matriz (LED + PCB + componentes)
m_face = m_panel + m_h
w_cg = (m_panel * w_p + m_h * w_h) / m_face
z_cg = (m_panel * zc + m_h * z_h) / m_face
e = D - w_cg                                      # el cdg queda por fuera del plano de los rieles: tiende a volcar la cara
W = m_face * g
print()
print("=" * 110)
print("2) CARA LATERAL: masas y centro de gravedad (portamatriz leído del STL, relleno 100 %)")
print("=" * 110)
print(f"  portamatriz lateral {V_h*1e6:.1f} cm³ -> {m_h*1000:.0f} g (cdg a {w_h*1000:.1f} mm de la cara LED);  matriz {m_panel*1000:.0f} g (ESCENARIO)")
print(f"  cara completa {m_face*1000:.0f} g, peso {W:.2f} N; cdg a {w_cg*1000:.1f} mm de la cara LED y {z_cg*1000:.0f} mm de altura")
print(f"  brazo de vuelco hacia fuera respecto al riel: {e*1000:.1f} mm; eje de vuelco en la uña (z = {z_hook*1000:.0f} mm)")

def momento_imanes(F, filas):
    """Momento resistente de los imanes por encima del eje de vuelco: filas = {z: número de imanes}."""
    return sum(n * F * (z - z_hook) for z, n in filas.items() if z > z_hook)

# A y B: 8 imanes (en A el superior central se desplazó a u = 20 para salir de la ventana del conector; misma altura)
filas = {"A y B (8 imanes)": {z_mag[1]: 2, z_mag[2]: 3}}
w = rpm_max * 2 * math.pi / 60
F_c = m_face * w * w * (h2 - w_cg)
cases = {
    "peso (vuelco estático, giro parado)": W * e,
    f"peso + centrífuga a {rpm_max} rpm": W * e + F_c * (z_cg - z_hook),
    "cubo tumbado con esta cara hacia abajo (1 g hacia fuera)": W * (z_cg - z_hook),
    "golpe al transportarlo tumbado (2 g hacia fuera)": 2 * W * (z_cg - z_hook),
    "alguien tira del borde superior con 20 N (ESCENARIO)": 20 * (z_top_edge - z_hook),
}
F_m3_cap = 200.0     # N, SUPUESTO conservador: arranque de inserto térmico M3 en PETG (ensayos típicos 500–900 N)
print()
print("=" * 110)
print("3) CARA LATERAL: ¿se despega la parte alta? (momentos respecto a la uña, N·m)")
print("=" * 110)
Fn = F_par["imanes al fondo del bolsillo 1.6 mm"]["N35"]     # caso de diseño: N35 y holgura de bolsillo
print(f"  Imanes de diseño: N35 a 1.6 mm = {Fn:.2f} N por pareja. M3: {F_m3_cap:.0f} N (inserto) a {(z_m3 - z_hook)*1000:.0f} mm del eje.")
resumen = []
for var, fl in filas.items():
    M_mag = momento_imanes(Fn, fl)
    M_m3 = F_m3_cap * (z_m3 - z_hook)
    print(f"  Variante {var}")
    M_mag52 = momento_imanes(F_par["imanes al fondo del bolsillo 1.6 mm"]["N52"], fl)
    for nombre, M in cases.items():
        s1 = linea(f"  solo imanes: {nombre}", M_mag, M, "N·m")
        s2 = linea(f"  imanes + M3: {nombre}", M_mag + M_m3, M, "N·m")
        resumen.append((nombre, s1, fs(M_mag52, M), s2))

print()
print("=" * 110)
print("4) CARA SUPERIOR: con el cubo boca abajo, ¿la sujetan los 8 imanes?")
print("=" * 110)
m_top = m_panel + m_t
print(f"  portamatriz superior {m_t*1000:.0f} g + matriz {m_panel*1000:.0f} g = {m_top*1000:.0f} g; peso {m_top*g:.2f} N")
for nombre, gp in gaps.items():
    linea(f"  8 imanes N35, {nombre}", 8 * F_par[nombre]["N35"], m_top * g, "N")
print("  En uso normal la sujeta la gravedad y los 2 pasadores impiden que deslice; la centrífuga es radial (en su plano).")

print()
print("=" * 110)
print("5) TORNILLOS ORIGINALES DE LA PCB (14 por matriz, Ø1 mm, 5 mm de largo)")
print("=" * 110)
As = math.pi / 4 * (1.0 - 0.9382 * 0.25) ** 2 * 1e-6          # área resistente M1 (paso 0.25)
F_rot = As * 400e6                                              # SUPUESTO acero clase 4.8 (400 MPa)
dem_trac = 2 * m_panel * g / n_pcb_screws                        # 2 g hacia fuera, repartido entre los 14
dem_cort = m_panel * g / n_pcb_screws
print(f"  Tracción por tornillo con 2 g hacia fuera: {dem_trac:.2f} N; cortante por el peso: {dem_cort:.2f} N")
linea("rotura del tornillo (acero 4.8, área resistente M1)", F_rot, dem_trac, "N")
L_eng = 5.0 - 3.0 - 0.0                                          # largo - agarre (3 mm supuesto) = rosca bajo el aro
for L, txt in ((L_eng, f"rosca en PCB+máscara, {L_eng:.1f} mm (agarre de 3 mm)"), (0.5, "rosca solo en la máscara LED, 0.5 mm (peor caso)")):
    F_po = 0.5 * 20e6 * math.pi * 0.9e-3 * L * 1e-3              # SUPUESTO: plástico τ = 20 MPa, 50 % de filete efectivo
    linea(f"arranque de la rosca: {txt}", F_po, dem_trac, "N")
print("  Riesgo real: APRETAR DEMASIADO. La cabeza de 2 mm apoya en un borde de 0.25 mm alrededor del agujero de 1.5 mm.")
for hole in (1.5, 1.3):
    A = math.pi / 4 * (2.0 ** 2 - hole ** 2) * 1e-6
    F_aplast = A * 50e6                                           # PETG: compresión ~50 MPa
    T = 0.2 * F_aplast * 1.0e-3                                   # T = K·F·d, K = 0.2
    print(f"    agujero {hole} mm: la cabeza se hunde con {F_aplast:5.0f} N de apriete = par de {T*1000:4.1f} mN·m "
          f"(un destornillador de precisión apretado a fondo da 20–50 mN·m)")

print()
print("=" * 110)
print("6) UÑAS (2 por cara lateral): flexión de la placa que apoya en el riel")
print("=" * 110)
b, t, L = 16e-3, 3e-3, 4.4e-3                    # ancho, espesor, voladizo hasta el borde del riel
for fac, txt in ((1, "peso"), (3, "golpe 3 g")):
    F_uña = fac * W / 2
    sigma = 6 * F_uña * L / (b * t * t)
    linea(f"uña, {txt} (resistencia entre capas PETG ~20 MPa)", 20e6, sigma, "Pa")

print()
print("=" * 110)
print("7) TORNILLOS M3 COLUMNA–PLACA y COLUMNA–ANILLO (4 + 4)")
print("=" * 110)
V_r, _ = stl_masa_cdg("top_ring")
m_arriba = V_r * rho_petg + m_top
dem = 2 * m_arriba * g / 4
linea("cubo boca abajo, 2 g: anillo + cara superior colgando de 4 M3", 200.0, dem, "N")
for t_pl, txt in ((1.0, "placa ANTES de la corrección (1 mm bajo la cabeza)"), (2.7, "placa/anillo AHORA (2.7 mm bajo la cabeza)")):
    F_punz = math.pi * 5.5e-3 * t_pl * 1e-3 * 20e6              # punzonado del plástico bajo cabeza Ø5.5 (τ ~20 MPa)
    T_max = 0.2 * F_punz * 3e-3
    print(f"  {txt}: la cabeza atraviesa el plástico con {F_punz:5.0f} N = par de {T_max:4.2f} N·m")
print("  -> Apretar los M3 a ≤ 0.3 N·m (a mano con la llave Allen corta, sin forzar). El anillo antes de la corrección")
print("     NO tenía material bajo la cabeza (0 mm): el tornillo no apretaba el anillo contra la columna.")

print()
print("=" * 110)
print("RESUMEN: caras laterales A y B — factor de seguridad (FS ≥ 2 = OK)")
print("=" * 110)
print(f"  {'caso':62s} {'imanes N35':>10s} {'imanes N52':>10s} {'imanes+M3':>10s}")
for nombre, s1, s52, s2 in resumen:
    print(f"  {nombre:62s} {s1:10.1f} {s52:10.1f} {s2:10.1f}")
