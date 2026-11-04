"""¿Se puede instalar/retirar un portamatriz lateral (con su matriz) una vez armada la estructura?
Busca un movimiento: inclinar hacia fuera (giro alrededor de un eje horizontal paralelo a la cara) y luego alejarlo.
Prueba una rejilla de ejes de giro. Fijo: placa inferior, columnas, anillo superior y las otras 3 caras laterales (peor caso).
La matriz superior se instala al final, así que no se incluye.
Uso:  blender -b --python blender/montaje_lateral.py
"""
import bpy, math, pathlib
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

def cargar(n):
    bpy.ops.wm.stl_import(filepath=str(stl / f"{n}.stl"))
    o = bpy.context.selected_objects[0]
    me = o.data
    return [v.co.copy() for v in me.vertices], [tuple(p.vertices) for p in me.polygons]

def bvh(verts, polys):
    return BVHTree.FromPolygons(verts, polys, epsilon=0.0)

def unir(partes):
    V, P = [], []
    for v, p in partes:
        off = len(V); V += v; P += [tuple(i + off for i in q) for q in p]
    return V, P

fijas = ["bottom_plate", "top_ring"] + [f"column_{k}" for k in range(4)] + \
        [f"holder_side_{i}" for i in (1, 2, 3)] + [f"panel_side_{i}" for i in (1, 2, 3)]
F = bvh(*unir([cargar(n) for n in fijas]))
mov_v, mov_p = unir([cargar("holder_side_0"), cargar("panel_side_0")])

# cara 0 mira hacia +Y; "fuera" = +Y; "arriba" = +Z. Holgura mínima para no contar los contactos planos del montaje.
HOLG = Vector((0, 0.15, 0))

def choca(M):
    vs = [(M @ v) + HOLG for v in mov_v]
    return bool(bvh(vs, mov_p).overlap(F))

def giro(yp, zp, ang):
    """Giro de 'ang' grados alrededor del eje X que pasa por (y=yp, z=zp); ang < 0 = parte superior hacia fuera (+Y)."""
    T = Matrix.Translation(Vector((0, yp, zp)))
    return T @ Matrix.Rotation(math.radians(ang), 4, 'X') @ T.inverted()

print("Base: ¿choca en la posición de montaje (0°, con 0.15 mm de holgura)?", choca(Matrix.Identity(4)))

mejores = []
for yp in [x * 3 for x in range(24, 35)]:               # y = 72 … 102
    for zp in range(0, 61, 6):                            # z = 0 … 60
        angulo_ok = 0
        for a in [i * 2.5 for i in range(1, 25)]:         # 2.5° … 60° (hacia fuera)
            if choca(giro(yp, zp, -a)):
                break
            angulo_ok = a
        mejores.append((angulo_ok, yp, zp))
mejores.sort(reverse=True)
print("Mejores ejes de giro (ángulo máximo libre desde el montaje), eje en (y, z):")
for a, yp, zp in mejores[:8]:
    print(f"   {a:5.1f}°   eje en y={yp}, z={zp}")

# desde el mejor eje: ¿una vez inclinado puede alejarse hacia fuera/arriba sin chocar?
if mejores[0][0] > 0:
    a, yp, zp = mejores[0]
    M0 = giro(yp, zp, -a)
    libre = True
    for d in range(0, 160, 5):
        if choca(Matrix.Translation(Vector((0, d, d * 0.3))) @ M0):
            libre = False; print(f"   al alejarse choca a {d} mm"); break
    print(f"Con el mejor eje ({a}° en y={yp}, z={zp}): ¿se puede alejar sin chocar? {'SÍ' if libre else 'NO'}")
else:
    print("Ningún eje permite inclinar la pieza sin chocar: no se puede instalar/retirar así.")
print(f"Éxito de inclinación ≥ 25° en algún eje: {mejores[0][0] >= 25}")
