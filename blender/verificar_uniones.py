"""Comprueba con rayos verticales cuánto material queda bajo la cabeza de los tornillos M3 columna–anillo y columna–placa.
Uso:  blender -b --python blender/verificar_uniones.py
"""
import bpy, pathlib
from mathutils import Vector
from mathutils.bvhtree import BVHTree

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

def arbol(n):
    bpy.ops.wm.stl_import(filepath=str(stl / f"{n}.stl"))
    o = bpy.context.selected_objects[0]
    return BVHTree.FromPolygons([v.co for v in o.data.vertices], [tuple(p.vertices) for p in o.data.polygons])

def cortes(t, x, y, z0, dz):
    """z de todas las superficies que cruza un rayo vertical que parte de (x, y, z0) en sentido dz (+1/-1)."""
    zs, o, d = [], Vector((x, y, z0)), Vector((0, 0, dz))
    while True:
        h = t.ray_cast(o, d)
        if h[0] is None: return zs
        zs.append(round(h[0].z, 2)); o = h[0] + d * 0.01

post_c = 78.4
for r in (1.0, 2.6):           # dentro del paso M3 (r < 1.7) y bajo la cabeza (1.7 < r < 3.1)
    x, y = post_c + r, post_c
    print(f"Anillo superior, rayo hacia abajo a r = {r} mm del tornillo: superficies en z = {cortes(arbol('top_ring'), x, y, 300, -1)}")
    print(f"Placa inferior,  rayo hacia arriba a r = {r} mm del tornillo: superficies en z = {cortes(arbol('bottom_plate'), x, y, -10, 1)}")
print("Referencia: anillo de z = 182.8 a 185.8 (3 mm); placa de z = 0 a 4. Sin superficies a r = 2.6 => no queda material bajo la cabeza.")
