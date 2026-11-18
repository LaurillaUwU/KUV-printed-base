"""Cada pieza de imprimir/ debe ser la misma pieza del montaje (blender/stl) GIRADA, nunca en espejo.
Un espejo no se ve en las comprobaciones de choques (el montaje se modela bien) ni en los tornillos (son simétricos),
pero las ventanas de conectores, imanes desplazados y agujeros de seguridad quedan del lado contrario.
Prueba las 48 orientaciones de ejes (24 giros + 24 espejos), centra las cajas y cuenta vértices coincidentes.
Uso:  python blender/verificar_orientacion.py      (Python normal con numpy; no hace falta Blender)
"""
import itertools, pathlib, struct
import numpy as np
from scipy.spatial import cKDTree

aqui = pathlib.Path(__file__).resolve().parent
pares = [("03_portamatriz_lateral_A.stl", "holder_side_0.stl"),
         ("04_portamatriz_lateral_B.stl", "holder_side_3.stl"),
         ("05_portamatriz_superior_B.stl", "holder_top.stl"),
         ("06_placa_inferior.stl", "bottom_plate.stl"),
         ("07_columna.stl", "column_0.stl"),
         ("08_anillo_superior.stl", "top_ring.stl")]

def cargar(ruta):
    data = ruta.read_bytes()
    if data[:5] == b"solid" and b"facet" in data[:300]:
        return np.array([[float(t) for t in l.split()[1:]] for l in data.decode().splitlines() if l.strip().startswith("vertex")])
    n = struct.unpack("<I", data[80:84])[0]
    a = np.frombuffer(data[84:84 + n * 50], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]))
    return a["v"].reshape(-1, 3).astype(float)

def centrar(p):
    return p - (p.min(0) + p.max(0)) / 2

mal = 0
for impr, mont in pares:
    a, b = cargar(aqui.parent / "imprimir" / impr), cargar(aqui / "stl" / mont)
    b = np.unique(np.round(b, 3), axis=0); a = np.unique(np.round(a, 3), axis=0)
    arbol = cKDTree(centrar(b))
    mejor = {1: 0.0, -1: 0.0}
    for perm in itertools.permutations(range(3)):
        for signos in itertools.product((1, -1), repeat=3):
            m = np.zeros((3, 3))
            for i, (j, s) in enumerate(zip(perm, signos)): m[i, j] = s
            det = round(np.linalg.det(m))
            d, _ = arbol.query(centrar(a @ m.T))
            mejor[det] = max(mejor[det], float(np.mean(d < 0.05)))
    ok = mejor[1] > 0.98 and mejor[1] >= mejor[-1]   # >= : una pieza simétrica (columna) coincide de las dos formas
    mal += not ok
    print(f"{impr:32s} giro {mejor[1]:6.1%}  espejo {mejor[-1]:6.1%}  -> {'OK' if ok else 'EN ESPEJO / NO COINCIDE'}")
print(f"\nPiezas mal orientadas: {mal}")
