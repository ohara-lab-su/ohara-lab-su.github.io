# FDMNES (2016あたりのコード) CentOS + gfortran

[TOC]

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> はじめに

FDMNES を CentOS7 + gfortran 環境へ導入するためのメモ、備忘録

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

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> 環境

- CentOS7.x

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> FDMNES のビルドに事前に必要なもの(主なもの)

1. cmake
2. gfortran
3. openmpi
4. lapack
5. scalapack
6. metis
7. scotch
8. mumps

!!! Note
    CentOS だと rmp (yum) などで大抵は入るのだが、それぞれのライブラリで必要としているバージョンが矛盾（特に openmpi )していることがおおくて、rpmでインストールしてもほとんど動かない。

!!! Note
    基本的にはここに書いた順番で入れる(デフォルトで導入済みは別)

!!! Note
    バージョンの組み合わせにチョイスがあって、動く動かないがある（そもそもビルドできなかったりする）。一番シンプルには世代をそろえること。FDMNES や VASP などのコードも同じ。特に、**MUMUPS** まわりは注意が必要。

ちょっとビルドがぬるいかもしれない

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> cmake

!!! Warning
    あまり新しいと、gcc の新しいものを求めてくるのでデンジャラス

ここでは、3.1.1 を導入する

```sh
./configure --prefix=/opt/local/cmake
make
sudo make install
```

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> openmpi

- [openmpi-4.0.4](https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.4.tar.gz)
- [openmpi-2.0.4](https://download.open-mpi.org/release/open-mpi/v2.0/openmpi-2.0.4.tar.gz)
- [openmpi-1.10.7](https://download.open-mpi.org/release/open-mpi/v1.10/openmpi-1.10.7.tar.gz)

```sh
./configure --prefix=/opt/local/openmpi-4.0.4
make all -j 16  # -j 並列ビルド
sudo make install
```

パスを通したりいろいろ

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> lapack

- [lapack](http://www.netlib.org/lapack/)
- [lapack 3.9.0](https://github.com/Reference-LAPACK/lapack/archive/v3.9.0.tar.gz)
- [lapack 3.5.0](http://www.netlib.org/lapack/lapack-3.5.0.tgz)

!!! note
    3.5.0 までの dgev.f は VASP などでは使うので注意

### lapack-3.9.0

ビルドのための準備

```sh
cp make.inc.exsample make.inc
```

CentOS + gfortran + gcc では修正無しでOK

```sh
make -j 16
```

普通に make すると、テスト関係でいくつかコケるので下記をがベスト(必要ないものなどもいろいろテストしている)

```sh
make blaslib -j 16
make lapacklib -j 16
make lib -j 16
```

- ```make tgmliib``` は 3.9.0 では存在しない

この時点で生成された十なライブラリは(make.in があるディレクトリに作られる)

- liblapack.a
- librefblas.a
- libtmglib.a

```sh
sudo mkdir /opt/local/lapack-3.9.0/lib
sudo cp liblapack.a librefblas.a libtgmlib.a /opt/local/lapack-3.9.0/lib
```

### lapack-3.5.0

```sh
cp make.inc.example make.inc
vi make.inc
make blaslib -j 16
make lapacklib -j 16
make lib -j 16
make -j16
```

*) 上記、冗長的な記述あり

- liblapack.a
- librefblas.a
- libtmglib.a

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> scaLapack

!!! Note
    openmpi を先に入れる

- [ScaLAPACK](http://www.netlib.org/scalapack/)
- [ScaLAPACK-2.0.2](http://www.netlib.org/scalapack/scalapack-2.0.2.tgz)  (MPI-3.0: openmpi-4.0.4 ではNG)
- [ScaLAPACK-2.1.0](http://www.netlib.org/scalapack/scalapack-2.1.0.tgz)

### scalapack-2.1.0: openmpi-4.0.4 + lapack-3.9.0

```sh
cp SLmake.inc.example SLmake.inc
```

SLmake.inc

```makefile
FC = /opt/local/openmpi-4.0.4/bin/mpif90 -L/opt/local/lapack-3.9.0/lib
CC = /opt/local/openmpi-4.0.4/bin/mpicc -L/opt/local/lapack-3.9.0/lib
BLASLIB       = -L/opt/local/lapack-3.5.9/lib -lrefblas
LAPACKLIB     = -L/opt/local/lapack-3.5.9/lib -llapack
```

```sh
make lib -j 16
```

!!! Note
    MPI_Type_struct was removed in MPI-3.0 だとビルドできない。(MPI library のバージョンが高すぎるのが原因) 上記と同じ内容を、scalapack-2.1.0 にて行うと成功する

- libscalapack.a

```sh
sudo mkdir /opt/local/scalapack-2.1.0/lib
sudo cp libscalapack.a /opt/local/scalapack-2.1.0/lib
```

### scalapack-2.0.2: openmpi-2.0.4 + lapack-3.5.0

```sh
cp SLmake.inc.example SLmake.inc
```

SLmake.inc

```makefile
FC  = /opt/local/openmpi-2.0.4/bin/mpif90 -L/opt/local/lapack-3.5.0/lib
CC  = /opt/local/openmpi-2.0.4/bin/mpicc -L/opt/local/lapack-3.5.0/lib
BLASLIB    = -L/opt/local/lapack-3.5.0/lib -lrefblas
LAPACKLIB  = -L/opt/local/lapack-3.5.0/lib -llapack
```

```sh
make
```

- libscalapack.a

```sh
sudo mkdir /opt/local/scalapack-2.0.2/lib
sudo cp libscalapack.a /opt/local/scalapack-2.0.2/lib
```

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> metis

([参考](https://www.nag-j.co.jp/nagconsul/performance-tuning/jisseki/hector_dCSE_UnstructuredGridGuide.htm#04))

ミソネタ大学・空軍HPC研究センター・クレイリサーチ社の開発による、グラフ分割と有限要素メッシュ作成のシリアルプログラム集。
マルチレベル再帰的バイセクション、マルチレベルk分割、および多重制約領域分割スキームに基づいている。
元のグラフサイズを縮小して分割を行い、その後最終的に元のグラフの領域を元得る。
**METISは領域分割ソフト**として用いられることも多い。

ParMETISはMITISを機能拡張するMPIベースの並列ライブラリ。
PerMETIS 以外にも、MT-METIS がある。

METIS それ自体は、2013年の 5.1.0 が最終版っぽい。

- [hp](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview)
- [metis-5.1.0 binary-package](https://centos.pkgs.org/7/epel-x86_64/metis-5.1.0-12.el7.x86_64.rpm.html)
- [rpm直リンク](http://springdale.princeton.edu/data/springdale/7/x86_64/os/Computational/metis-5.1.0-12.sdl7.x86_64.rpm)

!!! Note
    cmake が必要

```sh
make config prefix=/opt/local/metis-5.1.0
make
sudo make install
```

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> scotch

([参考](https://www.nag-j.co.jp/nagconsul/performance-tuning/jisseki/hector_dCSE_UnstructuredGridGuide.htm#04))

ボルドー大学情報学研究所LaBRIで開発され、現在はINRIA ボルドー南西研究センターのScAlApplixeプロジェクト内で開発管理されている。

デュアル再帰的二分割(DRB)マッピングアルゴリズムが全ての Scotchパッケージに実装されており、
これは分割統治アプローチに基づく幾つかの発見論的グラフ二分割法が用いられている。
また、近年では、ハイパーグラフ分割アルゴリズムから、Scotchの順序付け機能は元のメッシュ構造へ拡張されている。

並列化機能は、PT-Scotch(Parallel Threaded　Scotch)として実装されている。
これは、操作するサブグラフが単一プロセッサに割当てられたときは、PT-ScotchはScotchライブラリの
シリアル動作ルーチンへ制御を移行する。
ScotchとPT-Scotchは並列分散計算アプリケーションで用いられるグリッド分割に極めて有効に作用する。

新規の領域分割や**順序付け手法**として用いられる。
利用方法として、領域分割ソフトに metis、順序づけとして scotch などの組み合わせが多い。

- [scotch](https://www.labri.fr/perso/pelegrin/scotch/)
- [scotch-6.0.4 binary-package](https://centos.pkgs.org/7/epel-x86_64/scotch-6.0.4-13.el7.x86_64.rpm.html)
- [rpm直リンク](http://springdale.princeton.edu/data/springdale/7/x86_64/os/Computational/scotch-6.0.4-13.sdl7.x86_64.rpm)
- [scotch-6.0.4 (src)](https://gforge.inria.fr/frs/download.php/file/34618/scotch_6.0.4.tar.gz)
- [scotch-6.0.9 (src)](https://gforge.inria.fr/frs/download.php/file/38187/scotch_6.0.9.tar.gz)

### scotch-6.0.4 + openmpi-4.0.4 + scalapack-2.1.0 + lapack-3.9.0

#### scotch-6.0.4: (openmpi-4.0.4 + scalapack-2.1.0 + lapack-3.9.0) Makefile.in のひな形をコピー

```scotch_6.0.4/src/Make.inc/Makefile.inc.x86-64_pc_linux2```

```sh
cp scotch_6.0.4/src/Make.inc/Makefile.inc.x86-64_pc_linux2 scotch_6.0.4/src/Makefile.inc
```

作業フォルダのツリー

- src/Make.inc/
- src/Makefile
- src/Makefile.inc
- src/check/
- src/esmumps/
- src/libscotch/
- src/libscotchmetis/
- src/misc/
- src/scotch/

Makefile.inc の mpicc, gcc に include を加える

```makefile
CCS  = gcc -I/opt/local/openmpi-4.0.4/include/
CCP  = mpicc -I/opt/local/openmpi-4.0.4/include/
CCD  = gcc -I/opt/local/openmpi-4.0.4/include/
```

最終的には

```makefile
EXE     =
LIB     = .a
OBJ     = .o
MAKE    = make
AR      = ar
ARFLAGS = -ruv
CAT     = cat
CCS  = gcc -I/opt/local/openmpi-4.0.4/include/
CCP  = mpicc -I/opt/local/openmpi-4.0.4/include/
CCD  = gcc -I/opt/local/iopenmpi-4.0.4/include/

CFLAGS  = -O3 -DCOMMON_FILE_COMPRESS_GZ -DCOMMON_PTHREAD -DCOMMON_RANDOM_FIXED_SEED -DSCOTCH_RENAME -DSCOTCH_PTHREAD -Drestrict=__restrict -DIDXSIZE64
CLIBFLAGS =
LDFLAGS  = -lz -lm -lrt -pthread
CP     = cp
LEX    = flex -Pscotchyy -olex.yy.c
LN     = ln
MKDIR  = mkdir
MV     = mv
RANLIB = ranlib
YACC   = bison -pscotchyy -y -b y
```

#### scotch-6.0.4: (openmpi-4.0.4 + scalapack-2.1.0 + lapack-3.9.0)  prefix を修正する

インストール先を直す

```makefile
prefix   ?= /opt/local/scotch_6.0.4
```

インストール先に

- scotch_6.0.4/bin
- scotch_6.0.4/include
- scotch_6.0.4/lib
- scotch_6.0.4/man

がなければ事前に作っておく

#### scotch-6.0.4: make

make する

```sh
make
make esmumps
make install
```

生成物

- lib/libesmumps.a
- lib/libscotch.a
- lib/libscotcherr.a
- lib/libscotcherrexit.a
- lib/libscotchmetis.a

!!! Warning
    openmpi-4.0.4 + scalapack-2.1.0 + lapack-3.9.0 の組み合わせの scotch-6.0.4 は結局 mumps-5.0.1 ではダメなので使わない。

### scotch-6.0.4 + openmpi-2.0.4 + scalapack 2.0.2 + lapack-3.5.0

```scotch_6.0.4/src/Make.inc/Makefile.inc.x86-64_pc_linux2```

```sh
cd src
cp Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc
```

作業フォルダのツリー

- src/Make.inc/
- src/Makefile
- src/Makefile.inc
- src/check/
- src/esmumps/
- src/libscotch/
- src/libscotchmetis/
- src/misc/
- src/scotch/

Makefile.inc の mpicc, gcc に include を加える

```makefile
CCS  = gcc -I/opt/local/openmpi-2.0.4/include/
CCP  = mpicc -I/opt/local/openmpi-2.0.4/include/
CCD  = gcc -I/opt/local/openmpi-2.0.4/include/
```

Makefile を修正する

```makefile
prefix   ?= /opt/local/scotch_6.0.4
```

インストール先に

- scotch_6.0.4/bin
- scotch_6.0.4/include
- scotch_6.0.4/lib
- scotch_6.0.4/man

make する

```sh
make
make esmumps
make install
```

生成物

- lib/libesmumps.a
- lib/libscotch.a
- lib/libscotcherr.a
- lib/libscotcherrexit.a
- lib/libscotchmetis.a

### scotch-6.0.9 + openmpi-4.0.4 + scalapack 2.1.0 + lapack-3.9.0

scotch-6.0.4 --> **6.0.9**

```scotch_6.0.9/src/Make.inc/Makefile.inc.x86-64_pc_linux2```

```sh
cp scotch_6.0.9/src/Make.inc/Makefile.inc.x86-64_pc_linux2 scotch_6.0.4/src/Makefile.inc
```

作業フォルダのツリー

- src/Make.inc/
- src/Makefile
- src/Makefile.inc
- src/check/
- src/esmumps/
- src/libscotch/
- src/libscotchmetis/
- src/misc/
- src/scotch/

Makefile.inc の mpicc, gcc に include を加える

```makefile
CCS  = gcc -I/opt/local/openmpi-4.0.4/include/
CCP  = mpicc -I/opt/local/openmpi-4.0.4/include/
CCD  = gcc -I/opt/local/openmpi-4.0.4/include/
```

Makefile を修正する

```makefile
prefix   ?= /opt/local/scotch_6.0.9
```

インストール先に

- scotch_6.0.4/bin
- scotch_6.0.4/include
- scotch_6.0.4/lib
- scotch_6.0.4/man

make する

```sh
make
make esmumps
make install
```

生成物

- lib/libesmumps.a
- lib/libscotch.a
- lib/libscotcherr.a
- lib/libscotcherrexit.a
- lib/libscotchmetis.a

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> MUMPS 5.0.1

事前に必要なもの

- lapack-3.5.0
  - BLAS
  - BLACS
- OpenMPI-2.0.4
- ScaLapack-2.0.2
- metis-5.1.0
- scotch-6.0.4
- mumps-5.0.1

!!! Note
    scotch-6.0.4 + openmpi-2.0.4 + scalapack 2.0.2 + lapack-3.5.0 の構成だとうまく成功する

### mumps-5.0.1: Makefile.inc の生成

!!! Note
    ひな形には gfortran がないのだが、実は debian が gfortran ベースなので、debian を元にすると簡単

```sh
cp Make.inc/Makefile.debian.PAR Makefile.inc
```

### mumps-5.0.1: Makefile のバグ修正

アーカイバの呼び出しにスペースが入ってないので、コケる。
最新の Intel Compiler などでは動くのか？
よく知らん。少なくとも、古い Intel Compiler環境、古い/最新の gccなどのLinux
環境では１００パーセントコケる。**嫌がらせ**にしか思えない。

例

```makefile
libmpiseq$(PLAT)$(LIBEXT): mpi.o mpic.o elapse.o
    $(AR)$@ mpi.o mpic.o elapse.o  (修正前)
    $(AR) $@ mpi.o mpic.o elapse.o  (修正後)
```

これらの修正を

- libseq/Makefile
- src/Makefile
- PORD/lib/Makefile

### mumps-5.0.1: Makefile.inc の修正(1)

```makefile
#
#  This file is part of MUMPS 5.0.1, released
#  on Thu Jul 23 17:08:29 UTC 2015
#
# These settings for a PC under Debian/linux with standard packages :
# metis (parmetis), scotch (ptscotch), openmpi, gfortran

# packages installation :
# apt-get install libmetis-dev libparmetis-dev libscotch-dev libptscotch-dev libatlas-base-dev openmpi-bin libopenmpi-dev

# # Begin orderings
LSCOTCHDIR = /opt/local/scotch_6.0.4/lib
#ISCOTCH   = -I/usr/include/scotch # only needed for ptscotch

#LSCOTCH   = -L$(LSCOTCHDIR) -lptesmumps -lptscotch -lptscotcherr
LSCOTCH   = -L$(LSCOTCHDIR) -lesmumps -lscotch -lscotcherr

LPORDDIR = $(topdir)/PORD/lib/
IPORD    = -I$(topdir)/PORD/include/
LPORD    = -L$(LPORDDIR) -lpord

LMETISDIR = /opt/local/metis-5.1.0/lib
#IMETIS    = -I/usr/include/parmetis
IMETIS    = -I/opt/local/metis-5.1.0/lib

# # LMETIS    = -L$(LMETISDIR) -lparmetis
LMETIS    = -L$(LMETISDIR) -lmetis

# Corresponding variables reused later
#ORDERINGSF = -Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch
ORDERINGSF = -Dmetis -Dpord -Dscotch
ORDERINGSC  = $(ORDERINGSF)
LORDERINGS = $(LMETIS) $(LPORD) $(LSCOTCH)
IORDERINGSF = $(ISCOTCH)
IORDERINGSC = $(IMETIS) $(IPORD) $(ISCOTCH)
# End orderings
################################################################################

PLAT    =
LIBEXT  = .a
OUTC    = -o
OUTF    = -o
RM = /bin/rm -f
CC = gcc
FC = gfortran
FL = gfortran
AR = ar vr
RANLIB = ranlib

#SCALAP  = -lscalapack-openmpi -lblacs-openmpi  -lblacsF77init-openmpi -lblacsCinit-openmpi
#SCALAP = -L/opt/local/scalapack-2.1.0/lib -lscalapack
SCALAP = -L/opt/local/scalapack-2.0.2/lib -lscalapack

#INCPAR = -I/usr/lib/openmpi/include
#INCPAR = -I/opt/local/openmpi-4.0.4/include
INCPAR = -I/opt/local/openmpi-2.0.4/include

#LIBPAR = $(SCALAP)  -lmpi -lmpi_f77
#LIBPAR = $(SCALAP) -L/opt/local/openmpi-4.0.4/lib -lmpi -lmpi_mpifh
LIBPAR = $(SCALAP) -L/opt/local/openmpi-2.0.4/lib -lmpi -lmpi_mpifh

INCSEQ = -I$(topdir)/libseq
LIBSEQ  =  -L$(topdir)/libseq -lmpiseq

#LIBBLAS = -lblas
#LIBBLAS = -L/opt/local/lapack-3.9.0/lib -lrefblas
LIBBLAS = -L/opt/local/lapack-3.5.0/lib -lrefblas
LIBOTHERS = -lpthread

#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)
CDEFS   = -DAdd_

#Begin Optimized options
OPTF    = -O  -DALLOW_NON_INIT
OPTL    = -O
OPTC    = -O
#End Optimized options
INCS = $(INCPAR)
LIBS = $(LIBPAR)
LIBSEQNEEDED =
```

### install

```sh
make
make z
cp lib/* /opt/local/mumps-5.0.1/lib/
cp include/* /opt/local/mumps-5.0.1/include/
```

libmpiseq

```sh
cd libseq
make
cp libmpiseq.a /opt/local/mumps-5.0.1/
```

これまでの作業で下記に入っている

- /opt/local/mumps-5.0.1/lib/libdmumps.a
- /opt/local/mumps-5.0.1/lib/libmpiseq.a
- /opt/local/mumps-5.0.1/lib/libmumps_common.a
- /opt/local/mumps-5.0.1/lib/libpord.a
- /opt/local/mumps-5.0.1/lib/libzmumps.a

!!! Warning
    scotch-6.0.4 + openmpi-4.0.4 + scalapack 2.1.0 + lapack-3.9.0 の構成では**このままでは動かない**
    ビルドは出来てもリンク時に関数がいくつかライブラリ(scalapack)内にないのでお壊れる。

!!! Note
    scotch-6.0.4 + openmpi-2.0.4 + scalapack 2.0.2 + lapack-3.5.0 の構成だとうまく成功する

## <i class="fa fa-arrow-circle-right" aria-hidden="true"></i> MUMPS 5.3.1

新しい、FDMNES ではいつかから、MUMPS の新しいものが必要。API が結構変わっている。

事前に必要なもの

- lapack-3.9.0
  - BLAS
  - BLACS
- OpenMPI-4.0.4
- ScaLapack-2.1.0
- metis-5.1.0
- scotch-6.0.9
- mumps-5.3.1

!!! Note
    scotch-6.0.4 + openmpi-2.0.4 + scalapack 2.0.2 + lapack-3.5.0 の構成だとうまく成功する

### mumps-5.3.1: Makefile.inc の生成

!!! Note
    ひな形には gfortran がないのだが、実は debian が gfortran ベースなので、debian を元にすると簡単

```sh
cp Make.inc/Makefile.debian.PAR Makefile.inc
```

### mumps-5.3.1: Makefile のバグ修正

アーカイバの呼び出しにスペースが入ってないので、コケる。
最新の Intel Compiler などでは動くのか？
よく知らん。少なくとも、古い Intel Compiler環境、古い/最新の gccなどのLinux
環境では１００パーセントコケる。**嫌がらせ**にしか思えない。

例

```makefile
libmpiseq$(PLAT)$(LIBEXT): mpi.o mpic.o elapse.o
    $(AR)$@ mpi.o mpic.o elapse.o  (修正前)
    $(AR) $@ mpi.o mpic.o elapse.o  (修正後)
```

これらの修正を

- libseq/Makefile
- src/Makefile
- PORD/lib/Makefile

### mumps-5.3.1: Makefile.inc の修正

!!! Note
    fmdnes は mumps の openmp ライブラリを使うので、openmp オプションが必須となる

```makefile
#ISCOTCH   = -I/usr/include/scotch
LSCOTCHDIR = /opt/local/scotch_6.0.9
ISCOTCH   = -I$(LSCOTCHDIR)/include

#LSCOTCH   = -L$(LSCOTCHDIR) -lptesmumps -lptscotch -lptscotcherr
LSCOTCH   = -L$(LSCOTCHDIR)/lib -lesmumps -lscotch -lscotcherr

LPORDDIR = $(topdir)/PORD/lib/
IPORD    = -I$(topdir)/PORD/include/
LPORD    = -L$(LPORDDIR) -lpord

#LMETISDIR = /usr/lib
LMETISDIR = /opt/local/metis-5.1.0
#IMETIS    = -I/usr/include/parmetis
#IMETIS    = -I/usr/include/metis
IMETIS    = -I$(LMETISDIR)/include

# LMETIS    = -L$(LMETISDIR) -lparmetis -lmetis
LMETIS    = -L$(LMETISDIR)/lib -lmetis

# Corresponding variables reused later
#ORDERINGSF = -Dmetis -Dpord -Dparmetis -Dscotch -Dptscotch
ORDERINGSF = -Dmetis -Dpord -Dscotch
ORDERINGSC  = $(ORDERINGSF)

LORDERINGS = $(LMETIS) $(LPORD) $(LSCOTCH)
IORDERINGSF = $(ISCOTCH)
IORDERINGSC = $(IMETIS) $(IPORD) $(ISCOTCH)
# End orderings
################################################################################

PLAT    =
LIBEXT  = .a
OUTC    = -o
OUTF    = -o
RM = /bin/rm -f

#CC = mpicc
#FC = mpif90
#FL = mpif90
CC = /opt/local/openmpi-4.0.4/bin/mpicc -fopenmp
FC = /opt/local/openmpi-4.0.4/bin/mpif90 -fopenmp
FL = /opt/local/openmpi-4.0.4/bin/mpif90 -fopenmp

AR = ar vr
RANLIB = ranlib
#LAPACK = -llapack
#SCALAP  = -lscalapack-openmpi -lblacs-openmpi
LAPACK = -L/opt/local/lapack-3.9.0/lib -llapack
#SCALAP  = -L/opt/local/scalapack-2.1.0/lib -lscalapack-openmpi -lblacs-openmpi
SCALAP  = -L/opt/local/scalapack-2.1.0/lib -lscalapack

#INCPAR = # not needed with mpif90/mpicc:  -I/usr/include/openmpi
INCPAR = -I/opt/local/openmpi-4.0.4/include

LIBPAR = $(SCALAP) $(LAPACK) # not needed with mpif90/mpicc: -lmpi_mpifh -lmpi

INCSEQ = -I$(topdir)/libseq
LIBSEQ  = $(LAPACK) -L$(topdir)/libseq -lmpiseq

#LIBBLAS = -lblas
LIBBLAS = -L/opt/local/lapack-3.9.0/lib -lrefblas
LIBOTHERS = -lpthread

#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)
CDEFS   = -DAdd_

#Begin Optimized options
OPTF    = -O -fopenmp
OPTL    = -O -fopenmp
OPTC    = -O -fopenmp
#End Optimized options

INCS = $(INCPAR)
LIBS = $(LIBPAR)
LIBSEQNEEDED =
```

### make & install

```sh
make
make z
cp lib/* /opt/local/mumps-5.3.1/lib/
cp include/* /opt/local/mumps-5.3.1/include/
```

libmpiseq

```sh
cd libseq
make
cp libmpiseq.a /opt/local/mumps-5.0.1/
```

!!! Warning
    ビルドは出来てもリンク時に関数がいくつかライブラリ(scalapack)内にないのでお壊れる。 scotch-6.0.4 + openmpi-4.0.4 + scalapack 2.1.0 + lapack-3.9.0 の構成では**このままでは動かない**

!!! Note
    scotch-6.0.4 + openmpi-2.0.4 + scalapack 2.0.2 + lapack-3.5.0 の構成だとうまく成功する

## FDMNES 2016.09.01 version

1. CentOS7
2. gfortran-4.8.5
3. openmpi-2.0.4
4. lapack-3.5.0
5. scalapack-2.0.2
6. metis-5.1.0
7. scotch-6.0.4
8. mumps-5.0.1

```sh
▽
# Makefile to compile FDMNES with call to MUMPS, LAPACK and BLAS libraries, for sequential calculations
# MUMPS comes with associated other libraries.
# Works with the gfortran Linux Compiler (for other compiler change the FC command)

#FC = gfortran
FC = /opt/local/openmpi-2.0.4/bin/mpif90
#OPTLVL = 3

EXEC = ../bin/fdmnes

# For intel compiler, it seems that probems at execution are avoided when compiling
# sphere.f90 with O1 option and the other routines with O2 option.

BIBDIR = bib

FDMNES_include = include

FFLAGS = -c  -O$(OPTLVL) -I$(FDMNES_include)

OBJ = main.o clemf0.o coabs.o convolution.o dirac.o fdm.o fprime.o general.o lecture.o mat.o metric.o \
      minim.o optic.o potential.o selec.o scf.o spgroup.o sphere.o tab_data.o tddft.o tensor.o \
      mat_solve_mumps.o

all: $(EXEC)

LAPACKDIR=/opt/local/lapack-3.5.0
SCADIR=/opt/local/scalapack-2.0.2
METISDIR=/opt/local/metis-5.1.0
SCOTCHDIR=/opt/local/scotch_6.0.4
MUMPSDIR=/opt/local/mumps-5.0.1

$(EXEC): $(OBJ)
>---$(FC) -o $@ $^ -L$(BIBDIR)  \
                              -L$(MUMPSDIR)/lib -ldmumps -lmumps_common -lzmumps -lpord -lmpiseq \
                              -L$(SCOTCHDIR)/lib  -lesmumps -lscotch -lscotcherr \
                              -L$(METISDIR)/lib -lmetis \
                              -L$(SCADIR)/lib -lscalapack \
                              -L$(LAPACKDIR)/lib -llapack -lrefblas -ltmglib \
                              -lpthread

%.o: %.f90
>---$(FC) -o $@ $(FFLAGS) $?

clean:
>---rm -f *.o $(EXEC)
>---rm -f *.mod
```

## FDMNES 2020.06.12-2 version

期間ライブラリのバージョンをそろえる

1. CentOS7
2. gfortran-4.8.5
3. **openmpi-4.0.4**
4. lapack-3.9.0
5. **scalapack-2.1.0**
6. metis-5.1.0
7. **scotch-6.0.9**
8. **mumps-5.3.1**

!!! Note
    openmp を mumps に求めるなど openmp を使うので openmp オプションをつける

```makefile
# Makefile to compile FDMNES with call to MUMPS, LAPACK and BLAS libraries, for sequential calculations
# MUMPS comes with associated other libraries.
# Works with the gfortran Linux Compiler (for other compiler change the FC command)

##FC = gfortran-mp-6
FC = /opt/local/openmpi-4.0.4/bin/mpif90 -fopenmp
OPTLVL = 3

EXEC = ../bin/fdmnes

# For intel compiler, it seems that probems at execution are avoided when compiling^M
# sphere.f90 with O1 option and the other routines with O2 option.

BIBDIR = /opt/local/lib

LAPACKDIR=/opt/local/lapack-3.9.0
SCADIR=/opt/local/scalapack-2.1.0
METISDIR=/opt/local/metis-5.1.0
SCOTCHDIR=/opt/local/scotch_6.0.9
MUMPSDIR=/opt/local/mumps-5.3.1

#INCDIR = include

#FFLAGS = -c  -O$(OPTLVL) -I$(INCDIR)
FFLAGS = -c  -O$(OPTLVL) -I$(MUMPSDIR)/include

OBJ = main.o clemf0.o coabs.o convolution.o diffraction.o dirac.o fdm.o fdmx.o fprime.o fprime_data.o general.o lecture.o mat.o metric.o \
      minim.o optic.o potential.o selec.o scf.o spgroup.o sphere.o tab_data.o tddft.o tensor.o \
      mat_solve_mumps.o RIXS.o

all: $(EXEC)

$(EXEC): $(OBJ)
>---$(FC) -o $@ $^  -L$(BIBDIR) \
                              -L$(MUMPSDIR)/lib -ldmumps -lzmumps -lmumps_common -lpord -lmpiseq \
                              -L$(SCOTCHDIR)/lib  -lesmumps -lscotch -lscotcherr \
                              -L$(METISDIR)/lib -lmetis \
                              -L$(SCADIR)/lib -lscalapack \
                              -L$(LAPACKDIR)/lib -llapack -lrefblas -ltmglib \
                              -lpthread

%.o: %.f90
>---$(FC) -o  $@ $(FFLAGS) $?

clean:
>---rm -f *.o $(EXEC)
>---rm -f *.mod
```