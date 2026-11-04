import subprocess, pathlib, re, sys
here = pathlib.Path(__file__).parent; stl = here / "stl"; tmp = here / "tmp"
a = sys.argv[1]
for k in range(4):
    (tmp / "l.scad").write_text(f'intersection(){{ import("{stl}/{a}.stl"); import("{stl}/column_{k}.stl"); }}')
    out = tmp / "l.stl"
    if out.exists(): out.unlink()
    r = subprocess.run(["openscad", "-o", str(out), str(tmp / "l.scad")], capture_output=True, text=True)
    if "empty" in r.stderr: print(k, "vacío"); continue
    v = [tuple(map(float, m)) for m in re.findall(r"vertex\s+(\S+)\s+(\S+)\s+(\S+)", out.read_text())]
    print(k, [(round(min(p[i] for p in v), 2), round(max(p[i] for p in v), 2)) for i in range(3)])
