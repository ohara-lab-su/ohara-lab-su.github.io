# FDMNES のビルド

[TOC]

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> はじめに

FDMNES は最低限の makefile があるのみで、あまり自由にビルドできる情報が提供されてないし、
付属のMakefile はたいがい腐っているし、最新の Intel Compiler 構成での最低限の形でしか無い。
ここでは簡単にそれを読み解いた study を紹介する。この手の作業が５年ぶりなので忘れているので、基本は備忘録である。

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> 自作の関連ドキュメント

- [FDMNES講習会2016](http://support.spring8.or.jp/Doc_lecture/Text_160128-29.html)
- [FDMNES講習会2019](http://support.spring8.or.jp/Doc_lecture/Text_190228-0301.html)
- [cif などから FDMNES の構造ファイル(inp)を作成するツール](../SAE/install_02.md)
- [FDMNES の CnetOS6 + Intel Compiler(2011)への導入](../FDMNES/fdmnes_install_01.md)
- [FDMNES の CnetOS7 + gfortran 環境への導入](../FDMNES/fdmnes_centos_gfortran.md)
- [FDMNES の産業利用計算機(BL14B2計算機)でのあれこれ](../FDMNES/BL14B2_fdmnes.md)

PDFドキュメント

- [FDMNES のビルドに関して for Linux (Intel Compiler) 2015.12.22](../FDMNES/pdf/メモ_FDMNES_NEW-compile_2015.12.22.pdf)
- [FDMNES のビルド関して for Ubuntu (gfortran) (2015/2016版)](../FDMNES/pdf/メモ_FDMNES_NEW-compile_gfortran+openmpi.key.pdf)
- [FDMNES のビルドに関して for Mac (2015/2016版) 未完](../FDMNES/pdf/メモ_FDMNES_NEW-compile_homebrew.key.pdf)

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> 必要なライブラリのダウンロード

FDMNES のバージョンによってライブラリの必要バージョンが変わるようなので注意。基本的には、MUMPS のバージョンに注意する。

!!! Warning
    FDMNES 2016 あたりと 2020 ではかなりビルドが異なるので注意。

### MUMPS

FDMNEDS は、MUMPS (**MU**ltifrontal **M**assively **P**arallel sparse direct **S**olver) Libraryを用いる。

- [MUMPS](http://mumps.enseeiht.fr)

疎行列ソルバーの欧州の雄。このあたりの業界をほとんど知らないのだが、昔調べたときは、世界を二分か三分するそのうちの主流の一派の一つ。

### Scotch

- [SCOTCH](https://www.labri.fr/perso/pelegrin/scotch/)
- [SOCTCH ダウンロードなど](https://gforge.inria.fr/projects/scotch/)

 2020.05.12 での最新バージョン (scotch 6.0.6)

### METIS

行列、グラフの並び替え、分割ライブラリ

- [METIS](http://glaros.dtc.umn.edu/gkhome/metis/metis/download)

!!! note
    2020.05.12 での最新バージョン (metis-5.1.0)

<!-- --------------------------------------------------------------------------------- -->
## FDMNES でビルドできるバージョン構成

### 2015.07.03 以前

### 2016 あたり

- MUMPS_5.0.1
- metis-5.1.0
- scotch_6.0.4

### 2020 あたり

- MUMPS_5.0.1 だとダメ
- MUMPS_5.3.1 でやる
- metis-5.1.0/scotch-6.0.4 では一応動く

<!-- --------------------------------------------------------------------------------- -->
## ビルドの詳細

<!-- --------------------------------------------------------------------------------- -->
### MUMPS 手抜きビルド

#### 必要なライブラリ

- OpenMPI
- BLAS
- BLACS
- ScaLAPAC

#### Makefile 修正

Makefile のベースとなるものを Makefile.inc に名前を変える

```text
cp Make.inc/Makefile.INTEL.PARA Makefile.inc
```

バグっている　Makefile　を修正

``` PROD/lib/Makefile ``` 修正前

```makefile
libpord$(LIBEXT):$(OBJS)
>---$(AR)$@ $(OBJS)
>---$(RANLIB) $@
```

``` PROD/lib/Makefile ``` 修正後

```makefile
libpord$(LIBEXT):$(OBJS)
>---$(AR) $@ $(OBJS)
>---$(RANLIB) $@
```

!!! Note
    嫌がらせとしか思えないが、もしかしたら新しい Intel Compiler だとこれで動くのかもしれない。摩訶不思議。

同様に

```src/Makefile``` 修正後

```makefile
$(libdir)/libmumps_common$(PLAT)$(LIBEXT):      $(OBJS_COMMON_MOD) $(OBJS_COMMON_OTHER)
>---$(AR) $@ $?
>---$(RANLIB) $@

$(libdir)/lib$(ARITH)mumps$(PLAT)$(LIBEXT):    $(OBJS_MOD) $(OBJS_OTHER)
>---$(AR) $@ $?
>---$(RANLIB) $@
```

同様に

```libseq/Makefile``` 修正後

```makefile
libmpiseq$(PLAT)$(LIBEXT): mpi.o mpic.o elapse.o
>---$(AR) $@ mpi.o mpic.o elapse.o
>---$(RANLIB) $@
```

主にコンパイラ情報を直す(産業BL14B2計算機, IntelCompiler + openmpi)

```text
CC = mpicc
FC = mpif90
FL = mpif90
```

オプティマイズを変更する(**変更しない方が良いかも**、qopenmp を openmp に直すだけ旧コンパイラでOK)下記は、MUMPS 5.0.1 をベースとしたオプションなので。

```text
OPTF  = -O  -DALLOW_NON_INIT -nofor_main
OPTL  = -O -nofor_main
OPTC  = -O
```

!!! Warning
    古い(2016年あたり)の MKL だと dgemmt 関係が使えないので、オプティマイズ(ディレクティブ)で外しておく必要がある

```makefile
#OPTF    = -O -nofor_main -DBLR_MT -openmp -DGEMMT_AVAILABLE
OPTF    = -O -nofor_main -DBLR_MT -openmp
```

GEMMT の有効化が消える。

openmp 関係のオプションを修正

修正

```makefile
-qopenmp
```

修正後

```makefile
-openmp
```

!!! Note
    -qopenmp  は -openmp のオプションの後継オプションです。新しいコンパ等ならばそのまま動きます

ビルド手順

```text
make
make z
cd libseq
make
```

!!! Note
    結構時間がかかります

生成されるライブラリ

- lib/libdmumps.a
- lib/libmumps_common.a
- lib/libpord.a
- lib/libzmumps.a

<!-- --------------------------------------------------------------------------------- -->
### SCOTCH 手抜きビルド

コンパイラに ICC をつかっていて、clock_gettime() がない！とエラーが出るときは ```-lrt``` をつけてコンパイルする

修正箇所(for Linux)

```text
cd src
```

```makefile
Make.inc/Makefile.inc.i686_pc_linus2 ベース
LDFLAGS = -lz -lm -pthread -lrt
```

ビルド手順

```text
make
make esmumps
```

生成されるライブラリ

- libscotch/libscotch.a
- libscotch/libscotcherr.a
- esmumps/libesmumps.a

<!-- --------------------------------------------------------------------------------- -->
### METIS 手抜きビルド

```text
make  config cc=icc prefix=~/lib/metis
make
make install
```

生成されるライブラリ

- libmetics.a

<!-- --------------------------------------------------------------------------------- -->
## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> FDMNES のビルド (Linux Intel Compiler + openmpi)

### 事前に必要なライブラリまとめ

### 2016 および 2020 共通

ビルドに必要な includeファイル。MUMPS & MPI 関係

```text
dmumps_root.h
dmumps_struc.h
mpif.h
zmumps_root.h
zmumps_struc.h
```

!!! Warning
    特に重要なのがライブラリのリンク順番になる。オリジナルの Makefile がベースだと古いコンパイラだとほぼダメ。順番による依存を真面目に考えないといけない。

Makefile の重要な部分の抜粋

```makefile
$(EXEC): $(OBJ)
    $(FC) -o $@ $^ -Llibmumps -ldmumps -lmumps_common -lpord -lzmumps \
                   -Llibesmumps -lesmumps \
                   -L$(HOME)/lib/metis/lib -lmetis \
                   -Llibscotch -lscotch -lscotcherr \
                   -lpthread
                   -mkl -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64

```

### 2016 推奨

```makefile
sphere.o: sphere.f90
        $(FC) -O1 -c $*.f90
```

実は本当に必要かわからないが、コンパイルオプションを特定のソースだけしている。

### 2020 のみ

```makefile
OBJ = main.o clemf0.o coabs.o convolution.o diffraction.o dirac.o \
      fdm.o fdmx.o fprime.o fprime_data.o general.o lecture.o mat.o metric.o \
      minim.o optic.o potential.o selec.o scf.o spgroup.o sphere.o tab_data.o \
      tddft.o tensor.o mat_solve_mumps.o \
      RIXS.o
```

!!! Note
    RIXS.f90 のビルドが必要。公式 Makefile からも依存が消えているので糞なのだが、ビルドしてリンクすると使える。

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> Makefile

完全な保障はないが、私が作って使っているやつ

### 2016 Maakefile

```makefile
.SUFFIXES: .f90
# Makefile to compile FDMNES with call to MUMPS, LAPACK and BLAS libraries, for sequential calculations
# MUMPS comes with associated other libraries.
# Works with the gfortran Linux Compiler (for other compiler change the FC command)

#FC = gfortran
FC = mpif90
#OPTLVL = 3

#EXEC = ../fdmnes
EXEC = ../bin/fdmnes

# For intel compiler, it seems that probems at execution are avoided when compiling
# sphere.f90 with O1 option and the other routines with O2 option.

#BIBDIR = bib

#FFLAGS = -c  -O$(OPTLVL) -Iincludemumps
FFLAGS = -c -Iincludemumps

OBJ = main.o clemf0.o coabs.o convolution.o dirac.o fdm.o fprime.o general.o lecture.o mat.o metric.o \
      minim.o optic.o potential.o selec.o scf.o spgroup.o sphere.o tab_data.o tddft.o tensor.o \
      mat_solve_mumps.o

all: $(EXEC)

$(EXEC): $(OBJ)
>---$(FC) -o $@ $^ -Llibmumps -ldmumps -lmumps_common -lpord -lzmumps \
                   -Llibscotch -lscotch -lscotcherr \
                   -Llibesmumps -lesmumps \
                   -L$(HOME)/lib/metis/lib -lmetis \
                   -lpthread -mkl \
                   -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64


#                   -lzmumps \
#                   -lzmumps -lmpiseq -lpord \
#

sphere.o: sphere.f90
>---$(FC) -O1 -c $*.f90

%.o: %.f90
>---$(FC) -O2 -o $@ $(FFLAGS) $?


clean:
>---rm -f *.o $(EXEC)
>---rm -f *.mod>
```

### 2020 Maakefile (2020.05.13 21:26)

いらんコメントが入って申し訳ないが、まだテスト中。とりあえず使える。

```makefikle
# Makefile to compile FDMNES with call to MUMPS, LAPACK and BLAS libraries, for sequential calculations
# MUMPS comes with associated other libraries.
# Works with the gfortran Linux Compiler (for other compiler change the FC command)

#FC = gfortran-mp-6
FC = mpif90
#OPTLVL = 3

#EXEC = ../fdmnes
EXEC = ../bin/fdmnes

# For intel compiler, it seems that probems at execution are avoided when compiling^M
# sphere.f90 with O1 option and the other routines with O2 option.

#BIBDIR = /opt/local/lib

INCDIR = include

FFLAGS = -c  -O$(OPTLVL) -I$(INCDIR)

OBJ = main.o clemf0.o coabs.o convolution.o diffraction.o dirac.o \
>---  fdm.o fdmx.o fprime.o fprime_data.o general.o lecture.o mat.o metric.o \
      minim.o optic.o potential.o selec.o scf.o spgroup.o sphere.o tab_data.o \
>---  tddft.o tensor.o mat_solve_mumps.o \
>---  RIXS.o

all: $(EXEC)

$(EXEC): $(OBJ)
>---$(FC) -o $@ $^ \
>---  -Llibmumps -ldmumps -lmumps_common -lpord -lzmumps \
>---  -Llibesmumps -lesmumps \
>---  -L$(HOME)/lib/metis/lib -lmetis \
>---  -Llibscotch -lscotch -lscotcherr \
>---  -lpthread \
>---  -mkl -lmkl_scalapack_lp64 -lmkl_blacs_openmpi_lp64

#>--  -Llibmumpsseq -lmpiseq


# #>  -Llibesmumps -lesmumps \
# #>  -Llibmumpsseq -lmpiseq
#
# #$(EXEC): $(OBJ)
# >-#$(FC) -o $@ $^ -L$(BIBDIR) -ldmumps -lzmumps -lmumps_common -lesmumps -lmetis -lpord \
#                                    -lscotch -lscotcherr -lpthread -llapack -lblas
# #$(EXEC): $(OBJ)
# #>$(FC) -o $@ $^ -L$(BIBDIR) -ldmumps -lzmumps -lmumps_common -lpord \
                                   -lscotch -lscotcherr -lpthread -llapack -lblas

%.o: %.f90
>---$(FC) -o  $@ $(FFLAGS) $?

clean:
>---rm -f *.o $(EXEC)
>---rm -f *.mod
```