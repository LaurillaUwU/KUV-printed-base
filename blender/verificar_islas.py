"""Detalle de las islas de cada pieza: volumen con signo (negativo = hueco interno cerrado, positivo = sólido separado),
posición y si está dentro de la isla principal. También localiza las aristas no manifold.
Uso:  blender -b --python blender/verificar_islas.py
"""
import bpy, bmesh, pathlib
from mathutils import Vector

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)
piezas = ["bottom_plate", "top_ring", "column_0", "holder_side_0", "holder_side_3", "holder_top"]

def componentes(bm):
    seen, comps = set(), []
    for v0 in bm.verts:
        if v0.index in seen: continue
        pila, c = [v0], []
        seen.add(v0.index)
        while pila:
            v = pila.pop(); c.append(v)
            for e in v.link_edges:
                w = e.other_vert(v)
                if w.index not in seen: seen.add(w.index); pila.append(w)
        comps.append(c)
    return comps

def vol_signo(faces):
    s = 0.0
    for f in faces:
        a, b, c = [v.co for v in f.verts]
        s += a.dot(b.cross(c)) / 6
    return s

for p in piezas:
    bpy.ops.wm.stl_import(filepath=str(stl / f"{p}.stl"))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.verts.index_update(); bm.faces.ensure_lookup_table()
    comps = componentes(bm)
    comps.sort(key=len, reverse=True)
    print(f"\n== {p}: {len(comps)} islas")
    mayor = comps[0]
    bmin = Vector((min(v.co.x for v in mayor), min(v.co.y for v in mayor), min(v.co.z for v in mayor)))
    bmax = Vector((max(v.co.x for v in mayor), max(v.co.y for v in mayor), max(v.co.z for v in mayor)))
    tipos = {"hueco interno": 0, "SÓLIDO SEPARADO": 0}
    for c in comps[1:]:
        ids = {v.index for v in c}
        faces = [f for f in bm.faces if f.verts[0].index in ids]
        vs = vol_signo(faces)
        cen = sum((v.co for v in c), Vector()) / len(c)
        dentro = all(bmin[i] - 1e-3 <= cen[i] <= bmax[i] + 1e-3 for i in range(3))
        k = "hueco interno" if vs < 0 else "SÓLIDO SEPARADO"
        tipos[k] += 1
        if vs >= 0 or not dentro:
            print(f"   isla {len(c)} vértices, volumen {vs:.1f} mm³, centro {tuple(round(x,1) for x in cen)}, dentro de la pieza: {dentro}  <-- REVISAR")
    print("   resumen:", tipos)
    nm = [e for e in bm.edges if len(e.link_faces) != 2]
    if nm:
        print(f"   {len(nm)} aristas no manifold:")
        for e in nm:
            m = (e.verts[0].co + e.verts[1].co) / 2
            print(f"     en ({m.x:.1f}, {m.y:.1f}, {m.z:.1f})  caras que la comparten: {len(e.link_faces)}")
    bm.free()
