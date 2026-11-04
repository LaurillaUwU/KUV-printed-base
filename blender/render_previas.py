import bpy, pathlib, sys
here = pathlib.Path(__file__).resolve().parent
bpy.ops.wm.open_mainfile(filepath=str(here / "cubo_v1.blend"))
s = bpy.context.scene
s.render.engine = 'CYCLES'
s.cycles.device = 'CPU'
s.cycles.samples = 48
s.cycles.use_denoising = True
s.render.resolution_x, s.render.resolution_y = 1100, 900
s.render.film_transparent = False
s.render.use_stamp_filename = False   # no guardar la ruta local del .blend en los metadatos del PNG (el repositorio es público)
for name, explode, frame, cam in [("montado", 0.0, 1, None), ("explotado", 1.0, 1, (900, -1100, 750)),
                                  ("girado", 0.0, 50, None)]:
    s["Explosion"] = explode
    s.frame_set(frame)
    if cam: s.camera.location = cam
    s.render.filepath = str(here / f"render_{name}.png")
    bpy.ops.render.render(write_still=True)
    print("render", name)
