"""Comprueba que cada imán de cada portamatriz tiene su pareja coaxial en la estructura (placa, columnas, anillo).
Los imanes son huecos cerrados (islas de volumen negativo) en los STL en posición de montaje.
Uso:  blender -b --python blender/verificar_imanes.py
"""
import bpy, bmesh, math, pathlib
from mathutils import Vector

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

def huecos(nombre):
    bpy.ops.wm.stl_import(filepath=str(stl / f"{nombre}.stl"))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.verts.index_update(); bm.faces.ensure_lookup_table()
    seen, res = set(), []
    for v0 in bm.verts:
        if v0.index in seen: continue
        pila, comp = [v0], []
        seen.add(v0.index)
        while pila:
            v = pila.pop(); comp.append(v)
            for e in v.link_edges:
                w = e.other_vert(v)
                if w.index not in seen: seen.add(w.index); pila.append(w)
        ids = {v.index for v in comp}
        vol = sum(f.verts[0].co.dot(f.verts[1].co.cross(f.verts[2].co)) / 6 for f in bm.faces if f.verts[0].index in ids)
        if vol < 0:   # centro de la caja envolvente (en los huecos en "D" el promedio de vértices se desplaza)
            lo = Vector([min(v.co[i] for v in comp) for i in range(3)])
            hi = Vector([max(v.co[i] for v in comp) for i in range(3)])
            res.append((lo + hi) / 2)
    bm.free()
    return res

estructura = []
for n in ["bottom_plate", "top_ring"] + [f"column_{k}" for k in range(4)]:
    estructura += [(n, c) for c in huecos(n)]

caras = []
for i in range(4):
    a = math.radians(90 + 90 * i)
    caras.append((f"holder_side_{i}", Vector((math.cos(a), math.sin(a), 0))))
caras.append(("holder_top", Vector((0, 0, 1))))

total_mal = 0
for nombre, n in caras:
    propios = huecos(nombre)
    print(f"{nombre}: {len(propios)} imanes")
    for c in propios:
        mejor = None
        for sn, s in estructura:
            d = c - s
            sep = d.dot(n)                    # separación a lo largo de la normal de la cara
            lat = (d - n * sep).length        # desalineación en el plano de la cara
            if 0 < sep < 10 and (mejor is None or lat < mejor[0]):
                mejor = (lat, sep, sn)
        if mejor is None or mejor[0] > 0.5:
            total_mal += 1
            print(f"   SIN PAREJA: imán en {tuple(round(x, 1) for x in c)}"
                  + (f" (el más cercano está a {mejor[0]:.1f} mm de su eje, en {mejor[2]})" if mejor else ""))
        elif mejor[0] > 0.05:
            print(f"   descentrado {mejor[0]:.2f} mm: imán en {tuple(round(x, 1) for x in c)} con {mejor[2]}")
print(f"\nImanes sin pareja coaxial: {total_mal}")
