# TSPACE 導入あれこれ
[TOC]

## 履歴
- 2017.10.19: start

## はじめに

少し古い日本国内のバンド屋なら「必ず」知っている**柳瀬先生**の TSPACE ですが、一部の機能を使いたいと思って、15年ぶりくらいにコードを引っ張ってました。そのときのメモです。最近だと、空間群関係のライブラリは SPGLIB などのオープンソースを使ったりだと思うのですが、それらと合わせて空間群関係の一連のプログラムのメモ程度をまとめられればと思います。詳しい人はスルーしてください。

私自身は 18年くらい前、TSPACE からバンド計算を始めたのですが、実際に自分で第一原理計算のコードの開発を仕事にしたのが、TSPACE 相当を独自に実装した HiLAPW というコードをベースにしています。そのため、いろいろ作ったプログラムが実は結構公開できなかったります。ポチポチやりたいことをこれら TSPACE や SPGLIB などの公開プログラムで作りなしたり作ったり出来たらと思ってます。

## どのようなライブラリか？
空間群を使った一連の処理ができるライブラリです。空間群を使った座標の回転から、波動関数の対称化まで。空間群に関わるプログラムを作る場合は何かの形でこれらの機能の限定的なバージョンを自作しているはずです。TSPACE や SPGLIB のような汎用ライブラリは K空間でも実空間でも対称性を扱うプログラムを作りの大きな手助けになります。なんといっても、ソースコードが公開されてますので、情報の入手は自作コードの公開しやすいです。

## TSPACE入手
国産のバンド計算プログラムだと結構空間群の部分で TSPACE を使っているので実は使っているパターンが多いのですが、基本は書籍「[TSPACE空間群のプログラム](https://www.amazon.co.jp/空間群のプログラム-TSPACE-柳瀬-章/dp/4785329084)」で入手します。ただし当然今では絶版です。正直書籍がないとわけわからん（書籍があってもわからんくらい難しい）のですが、貴重です。

現在[TSPACEの公式サイト](http://aquarius.mp.es.osaka-u.ac.jp/~tspace/)にてソースコードが公開されてます

- ソースコード:[直リンク](http://aquarius.mp.es.osaka-u.ac.jp/~tspace/tspace_main/tsp07/tsp98.f)
- パラメータファイル:[直リンク](http://aquarius.mp.es.osaka-u.ac.jp/~tspace/tspace_main/tsp07/prmtsp.f)
- 生成元データベース:[直リンク](http://aquarius.mp.es.osaka-u.ac.jp/~tspace/tspace_main/tsp07/generator.table)
- ワイコフ位置データベース:[直リンク](http://aquarius.mp.es.osaka-u.ac.jp/~tspace/tspace_main/tsp07/wycoff)

原則的に上記4つのファイルは全部必要です。昔のアカデミアなコードなのでライセンスは明記されてないのですが、Apache2くらい意識、できれば GPLv2くらいの意識でコードを扱うべきだとは思います。

## TSPACE のビルド
上記Webで公開されているTSPACEは tsp98.f です(知っている限り 2007/08/29版)。試した限り、Intel Compiler と gfortran でビルドできます。書くまでもない部分ですが、ifort のビルドに必要な Makefile を示します。タブ記号はそのままスペース表記しているのでコピペしても動きませんので注意してください。その場合はダウンロードしてください。いくつかプラットホームで静的なライブラリを作ったのでそれもここでダウンロード可能です。ビルドしなくともライブラリファイルをコピーすれば TSPACE の機能は使えます。ライセンスは TSPACE にしたがってください。

```
FC = ifort
FFLAGS=-O -mp1
INSTALL_DIR=../../

LIB=libtsp98.a
SRC=tsp98.f
OBJ=tsp98.o

PROJ = $(LIB)

.f.o:
>---$(FC) $(FFLAGS) -c $<

all:>---$(PROJ)

clean:
>---rm -f $(PROJ) $(OBJ) core

$(PROJ):$(OBJ)
>---$(AR) -cr $@ $(OBJ)

install:
>---mv $(PROJ) $(INSTALL_DIR)
>---rm -f *.o

tsp98.o:tsp98.f prmtsp.f
```

gfortran の場合は、ifort を gfortran に変えればＯＫです。上記 Makefile は [こちら](tsp98/Makefile) にあります。

### コンパイル済みLibrary

- CentOS6.4, intel Compiler, 64bit [[Download (libtsp98.a)](pub/CentOS6.4/x64/ifort/libtsp98.a)]

