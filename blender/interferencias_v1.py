"""Intersección entre piezas vecinas de cubo_v1 (STL en posición de montaje).
Volumen ~0 = sin interferencia (puede haber contacto de superficie, previsto)."""
import subprocess, pathlib, re, shutil
here = pathlib.Path(__file__).parent
stl = here / "stl"
stl_s = stl.as_posix()   # OpenSCAD interpreta "\" como escape: usar "/"
cols = "union(){" + "".join(f'import("{stl_s}/column_{k}.stl");' for k in range(4)) + "}"
def imp(n): return f'import("{stl_s}/{n}.stl");'
pairs = {
    "portamatriz 0 vs columnas": (imp("holder_side_0"), cols),
    "portamatriz 3 (B) vs columnas": (imp("holder_side_3"), cols),
    "portamatriz 0 vs portamatriz 1": (imp("holder_side_0"), imp("holder_side_1")),
    "matriz 0 vs columnas": (imp("panel_side_0"), cols),
    "matriz 0 vs anillo": (imp("panel_side_0"), imp("top_ring")),
    "matriz superior vs anillo": (imp("panel_top"), imp("top_ring")),
    "portamatriz superior vs anillo": (imp("holder_top"), imp("top_ring")),
    "portamatriz superior vs portamatriz 0": (imp("holder_top"), imp("holder_side_0")),
    "portamatriz 0 vs placa inferior": (imp("holder_side_0"), imp("bottom_plate")),
    "portamatriz 0 vs anillo": (imp("holder_side_0"), imp("top_ring")),
    "matriz 0 vs placa inferior": (imp("panel_side_0"), imp("bottom_plate")),
    "columnas vs anillo": (cols, imp("top_ring")),
    "columnas vs placa inferior": (cols, imp("bottom_plate")),
    "Pi vs placa inferior": (imp("pi"), imp("bottom_plate")),
}
# Ajuste real: cada portamatriz contra su propia matriz (PCB, LED, conectores) y contra las matrices vecinas
for i in range(4):
    pairs[f"portamatriz {i} vs su matriz"] = (imp(f"holder_side_{i}"), imp(f"panel_side_{i}"))
pairs["portamatriz superior vs su matriz"] = (imp("holder_top"), imp("panel_top"))
for i in range(4):
    j = (i + 1) % 4
    pairs[f"matriz {i} vs matriz {j}"] = (imp(f"panel_side_{i}"), imp(f"panel_side_{j}"))
    pairs[f"portamatriz {i} vs matriz {j}"] = (imp(f"holder_side_{i}"), imp(f"panel_side_{j}"))
    pairs[f"matriz {i} vs matriz superior"] = (imp(f"panel_side_{i}"), imp("panel_top"))
OPENSCAD = shutil.which("openscad") or r"C:\Program Files\OpenSCAD\openscad.com"
def volume(path):
    txt = path.read_text(errors="ignore")
    v = [tuple(map(float, m)) for m in re.findall(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", txt)]
    return abs(sum((a[0]*(b[1]*c[2]-b[2]*c[1]) - a[1]*(b[0]*c[2]-b[2]*c[0]) + a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
                   for a, b, c in zip(v[0::3], v[1::3], v[2::3])))
tmp = here / "tmp"; tmp.mkdir(exist_ok=True)
for name, (a, b) in pairs.items():
    scad = tmp / "t.scad"; out = tmp / "t.stl"
    scad.write_text(f"intersection(){{ {a} {b} }}")
    if out.exists(): out.unlink()
    r = subprocess.run([OPENSCAD, "-o", str(out), str(scad)], capture_output=True, text=True)
    log = r.stdout + r.stderr
    if "not closed" in log or "ERROR" in log: print(f"{name}: ERROR, no se pudo comprobar (malla no cerrada)"); continue
    if "empty" in log or not out.exists(): print(f"{name}: sin interferencia"); continue
    print(f"{name}: volumen común = {volume(out):.2f} mm³")
