"""Analiza los STL de imprimir/ (ya en orientación de impresión):
 - piezas sueltas y apoyo en la cama;
 - imanes: para cada hueco cerrado, la altura de PAUSA (capas de 0.2 mm) y si el imán cabe por la abertura en ese momento;
 - superficie que necesita soportes (caras que miran hacia abajo a más de 45° y no apoyan en la cama).
Uso:  blender -b --python blender/analizar_impresion.py
"""
import bpy, bmesh, math, pathlib
from collections import defaultdict
from mathutils import Vector

carpeta = pathlib.Path(__file__).resolve().parent.parent / "imprimir"
CAPA = 0.2
IMAN_D, IMAN_H = 5.0, 2.0
bpy.ops.wm.read_factory_settings(use_empty=True)

def islas(bm):
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

def corte(caras, z):
    """Extensión en x e y de la sección de un hueco a la altura z."""
    pts = []
    for f in caras:
        vs = [v.co for v in f.verts]
        for a, b in ((vs[0], vs[1]), (vs[1], vs[2]), (vs[2], vs[0])):
            if (a.z - z) * (b.z - z) < 0:
                t = (z - a.z) / (b.z - a.z); pts.append(a + (b - a) * t)
    if not pts: return 0, 0
    return max(p.x for p in pts) - min(p.x for p in pts), max(p.y for p in pts) - min(p.y for p in pts)

for ruta in sorted(carpeta.glob("*.stl")):
    bpy.ops.wm.stl_import(filepath=str(ruta))
    o = bpy.context.selected_objects[0]
    bm = bmesh.new(); bm.from_mesh(o.data)
    bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-4)
    bm.verts.index_update(); bm.faces.ensure_lookup_table(); bm.normal_update()
    comps = islas(bm)
    cara_de = {}
    for i, c in enumerate(comps):
        for v in c: cara_de[v.index] = i
    caras_isla = defaultdict(list)
    for f in bm.faces: caras_isla[cara_de[f.verts[0].index]].append(f)
    vol = {i: sum(f.verts[0].co.dot(f.verts[1].co.cross(f.verts[2].co)) / 6 for f in fs) for i, fs in caras_isla.items()}
    solidos = [i for i in vol if vol[i] > 0]
    huecos = [i for i in vol if vol[i] < 0]
    zmin = min(v.co.z for v in bm.verts)
    d = o.dimensions
    print(f"\n=== {ruta.name}: {d.x:.1f} x {d.y:.1f} x {d.z:.1f} mm, apoya en z = {zmin:.2f}, "
          f"{'1 pieza' if len(solidos) == 1 else f'{len(solidos)} PIEZAS SUELTAS'}")
    # imanes y pausas
    pausas, malos = defaultdict(int), 0
    for i in huecos:
        fs = caras_isla[i]
        z0 = min(v.co.z for f in fs for v in f.verts); z1 = max(v.co.z for f in fs for v in f.verts)
        if z1 - z0 < 1.0: continue
        de_canto = (z1 - z0) > 3.5                       # imán con el eje horizontal
        alto_iman = IMAN_D if de_canto else IMAN_H
        zp = math.floor((z1 + 1e-6) / CAPA) * CAPA        # última capa completa antes del techo del hueco
        if zp >= z1 - 1e-6: zp -= CAPA
        wx, wy = corte(fs, zp - 0.05)
        cabe = (z0 + alto_iman <= zp + 1e-6) and max(wx, wy) >= IMAN_D and min(wx, wy) >= IMAN_H
        if not cabe: malos += 1
        pausas[(round(zp, 1), "de canto" if de_canto else "plano", cabe)] += 1
    if pausas:
        print("  Pausas para imanes (pausar al TERMINAR la capa de esa altura, meter imanes y continuar):")
        for (zp, tipo, cabe), n in sorted(pausas.items()):
            print(f"    z = {zp:6.1f} mm : {n:2d} imán(es) {tipo}{'' if cabe else '   <-- NO CABE POR LA ABERTURA'}")
    print(f"  Imanes: {sum(pausas.values())}; sin abertura suficiente: {malos}")
    # soportes
    area = sum(f.calc_area() for i in solidos for f in caras_isla[i]
               if f.normal.z < -math.cos(math.radians(45)) and min(v.co.z for v in f.verts) > zmin + 0.3)
    print(f"  Superficie que necesita soporte (voladizo > 45°): {area / 100:.1f} cm²")
    bm.free()
    bpy.data.objects.remove(o)
