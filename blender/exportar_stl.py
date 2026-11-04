"""Exporta las piezas de cubo_v1.scad a STL (posición de montaje) usando OpenSCAD."""
import subprocess, pathlib, shutil
OPENSCAD = shutil.which("openscad") or r"C:\Program Files\OpenSCAD\openscad.com"
here = pathlib.Path(__file__).parent
out = here / "stl"
out.mkdir(exist_ok=True)
parts = ["bottom_plate", "top_ring"] + [f"column_{k}" for k in range(4)] + \
        [f"holder_side_{i}" for i in range(4)] + [f"panel_side_{i}" for i in range(4)] + \
        ["holder_top", "panel_top", "pi"] + \
        [f"screws_ok_{i}" for i in list(range(4)) + ["top"]]
for p in parts:
    r = subprocess.run([OPENSCAD, "-o", str(out / f"{p}.stl"), "-D", f'part="{p}"',
                        str(here / "export_partes.scad")], capture_output=True, text=True)
    status = "OK" if r.returncode == 0 and (out / f"{p}.stl").exists() else "ERROR"
    print(p, status, [l for l in r.stderr.splitlines() if "ERROR" in l or "WARNING" in l][:2])
