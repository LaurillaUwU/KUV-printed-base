"""Interferencias entre piezas de cubo_v1 calculadas en Blender (sin depender de OpenSCAD/CGAL).
Uso:  blender -b --python blender/interferencias_blender.py
Volumen común ~0 = sin interferencia (puede haber contacto de superficie, previsto).
Incluye un control positivo: una pieza contra sí misma debe dar su volumen (si da 0, el chequeo no sirve).
"""
import bpy, bmesh, pathlib

here = pathlib.Path(bpy.data.filepath).parent if bpy.data.filepath else pathlib.Path(__file__).resolve().parent
stl = pathlib.Path(__file__).resolve().parent / "stl"
bpy.ops.wm.read_factory_settings(use_empty=True)

_cache = {}
def obj(name):
    if name not in _cache:
        bpy.ops.wm.stl_import(filepath=str(stl / f"{name}.stl"))
        o = bpy.context.selected_objects[0]; o.name = name
        _cache[name] = o
    return _cache[name]

def union_obj(names):
    objs = [obj(n) for n in names]
    bm = bmesh.new()
    for o in objs:
        bm.from_mesh(o.data)
    me = bpy.data.meshes.new("union"); bm.to_mesh(me); bm.free()
    o = bpy.data.objects.new("union", me); bpy.context.scene.collection.objects.link(o)
    return o

def volume(o):
    bm = bmesh.new(); bm.from_mesh(o.data)
    v = bm.calc_volume(signed=False); bm.free()
    return v

def common(a, b):
    """Volumen de a ∩ b usando booleano exacto sobre una copia de a."""
    work = a.copy(); work.data = a.data.copy(); bpy.context.scene.collection.objects.link(work)
    m = work.modifiers.new("i", 'BOOLEAN'); m.operation = 'INTERSECT'; m.object = b
    m.solver = 'EXACT'; m.use_self = True
    dg = bpy.context.evaluated_depsgraph_get()
    ev = work.evaluated_get(dg)
    me = bpy.data.meshes.new_from_object(ev)
    tmp = bpy.data.objects.new("r", me)
    vol = volume(tmp) if len(me.polygons) else 0.0
    for o in (work, tmp): bpy.data.objects.remove(o)
    bpy.data.meshes.remove(me)
    return vol

cols = lambda: union_obj([f"column_{k}" for k in range(4)])
pairs = {
    "CONTROL: portamatriz 0 contra sí mismo (debe ser > 0)": ("holder_side_0", "holder_side_0"),
    "portamatriz 0 vs columnas": ("holder_side_0", "COLS"),
    "portamatriz 3 (B) vs columnas": ("holder_side_3", "COLS"),
    "portamatriz 0 vs portamatriz 1": ("holder_side_0", "holder_side_1"),
    "matriz 0 vs columnas": ("panel_side_0", "COLS"),
    "matriz 0 vs anillo": ("panel_side_0", "top_ring"),
    "matriz superior vs anillo": ("panel_top", "top_ring"),
    "portamatriz superior vs anillo": ("holder_top", "top_ring"),
    "portamatriz superior vs portamatriz 0": ("holder_top", "holder_side_0"),
    "portamatriz 0 vs placa inferior": ("holder_side_0", "bottom_plate"),
    "portamatriz 0 vs anillo": ("holder_side_0", "top_ring"),
    "matriz 0 vs placa inferior": ("panel_side_0", "bottom_plate"),
    "columnas vs anillo": ("COLS", "top_ring"),
    "columnas vs placa inferior": ("COLS", "bottom_plate"),
    "Pi vs placa inferior": ("pi", "bottom_plate"),
}
for i in range(4):
    j = (i + 1) % 4
    pairs[f"portamatriz {i} vs su matriz"] = (f"holder_side_{i}", f"panel_side_{i}")
    pairs[f"matriz {i} vs matriz {j}"] = (f"panel_side_{i}", f"panel_side_{j}")
    pairs[f"portamatriz {i} vs matriz {j}"] = (f"holder_side_{i}", f"panel_side_{j}")
    pairs[f"matriz {i} vs matriz superior"] = (f"panel_side_{i}", "panel_top")
pairs["portamatriz superior vs su matriz"] = ("holder_top", "panel_top")

def get(n):
    if n == "COLS":
        if "COLS" not in _cache: _cache["COLS"] = cols()
        return _cache["COLS"]
    return obj(n)

for name, (a, b) in pairs.items():
    try:
        v = common(get(a), get(b))
        print(f"{name}: " + ("sin interferencia" if v < 0.5 else f"volumen común = {v:.2f} mm³"))
    except Exception as e:
        print(f"{name}: ERROR {e}")
