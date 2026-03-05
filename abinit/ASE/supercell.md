# ASE を用いたスーパーセル作成

公式マニュアルがすべですが、念のため。基本サンプル集。

## supercell を作る
入力が VASP (POSCAR) の時

```
#!/usr/bin/env python

from ase.io import read,write
from ase.io.vasp import *
from ase.io.xyz import *

cell = read_vasp('c-LGPS.vasp')

write_vasp('c-LGPS_222.vasp', cell*(2,2,2), label='c-LGPS_222supercell', direct=True, sort=True, vasp5=True)
write_vasp('c-LGPS_333.vasp', cell*(3,3,3), label='c-LGPS_333supercell', direct=True, sort=True, vasp5=True)
```

| key | value |
|---|---|
| cell*(2,2,2) | 2x2x2 の cell を作る|
| label | POACAR の一行目 |
| direct | True/False, Direct or カーテシアン |
| sort | True/False, 同一種の原子をまとめるか否か？ |
| vasp5 | True/False, VASP5 形式？ or VASP4 形式? |

## 分子用の supercell を作る

## 表面構造を作る

```
from ase.io import read,write
from ase.io.vasp import *
from ase.io.xyz import *
from ase.lattice.surface import *

cifname = 'crystal.cif'
outname = 'POSCAR_100_surface_05_layer.vasp'

cell = read(cifname, format='cif')

cell.write(outname, format='vasp',direct=True,vasp5=True)

sur = surface(cell, (1,0,0), 5, vacuum=12.0)
sur.center(vacuum=8, axis=2)
sur.write(outname, format='vasp', direct=True, vasp5=True)
```


## 真空層の変更

```
from ase.io import read,write
from ase.io.vasp import *
from ase.io.xyz import *
from ase.lattice.surface import *

inpname = 'POSCAR'
outname = 'POSCAR.vasp'

vacuum = 15 # Angstrom

cell = read(inpname, format='vasp')

cell.center(vacuum=vacuum, axis=2)
cell.write(outname, format='vasp',direct=True, vasp5=True)
```
