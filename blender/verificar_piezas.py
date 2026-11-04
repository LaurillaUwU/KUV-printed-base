"""Verificación de las piezas impresas de cubo_v1 (STL en posición de montaje).
Uso:  blender -b --python blender/verificar_piezas.py
Informa, por pieza: islas (partes sin conexión = piezas flotantes o cortadas), aristas no manifold (malla rota),
volumen y caja envolvente. Una pieza correcta tiene 1 isla y 0 aristas no manifold.
"""
import bpy, bmesh, pathlib

base = pathlib.Path(__file__).resolve().parent
stl = base / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

piezas = ["bottom_plate", "top_ring", "column_0", "column_1", "column_2", "column_3",
          "holder_side_0", "holder_side_1", "holder_side_2", "holder_side_3", "holder_top"]
rutas = {p: stl / f"{p}.stl" for p in piezas}
rutas["plantilla_prueba"] = base.parent / "imprimir" / "01_plantilla_prueba.stl"

def islas(bm):
    seen, grupos = set(), []
    for v0 in bm.verts:
        if v0.index in seen:
            continue
        pila, n, vol_aprox = [v0], 0, 0
        seen.add(v0.index)
        while pila:
            v = pila.pop(); n += 1
            for e in v.link_edges:
                w = e.other_vert(v)
                if w.index not in seen:
                    seen.add(w.index); pila.append(w)
        grupos.append(n)
    return sorted(grupos, reverse=True)

print(f"{'pieza':18} {'islas':>6} {'no-manifold':>12} {'volumen cm3':>12}  caja (mm)")
for nombre, ruta in rutas.items():
    if not ruta.exists():
        print(f"{nombre:18} NO EXISTE {ruta}"); continue
    bpy.ops.wm.stl_import(filepath=str(ruta))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.verts.index_update(); bm.edges.index_update()
    g = islas(bm)
    nm = sum(1 for e in bm.edges if len(e.link_faces) != 2)
    vol = bm.calc_volume(signed=False) / 1000
    d = o.dimensions
    extra = "" if len(g) == 1 else f"   <-- tamaños de islas (vértices): {g[:6]}"
    print(f"{nombre:18} {len(g):>6} {nm:>12} {vol:>12.1f}  {d.x:.1f} x {d.y:.1f} x {d.z:.1f}{extra}")
    bm.free()
