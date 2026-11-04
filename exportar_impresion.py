"""Exporta las piezas en la ORIENTACIÓN DE IMPRESIÓN a la carpeta imprimir/ (listas para el slicer).
Uso:  python exportar_impresion.py
Después:  blender -b --python blender/analizar_impresion.py   (pausas para imanes y soportes de cada archivo)
"""
import subprocess, pathlib, shutil
OPENSCAD = shutil.which("openscad") or r"C:\Program Files\OpenSCAD\openscad.com"
aqui = pathlib.Path(__file__).resolve().parent
out = aqui / "imprimir"
out.mkdir(exist_ok=True)
piezas = [  # (archivo, vista de cubo_v1.scad)
    ("01_plantilla_prueba.stl", "part_template"),
    ("02_probeta_calibracion.stl", "part_calibration"),
    ("03_portamatriz_lateral_A.stl", "part_holder_side_A"),
    ("04_portamatriz_lateral_B.stl", "part_holder_side_B"),
    ("05_portamatriz_superior_B.stl", "part_holder_top_B"),
    ("06_placa_inferior.stl", "part_bottom_plate"),
    ("07_columna.stl", "part_corner_column"),
    ("08_anillo_superior.stl", "part_top_ring"),
]
for archivo, vista in piezas:
    r = subprocess.run([OPENSCAD, "-o", str(out / archivo), "-D", f'view="{vista}"', str(aqui / "cubo_v1.scad")],
                       capture_output=True, text=True)
    log = r.stdout + r.stderr
    ok = r.returncode == 0 and (out / archivo).exists() and "ERROR" not in log
    print(f"{archivo:32s} {'OK' if ok else 'ERROR'}", [l for l in log.splitlines() if "ERROR" in l or "ASSERT" in l][:2])
