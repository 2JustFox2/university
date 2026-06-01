import math
from pathlib import Path

reactant = Path('1H_triazole_freq.xyz')
product = Path('2H_triazole_freq.xyz')
images = 5  # number of intermediate images

def read_xyz(p):
    lines = p.read_text().strip().splitlines()
    natoms = int(lines[0].strip())
    comment = lines[1]
    atoms = []
    for ln in lines[2:2+natoms]:
        parts = ln.split()
        atoms.append((parts[0], float(parts[1]), float(parts[2]), float(parts[3])))
    return atoms, comment

R, rc = read_xyz(reactant)
P, pc = read_xyz(product)

if len(R) != len(P):
    raise SystemExit('Atom count mismatch')

def interp(a, b, t):
    return a[0], a[1] + (b[1]-a[1])*t, a[2] + (b[2]-a[2])*t, a[3] + (b[3]-a[3])*t

header = '''! BLYP def2-TZVP def2/J D3BJ SP CPCM(Water) PAL6
%maxcore 4000
%cpcm
  SMD true
  SMDsolvent "water"
  end
* xyz 0 1
'''

for i in range(1, images+1):
    t = i / (images+1)
    coords = [interp(R[j], P[j], t) for j in range(len(R))]
    xyz_name = f'neb_img{i:02d}.xyz'
    inp_name = f'neb_img{i:02d}.inp'
    with open(xyz_name, 'w', encoding='utf-8') as f:
        f.write(f"{len(coords)}\n")
        f.write(f"Interpolated image {i} t={t:.6f}\n")
        for a,x,y,z in coords:
            f.write(f"  {a}   {x:16.8f}   {y:16.8f}   {z:16.8f}\n")

    # write ORCA input with header + coords
    with open(inp_name, 'w', encoding='utf-8') as f:
        f.write(header)
        for a,x,y,z in coords:
            f.write(f"  {a}   {x:12.6f}   {y:12.6f}   {z:12.6f}\n")
        f.write('*\n')

print('Wrote', [f'neb_img{i:02d}.xyz' for i in range(1, images+1)])
print('Wrote', [f'neb_img{i:02d}.inp' for i in range(1, images+1)])
