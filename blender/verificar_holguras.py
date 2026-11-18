"""Problemas de impresión y de montaje que no son choques:
1) Piezas de imprimir/ : paredes más delgadas que 2 pasadas de boquilla (< 0.75 mm) y rendijas internas tan finas (< 0.35 mm)
   que el slicer las rellena o suelda. Se mide lanzando un rayo desde cada cara hacia dentro (grosor) y hacia fuera (rendija).
2) Cubo montado (blender/stl): holgura mínima entre cada par de piezas. 0 = apoyo/contacto; entre 0 y 0.3 mm = demasiado justo
   para piezas impresas (rozan o no entran).
Uso:  blender -b --python blender/verificar_holguras.py
"""
import bpy, bmesh, pathlib, itertools
from mathutils import Vector
from mathutils.bvhtree import BVHTree

aqui = pathlib.Path(__file__).resolve().parent
PARED_MIN, RENDIJA_MIN, JUSTO = 0.75, 0.35, 0.3

def cargar(ruta):
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.wm.stl_import(filepath=str(ruta))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.faces.ensure_lookup_table(); bm.normal_update()
    return bm

def agrupar(puntos, r=3.0):
    grupos = []
    for p, v in puntos:
        for g in grupos:
            if (g[0] - p).length < r:
                g[1] = min(g[1], v); break
        else:
            grupos.append([p, v])
    return grupos

print("=" * 90)
print("1) PIEZAS DE IMPRESIÓN: paredes finas y rendijas internas")
print("=" * 90)
for stl in sorted((aqui.parent / "imprimir").glob("*.stl")):
    bm = cargar(stl)
    bvh = BVHTree.FromBMesh(bm)
    finas, rendijas = [], []
    for f in bm.faces:
        if f.calc_area() < 1e-4: continue
        c, n = f.calc_center_median(), f.normal
        # solo cuentan superficies enfrentadas (normales opuestas); en las esquinas interiores el rayo toca la cara vecina
        h = bvh.ray_cast(c - n * 1e-3, -n)                 # hacia dentro: grosor del material
        if h[0] is not None and n.dot(h[1]) < -0.9:
            t = (h[0] - c).length
            if t < PARED_MIN: finas.append((c.copy(), t))
        h = bvh.ray_cast(c + n * 1e-3, n)                  # hacia fuera: rendija hasta otra superficie de la misma pieza
        if h[0] is not None and n.dot(h[1]) < -0.9:
            g = (h[0] - c).length
            if g < RENDIJA_MIN: rendijas.append((c.copy(), g))
    print(f"\n== {stl.name}")
    for nombre, lista in (("pared fina", finas), ("rendija", rendijas)):
        gs = agrupar(lista)
        print(f"   {nombre}: {len(gs)} zona(s)")
        for p, v in sorted(gs, key=lambda g: g[1])[:12]:
            print(f"      {v:.2f} mm en ({p.x:.1f}, {p.y:.1f}, {p.z:.1f})")
    bm.free()

print()
print("=" * 90)
print("2) CUBO MONTADO: holgura mínima entre piezas (0 = apoyo; 0–0.3 mm = demasiado justo)")
print("=" * 90)
nombres = ["bottom_plate", "top_ring", "column_0", "column_1", "column_2", "column_3",
           "holder_side_0", "holder_side_1", "holder_side_2", "holder_side_3", "holder_top",
           "panel_side_0", "panel_side_1", "panel_side_2", "panel_side_3", "panel_top"]
datos = {}
for n in nombres:
    bm = cargar(aqui / "stl" / f"{n}.stl")
    bm.verts.index_update()
    vs = [v.co.copy() for v in bm.verts]
    # árbol con copia propia de los datos (FromBMesh deja de valer al liberar la malla y daba 0.00 en todo)
    datos[n] = (vs, BVHTree.FromPolygons(vs, [[v.index for v in f.verts] for f in bm.faces]),
                Vector([min(v.co[i] for v in bm.verts) for i in range(3)]), Vector([max(v.co[i] for v in bm.verts) for i in range(3)]))
    bm.free()

def dist(a, b):
    va, tb = datos[a][0], datos[b][1]          # vértices de a contra la superficie de b
    mejor, donde = 1e9, None
    for v in va:
        r = tb.find_nearest(v, 2.0)
        if r[0] is not None and r[3] < mejor: mejor, donde = r[3], v
    return mejor, donde

for a, b in itertools.combinations(nombres, 2):
    if a.startswith("panel") and b.startswith("panel"): continue
    la, ha, lb, hb = datos[a][2], datos[a][3], datos[b][2], datos[b][3]
    if any(la[i] > hb[i] + 2 or lb[i] > ha[i] + 2 for i in range(3)): continue   # cajas lejanas
    d1, p1 = dist(a, b); d2, p2 = dist(b, a)
    d, p = (d1, p1) if d1 <= d2 else (d2, p2)
    if d > 2: continue
    tipo = "apoyo/contacto" if d < 0.01 else ("DEMASIADO JUSTO" if d < JUSTO else "ok")
    print(f"   {a:14s} - {b:14s}: {d:5.2f} mm  {tipo:16s} cerca de ({p.x:.1f}, {p.y:.1f}, {p.z:.1f})")
