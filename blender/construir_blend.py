"""
Construye cubo_v1.blend a partir de las piezas exportadas de cubo_v1.scad.
Uso:  python3 construir_blend.py      (requiere el módulo bpy o ejecutarlo con:
      blender --background --python construir_blend.py)
La escena queda en milímetros (1 unidad = 1 mm).
"""
import bpy, math, pathlib
from mathutils import Vector

here = pathlib.Path(__file__).resolve().parent
stl = here / "stl"
out_blend = here / "cubo_v1.blend"

# ---------------------------------------------------------------- escena limpia
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.unit_settings.system = 'METRIC'
scene.unit_settings.length_unit = 'MILLIMETERS'
scene.unit_settings.scale_length = 0.001
scene.frame_start, scene.frame_end = 1, 240
scene.render.fps = 24

# ---------------------------------------------------------------- materiales
def mat(name, rgb, rough=0.6, metal=0.0, emit=None, emit_strength=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*rgb, 1)
    b.inputs["Roughness"].default_value = rough
    b.inputs["Metallic"].default_value = metal
    if emit:
        b.inputs["Emission Color"].default_value = (*emit, 1)
        b.inputs["Emission Strength"].default_value = emit_strength
    if alpha < 1:
        b.inputs["Alpha"].default_value = alpha
    m.diffuse_color = (*rgb, alpha)
    return m

M_PRINT = mat("Impreso negro (PETG)", (0.015, 0.015, 0.017), 0.55)
M_HOLD  = mat("Portamatriz (PETG)", (0.05, 0.05, 0.06), 0.6)
M_PANEL = mat("Matriz LED (PCB)", (0.02, 0.05, 0.03), 0.4)
M_PI    = mat("Raspberry Pi 4 (referencia)", (0.1, 0.35, 0.15), 0.5, alpha=0.6)

M_OK    = mat("Tornillo sujeto", (0.0, 0.8, 0.2), 0.4, emit=(0.0, 0.8, 0.2), emit_strength=2.0)
M_FREE  = mat("Tornillo SIN sujetar", (1.0, 0.05, 0.02), 0.4, emit=(1.0, 0.05, 0.02), emit_strength=3.0)

def led_material(name, a, b):
    """Pantalla: rejilla de 64x64 píxeles emisivos con degradado entre dos colores."""
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree; n = nt.nodes; l = nt.links
    n.clear()
    out = n.new("ShaderNodeOutputMaterial")
    em = n.new("ShaderNodeEmission")
    tex = n.new("ShaderNodeTexCoord")
    sep = n.new("ShaderNodeSeparateXYZ")
    # rejilla de píxeles: fract(uv*64) -> distancia al centro -> máscara circular
    mul = n.new("ShaderNodeVectorMath"); mul.operation = 'MULTIPLY'; mul.inputs[1].default_value = (64, 64, 1)
    frac = n.new("ShaderNodeVectorMath"); frac.operation = 'FRACTION'
    sub = n.new("ShaderNodeVectorMath"); sub.operation = 'SUBTRACT'; sub.inputs[1].default_value = (0.5, 0.5, 0)
    ln = n.new("ShaderNodeVectorMath"); ln.operation = 'LENGTH'
    mask = n.new("ShaderNodeMath"); mask.operation = 'LESS_THAN'; mask.inputs[1].default_value = 0.33
    ramp = n.new("ShaderNodeMixRGB"); ramp.inputs[1].default_value = (*a, 1); ramp.inputs[2].default_value = (*b, 1)
    strength = n.new("ShaderNodeMath"); strength.operation = 'MULTIPLY'; strength.inputs[1].default_value = 4.0
    l.new(tex.outputs["UV"], mul.inputs[0]); l.new(mul.outputs[0], frac.inputs[0])
    l.new(frac.outputs[0], sub.inputs[0]); l.new(sub.outputs[0], ln.inputs[0]); l.new(ln.outputs["Value"], mask.inputs[0])
    l.new(tex.outputs["UV"], sep.inputs[0]); l.new(sep.outputs["X"], ramp.inputs[0])
    l.new(ramp.outputs[0], em.inputs["Color"]); l.new(mask.outputs[0], strength.inputs[0])
    l.new(strength.outputs[0], em.inputs["Strength"]); l.new(em.outputs[0], out.inputs["Surface"])
    m.diffuse_color = (*a, 1)
    return m

# ---------------------------------------------------------------- colecciones
def coll(name, parent=None):
    c = bpy.data.collections.new(name)
    (parent or scene.collection).children.link(c)
    return c
C_ROTOR = coll("Cubo (gira)")
C_EST   = coll("Estructura impresa", C_ROTOR)
C_HOLD  = coll("Portamatrices impresos", C_ROTOR)
C_PAN   = coll("Matrices LED (referencia)", C_ROTOR)
C_ELEC  = coll("Electrónica (referencia)", C_ROTOR)
C_TORN  = coll("Tornillos de la PCB (14 por matriz, verdes)", C_ROTOR)
C_ESC   = coll("Cámara y luces")

# ---------------------------------------------------------------- explosión con drivers
scene["Explosion"] = 0.0
ui = scene.id_properties_ui("Explosion")
ui.update(min=0.0, max=1.0, soft_min=0.0, soft_max=1.0, description="0 = montado, 1 = explotado")

def add_explode(obj, offset):
    """Desplaza el objeto 'offset' (mm) multiplicado por la propiedad Explosion de la escena."""
    for i in range(3):
        if abs(offset[i]) < 1e-6:
            continue
        d = obj.driver_add("delta_location", i).driver
        d.type = 'SCRIPTED'
        v = d.variables.new(); v.name = "e"; v.type = 'SINGLE_PROP'
        v.targets[0].id_type = 'SCENE'; v.targets[0].id = scene; v.targets[0].data_path = '["Explosion"]'
        d.expression = f"e*{offset[i]:.3f}"

# ---------------------------------------------------------------- importar piezas
rotor = bpy.data.objects.new("Rotor (eje de giro)", None)
rotor.empty_display_type = 'ARROWS'; rotor.empty_display_size = 60
C_ROTOR.objects.link(rotor)

def load(fname, name, collection, material, explode=(0, 0, 0)):
    bpy.ops.wm.stl_import(filepath=str(stl / f"{fname}.stl"))
    o = bpy.context.selected_objects[0]
    o.name = name; o.data.name = name
    for c in o.users_collection: c.objects.unlink(o)
    collection.objects.link(o)
    o.data.materials.clear(); o.data.materials.append(material)
    o.parent = rotor
    bpy.context.view_layer.objects.active = o
    bpy.ops.object.shade_auto_smooth(angle=math.radians(30)) if hasattr(bpy.ops.object, "shade_auto_smooth") else None
    add_explode(o, explode)
    return o

E = 90  # mm de separación en la vista explotada
load("bottom_plate", "Placa inferior", C_EST, M_PRINT, (0, 0, -E))
load("top_ring", "Anillo superior", C_EST, M_PRINT, (0, 0, 1.3 * E))
for k in range(4):
    a = math.radians(45 + 90 * k)
    load(f"column_{k}", f"Columna de esquina {k + 1}", C_EST, M_PRINT, (0.6 * E * math.cos(a), 0.6 * E * math.sin(a), 0))
variants = ["A", "A", "A", "B"]
for i in range(4):
    a = math.radians(90 + 90 * i)               # cara 0 mira hacia +Y
    d = Vector((math.cos(a), math.sin(a), 0))
    load(f"holder_side_{i}", f"Portamatriz lateral {i + 1} ({variants[i]})", C_HOLD, M_HOLD, tuple(1.2 * E * d))
    load(f"panel_side_{i}", f"Matriz lateral {i + 1} ({variants[i]})", C_PAN, M_PANEL, tuple(1.8 * E * d))
    load(f"screws_ok_{i}", f"Tornillos PCB lateral {i + 1}", C_TORN, M_OK, tuple(1.8 * E * d))
load("holder_top", "Portamatriz superior (B)", C_HOLD, M_HOLD, (0, 0, 2.0 * E))
load("panel_top", "Matriz superior (B)", C_PAN, M_PANEL, (0, 0, 2.6 * E))
load("screws_ok_top", "Tornillos PCB superior", C_TORN, M_OK, (0, 0, 2.6 * E))
load("pi", "Raspberry Pi 4 + adaptador (envolvente)", C_ELEC, M_PI, (0, 0, -E))

# ---------------------------------------------------------------- pantallas (cara luminosa)
W = 202.8; h2 = W / 2; P = 192.0
colors = [((1.0, 0.25, 0.05), (1.0, 0.8, 0.1)), ((0.05, 0.5, 1.0), (0.6, 0.1, 1.0)),
          ((0.1, 1.0, 0.4), (0.0, 0.6, 0.9)), ((1.0, 0.1, 0.4), (1.0, 0.5, 0.2)), ((1, 1, 1), (0.3, 0.6, 1.0))]
z0 = 5.4; zc = z0 + P / 2
def screen(name, loc, rot, mat_, explode):
    bpy.ops.mesh.primitive_plane_add(size=P, location=loc, rotation=rot)
    o = bpy.context.active_object; o.name = name
    for c in o.users_collection: c.objects.unlink(o)
    C_PAN.objects.link(o)
    o.data.materials.append(mat_)
    o.parent = rotor
    add_explode(o, explode)
for i in range(4):
    a = math.radians(90 + 90 * i)
    d = Vector((math.cos(a), math.sin(a), 0))
    loc = d * (h2 + 0.05) + Vector((0, 0, zc))
    screen(f"Pantalla lateral {i + 1}", loc, (math.radians(90), 0, a - math.radians(90)),
           led_material(f"Contenido cara {i + 1}", *colors[i]), tuple(1.8 * E * d))
screen("Pantalla superior", (0, 0, W + 0.05), (0, 0, 0), led_material("Contenido cara superior", *colors[4]), (0, 0, 2.6 * E))

# ---------------------------------------------------------------- giro (animación)
rotor.rotation_euler = (0, 0, 0); rotor.keyframe_insert("rotation_euler", index=2, frame=1)
rotor.rotation_euler = (0, 0, math.radians(360)); rotor.keyframe_insert("rotation_euler", index=2, frame=241)
for fc in rotor.animation_data.action.fcurves if hasattr(rotor.animation_data.action, "fcurves") else []:
    for kp in fc.keyframe_points: kp.interpolation = 'LINEAR'
try:
    for kp in rotor.animation_data.action.layers[0].strips[0].channelbags[0].fcurves[0].keyframe_points:
        kp.interpolation = 'LINEAR'
except Exception:
    pass

# ---------------------------------------------------------------- cámara, luces, mundo
cam_data = bpy.data.cameras.new("Cámara"); cam_data.lens = 50; cam_data.clip_end = 10000
cam = bpy.data.objects.new("Cámara", cam_data); C_ESC.objects.link(cam)
cam.location = (520, -620, 430)
tgt = bpy.data.objects.new("Objetivo cámara", None); tgt.location = (0, 0, 95); C_ESC.objects.link(tgt)
t = cam.constraints.new('TRACK_TO'); t.target = tgt; t.track_axis = 'TRACK_NEGATIVE_Z'; t.up_axis = 'UP_Y'
scene.camera = cam
for name, loc, energy, size in [("Luz principal", (400, -300, 600), 2.5e6, 300), ("Luz de relleno", (-500, -200, 300), 8e5, 400),
                                ("Contraluz", (0, 500, 500), 1.2e6, 300)]:
    ld = bpy.data.lights.new(name, 'AREA'); ld.energy = energy; ld.size = size
    lo = bpy.data.objects.new(name, ld); lo.location = loc; C_ESC.objects.link(lo)
    tr = lo.constraints.new('TRACK_TO'); tr.target = tgt; tr.track_axis = 'TRACK_NEGATIVE_Z'; tr.up_axis = 'UP_Y'
world = bpy.data.worlds.new("Mundo"); scene.world = world; world.use_nodes = True
world.node_tree.nodes["Background"].inputs[0].default_value = (0.55, 0.57, 0.6, 1)
world.node_tree.nodes["Background"].inputs[1].default_value = 0.6

# ---------------------------------------------------------------- vista del visor en mm
for screen_ in bpy.data.screens:
    for area in screen_.areas:
        if area.type == 'VIEW_3D':
            area.spaces[0].clip_end = 10000
            area.spaces[0].overlay.grid_scale = 1

bpy.ops.wm.save_as_mainfile(filepath=str(out_blend))
print("Guardado:", out_blend)
