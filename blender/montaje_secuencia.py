"""Secuencia de armado: cada paso baja una pieza en vertical desde arriba hasta su posición y comprueba que no choca en el camino.
  1) cada portamatriz lateral (con su matriz) sobre placa inferior + columnas (+ las otras caras ya puestas)
  2) anillo superior sobre columnas + 4 caras
  3) portamatriz superior (con su matriz) sobre el anillo
Uso:  blender -b --python blender/montaje_secuencia.py
"""
import bpy, pathlib
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)
cache = {}
def cargar(n):
    if n not in cache:
        bpy.ops.wm.stl_import(filepath=str(stl / f"{n}.stl"))
        o = bpy.context.selected_objects[0]
        cache[n] = ([v.co.copy() for v in o.data.vertices], [tuple(p.vertices) for p in o.data.polygons])
    return cache[n]
def unir(ns):
    V, P = [], []
    for n in ns:
        v, p = cargar(n); off = len(V); V += v; P += [tuple(i + off for i in q) for q in p]
    return V, P
def bvh(v, p): return BVHTree.FromPolygons(v, p, epsilon=0.0)

columnas = [f"column_{k}" for k in range(4)]
caras = [f"holder_side_{i}" for i in range(4)] + [f"panel_side_{i}" for i in range(4)]
PASOS = [250, 200, 150, 100, 60, 40, 25, 15, 10, 6, 4, 3, 2, 1, 0.5, 0.2, 0.0]

def bajar(titulo, mov, fijas, holg=Vector((0, 0, 0.1)), escala_xy=1.0):
    """Baja 'mov' desde 250 mm más arriba hasta su sitio; informa del primer choque.
    'holg' (desplazamiento) y 'escala_xy' separan los contactos planos del montaje (si no, cuentan como choque)."""
    v, p = unir(mov)
    F = {n: bvh(*cargar(n)) for n in fijas}
    for d in PASOS:
        T = bvh([Vector((x.x * escala_xy, x.y * escala_xy, x.z)) + Vector((0, 0, d)) + holg for x in v], p)
        quien = [n for n, f in F.items() if T.overlap(f)]
        if quien:
            print(f"  {titulo}: CHOCA a {d} mm por encima de su posición final, con: {', '.join(quien)}"); return False
    print(f"  {titulo}: camino libre"); return True

print("1) Portamatrices laterales (con su matriz), bajando en vertical; fijas: placa + columnas + las otras 3 caras")
# lateral i: el eje vertical de bajada es +Z siempre; HOLG hacia arriba separa los contactos planos del montaje
import math
for i in range(4):
    otras = [n for n in caras if not n.endswith(f"_{i}")]
    a = math.radians(90 + 90 * i)                      # la cara 0 mira a +Y; cada cara siguiente gira 90°
    fuera = Vector((math.cos(a) * 0.15, math.sin(a) * 0.15, 0.1))
    bajar(f"cara {i}", [f"holder_side_{i}", f"panel_side_{i}"], ["bottom_plate"] + columnas + otras, holg=fuera)
print("2) Anillo superior, bajando sobre columnas + 4 caras")
bajar("anillo", ["top_ring"], ["bottom_plate"] + columnas + caras, escala_xy=0.9988)
print("3) Matriz superior (con portamatriz), bajando sobre todo lo anterior")
bajar("cara superior", ["holder_top", "panel_top"], ["bottom_plate", "top_ring"] + columnas + caras)
