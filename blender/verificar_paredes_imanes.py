"""Grosor del plástico alrededor de cada hueco de imán: por las dos caras del imán (eje) y por los lados.
Una cara es la piel de contacto (diseño 0.6 mm); la otra debe tener varias capas para que el imán no se salga.
Uso:  blender -b --python blender/verificar_paredes_imanes.py
"""
import bpy, bmesh, pathlib
from mathutils import Vector
from mathutils.bvhtree import BVHTree

stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)
piezas = ["bottom_plate", "top_ring", "column_0", "holder_side_0", "holder_side_3", "holder_top"]
MIN_TAPA, MIN_LADO = 0.8, 1.0     # mm: la cara opuesta a la piel y las paredes laterales deben tener al menos esto

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

def grosor(bvh, origen, d):
    """Desde dentro del hueco: distancia entre la pared del hueco y la siguiente superficie en la dirección d."""
    h1 = bvh.ray_cast(origen, d)
    if h1[0] is None: return None
    h2 = bvh.ray_cast(h1[0] + d * 1e-3, d)
    return None if h2[0] is None else (h2[0] - h1[0]).length

total_mal = 0
for p in piezas:
    bpy.ops.wm.stl_import(filepath=str(stl / f"{p}.stl"))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.verts.ensure_lookup_table(); bm.faces.ensure_lookup_table()
    bvh = BVHTree.FromBMesh(bm)
    comps = sorted(componentes(bm), key=len, reverse=True)[1:]      # la mayor es la pieza; el resto, huecos
    print(f"\n== {p}: {len(comps)} huecos")
    peor_tapa, peor_lado = 99, 99
    for c in comps:
        lo = Vector([min(v.co[i] for v in c) for i in range(3)])
        hi = Vector([max(v.co[i] for v in c) for i in range(3)])
        dim = hi - lo
        eje = min(range(3), key=lambda i: dim[i])                      # el imán es un disco: su eje es la medida más corta
        cen = (lo + hi) / 2
        ejes = [Vector([1 if j == eje else 0 for j in range(3)]), Vector([-1 if j == eje else 0 for j in range(3)])]
        caras = [grosor(bvh, cen, d) for d in ejes]
        lados = []
        for i in range(3):
            if i == eje: continue
            for s in (1, -1):
                lados.append(grosor(bvh, cen, Vector([s if j == i else 0 for j in range(3)])))
        caras_ok = [x for x in caras if x is not None]
        lados_ok = [x for x in lados if x is not None]
        piel, tapa = (min(caras_ok), max(caras_ok)) if len(caras_ok) == 2 else (None, None)
        lado = min(lados_ok) if lados_ok else None
        mal = tapa is None or lado is None or tapa < MIN_TAPA or lado < MIN_LADO
        total_mal += mal
        peor_tapa, peor_lado = min(peor_tapa, tapa or 0), min(peor_lado, lado or 0)
        if mal:
            print(f"   hueco en {tuple(round(x, 1) for x in cen)} eje {'xyz'[eje]}: piel {piel and round(piel, 2)} mm, "
                  f"cara opuesta {tapa and round(tapa, 2)} mm, lado mínimo {lado and round(lado, 2)} mm  <-- REVISAR")
    print(f"   peor cara opuesta {peor_tapa:.2f} mm, peor pared lateral {peor_lado:.2f} mm")
    bm.free()
print(f"\nHuecos con paredes por debajo del mínimo (cara opuesta {MIN_TAPA} mm, lado {MIN_LADO} mm): {total_mal}")
