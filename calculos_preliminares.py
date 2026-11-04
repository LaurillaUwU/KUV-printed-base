#!/usr/bin/env python3
"""
Cálculos preliminares del cubo LED giratorio.
TODOS los valores de entrada marcados como ESCENARIO son hipótesis para obtener
órdenes de magnitud; sustitúyalos por mediciones reales antes de seleccionar
componentes. Ejecutar:  python3 calculos_preliminares.py
"""
import math

g = 9.81

# ---------------------------------------------------------------- geometría
a = 0.1945          # m, lado exterior del cubo (192 mm + espesor de panel, ver SCAD)
r_face = a / 2      # m, distancia del eje a cada cara lateral

# ---------------------------------------------------------------- masas (ESCENARIOS)
# masa por panel SIN base plástica: desconocida -> tres escenarios
panel_masses = {"bajo": 0.20, "medio": 0.28, "alto": 0.35}   # kg (0.35 = dato CON base)
m_carrier   = 0.12   # kg por portapanel impreso (estimación PETG/ASA, a pesar)
m_frame     = 0.10   # kg por marco de cara impreso
m_posts     = 0.15   # kg, 4 postes de aluminio
m_hub       = 0.25   # kg, placa cubo aluminio + brida
m_elec      = 0.35   # kg, Pi 4 + adaptador HUB75 + convertidores + cables
m_bottom    = 0.10   # kg, tapa inferior giratoria

print("=" * 72)
print("1) MASA E INERCIA DEL ROTOR (escenarios)")
print("=" * 72)
rotor = {}
for k, mp in panel_masses.items():
    m_face = mp + m_carrier + m_frame          # por cara
    m_tot = 5 * m_face + m_posts + m_hub + m_elec + m_bottom
    # Inercia respecto al eje vertical:
    #  cara lateral (placa a distancia a/2, ancho a): m*(a^2/12 + (a/2)^2) = m*a^2/3
    #  cara superior (placa cuadrada a x a centrada): m*a^2/6
    #  postes en esquinas interiores (~r=0.07 m), cubo y electrónica ~ concentrados cerca del eje
    I = 4 * m_face * a**2 / 3 + m_face * a**2 / 6 \
        + m_posts * 0.07**2 + (m_hub + m_bottom) * (0.07**2) / 2 + m_elec * 0.03**2
    rotor[k] = (m_tot, I)
    print(f"  panel {k:5s} ({mp*1000:.0f} g): masa rotor = {m_tot:5.2f} kg  |  I_z = {I:.4f} kg·m²")

print()
print("=" * 72)
print("2) VELOCIDAD, PAR Y FUERZAS CENTRÍFUGAS")
print("=" * 72)
m_tot, I = rotor["alto"]
t_acc = 5.0   # s, rampa de aceleración propuesta (ESCENARIO)
for rpm in (2, 4, 6, 10, 20):
    w = rpm * 2 * math.pi / 60
    alpha = w / t_acc
    T_acc = I * alpha
    a_c = w**2 * (a * math.sqrt(2) / 2)        # en la esquina (radio máximo)
    E = 0.5 * I * w**2
    v_tip = w * a * math.sqrt(2) / 2
    print(f"  {rpm:3d} rpm: T_acel={T_acc*1000:6.2f} mN·m  a_centríf(esquina)={a_c:6.3f} m/s² "
          f"({a_c/g*100:5.2f}% de g)  v_esquina={v_tip:5.3f} m/s  E_cin={E*1000:6.2f} mJ")
print("  -> El par inercial es despreciable: el par del motor lo fijan el rozamiento del")
print("     slip ring, de los rodamientos/retenes y el margen; esos valores deben MEDIRSE")
print("     (llave dinamométrica o balanza + brazo) con los componentes elegidos.")

print()
print("=" * 72)
print("3) CARGA DE DISEÑO LATERAL (persona que empuja/sujeta el cubo)")
print("=" * 72)
F_side = 50.0      # N, ESCENARIO de empuje lateral accidental (a validar en el análisis de riesgos)
h_force = 0.20     # m, brazo desde el rodamiento superior hasta la parte alta del cubo
s_bear = 0.060     # m, separación entre rodamientos (parámetro SCAD bearing_spacing)
M = F_side * h_force
R_top = F_side * (h_force + s_bear) / s_bear
R_bot = F_side * h_force / s_bear
print(f"  Momento en el rodamiento superior: {M:.1f} N·m")
print(f"  Reacción radial rodamiento superior ≈ {R_top:.0f} N ; inferior ≈ {R_bot:.0f} N")
print(f"  Carga axial (peso rotor 'alto'): {m_tot*g:.0f} N")
print("  -> Comparar con la capacidad estática C0 del rodamiento elegido (catálogo).")

for (do, di, mat, sy) in ((12, 0, "acero macizo", 250e6), (12, 8, "tubo acero 12x2", 250e6),
                          (12, 8, "tubo inox 12x2", 200e6)):
    do_m, di_m = do / 1000, di / 1000
    Iw = math.pi * (do_m**4 - di_m**4) / 64
    sigma = M * (do_m / 2) / Iw
    print(f"  Eje {mat:16s} Ø{do}/{di}: σ_flexión = {sigma/1e6:6.1f} MPa  "
          f"(fluencia supuesta {sy/1e6:.0f} MPa -> FS ≈ {sy/sigma:4.1f})")

print()
print("=" * 72)
print("4) ESTABILIDAD AL VUELCO DE LA BASE")
print("=" * 72)
m_base_scen = {"base ligera (impresa)": 2.0, "base con lastre": 5.0}
H_top = 0.12 + 0.03 + a      # m: altura base + hueco + cubo (aprox.)
for name, mb in m_base_scen.items():
    W = (mb + m_tot) * g
    for half in (0.12, 0.15, 0.18):
        F_tip = W * half / H_top
        print(f"  {name:22s} semiancho base {half*1000:3.0f} mm: F_vuelco en la parte alta ≈ {F_tip:5.1f} N")
print("  -> Si F_vuelco no supera con margen la carga lateral de diseño, fijar la base")
print("     (tornillos a mueble/suelo) o añadir lastre. Decisión pendiente del lugar de instalación.")

print()
print("=" * 72)
print("5) ALIMENTACIÓN: ESCENARIOS (consumo REAL de los paneles desconocido)")
print("=" * 72)
P_pi = 7.5      # W, Pi 4 + adaptador (orden de magnitud; medir)
eta = 0.90      # eficiencia supuesta del reductor DC-DC en el rotor
for I_panel in (1.0, 2.0, 4.0):
    P_panels = 5 * 5.0 * I_panel
    P_rot = P_panels + P_pi
    I5 = P_rot / 5.0
    I24 = P_rot / eta / 24.0
    I12 = P_rot / eta / 12.0
    print(f"  {I_panel:.0f} A/panel: P_paneles={P_panels:5.0f} W  P_rotor={P_rot:5.1f} W | "
          f"por slip ring: 5 V→{I5:5.1f} A   12 V→{I12:4.1f} A   24 V→{I24:4.1f} A")
R_loop = 0.10   # ohm, ESCENARIO: resistencia total ida+vuelta (anillos + cables), medir
print(f"  Caída con R_lazo={R_loop} Ω: a 5 V/{(5*5*4+P_pi)/5:.0f} A -> {(5*5*4+P_pi)/5*R_loop:.1f} V (inaceptable);"
      f" a 24 V/{(5*5*4+P_pi)/eta/24:.1f} A -> {(5*5*4+P_pi)/eta/24*R_loop:.2f} V (≈{(5*5*4+P_pi)/eta/24*R_loop/24*100:.1f} %)")

print()
print("=" * 72)
print("6) TRANSMISIÓN")
print("=" * 72)
for ratio in (3, 4, 5):
    for rpm in (4, 6, 10):
        motor_rpm = rpm * ratio
        steps_s = motor_rpm / 60 * 200 * 16
        print(f"  relación 1:{ratio}  cubo {rpm:2d} rpm -> motor {motor_rpm:3d} rpm, {steps_s:6.0f} micropasos/s (1/16)")
