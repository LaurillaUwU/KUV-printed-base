"""Diagnóstico de montaje_lateral.py: ¿qué pieza fija bloquea cada movimiento simple del portamatriz lateral 0 (con su matriz)?
Uso:  blender -b --python blender/montaje_diagnostico.py
"""
import bpy, math, pathlib
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

def cargar(n):
    bpy.ops.wm.stl_import(filepath=str(stl / f"{n}.stl"))
    o = bpy.context.selected_objects[0]
    return [v.co.copy() for v in o.data.vertices], [tuple(p.vertices) for p in o.data.polygons]

def bvh(v, p): return BVHTree.FromPolygons(v, p, epsilon=0.0)

nombres = ["bottom_plate", "top_ring"] + [f"column_{k}" for k in range(4)] + \
          [f"holder_side_{i}" for i in (1, 2, 3)] + [f"panel_side_{i}" for i in (1, 2, 3)]
fijas = {n: bvh(*cargar(n)) for n in nombres}
partes_mov = {"portamatriz": cargar("holder_side_0"), "matriz": cargar("panel_side_0")}
HOLG = Vector((0, 0.15, 0))

def quien(M, que=None):
    bloquea = set()
    for pn, (v, p) in partes_mov.items():
        if que and pn != que: continue
        vs = [(M @ x) + HOLG for x in v]
        t = bvh(vs, p)
        for fn, F in fijas.items():
            if t.overlap(F):
                bloquea.add(f"{pn} contra {fn}")
    return sorted(bloquea)

def giro(yp, zp, ang):
    T = Matrix.Translation(Vector((0, yp, zp)))
    return T @ Matrix.Rotation(math.radians(ang), 4, 'X') @ T.inverted()

print("Traslaciones de 1 mm (cara 0 mira a +Y; +Z = arriba):")
for nombre, d in [("hacia fuera (+Y)", (0, 1, 0)), ("hacia dentro (-Y)", (0, -1, 0)), ("arriba (+Z)", (0, 0, 1)), ("abajo (-Z)", (0, 0, -1))]:
    r = quien(Matrix.Translation(Vector(d)))
    print(f"  {nombre:20}: {'libre' if not r else 'BLOQUEA ' + '; '.join(r)}")
print("Traslación hacia fuera 0.3 mm, por si fuera solo contacto:")
r = quien(Matrix.Translation(Vector((0, 0.3, 0)))); print("  ", "libre" if not r else "; ".join(r))

print("\nGiro de 2.5° hacia fuera con el eje en distintos puntos (y, z):")
for yp in (80.4, 90, 101.4):
    for zp in (10, 22, 60, 101.4):
        r = quien(giro(yp, zp, -2.5))
        print(f"  eje y={yp:6}, z={zp:6}: {'libre' if not r else '; '.join(r)}")
