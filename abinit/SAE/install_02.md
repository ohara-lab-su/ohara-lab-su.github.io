# SAE (仮) + FDMNES 変換ツールの導入

[TOC]

## はじめに

FDMNESの入力形式への変換を始めとした各種ツール([マニュアル](README.md),[概要](http://www.spring8.or.jp/pdf/ja/ann_rep/14/054.pdf))は、

- 2年以上メンテナンスできない
- メンテできてない以上バグが怖い
- 開発当時は Python がよくわかってなかった
- 方針がふらついていた
- 設計もフラついいた
- 存在価値(理由)も怪しい
- Python2.x ベースで作った
- (普段の Python 開発環境は、3.x へ移行ししてしまったので 2.x 開発は労力的に無理)
- 無駄に開発規模が大きくて飽和気味

など様々な問題を抱えていて、再設計しない限り、どうにもこうにも正直お蔵行きのプログラムです。

ただ、FDMNES 形式への構造変換関係ができる数少ない汎用コード（の基盤ライブラリ）でもあるため、時々需要があります。コードはアホですが、ツールとしては普通に便利に使えると思います。

## Windows 版の導入

SAE ([マニュアル](README.md),[概要](http://www.spring8.or.jp/pdf/ja/ann_rep/14/054.pdf))の導入をすれば各種変換ツールも同時に導入されます。**インストーラー付き**なので、順番に exe を実行すれば導入できます。各種バイナリの多くは 2年くらい前にDLした少し古いソースが元ですが、64bit版 windows向けに、インストーラーを用意してます。

導入されるのは Pytthon は 2.7.x 系です。おそらく、**[Anaconda](https://docs.continuum.io/anaconda/install/)** を導入していれば、1〜10番まで導入は全部スキップできると思います。どちらの方式でもよいです。

1. [python-2.7.14rc1.amd64.msi](../pub/python-2.7.14rc1.amd64.msi) ([公式HP](https://www.python.org/downloads/release/python-2713/))
2. [numpy-MKL-1.9.1.win-amd64-py2.7.exe](../pub/numpy-MKL-1.9.1.win-amd64-py2.7.exe)
3. [scipy-0.14.1rc1.win-amd64-py2.7.exe](../pub/scipy-0.14.1rc1.win-amd64-py2.7.exe)
4. [pyparsing-2.0.3.win-amd64.exe](../pub/pyparsing-2.0.3.win-amd64.exe)
5. [python-ase-3.9.1.win-amd64.exe](../pub/python-ase-3.9.1.win-amd64.exe)
6. [pytz-2015.4.win-amd64.exe](../pub/pytz-2015.4.win-amd64.exe)
7. [six-1.9.0.win-amd64.exe](../pub/six-1.9.0.win-amd64.exe)
8. [matplotlib-1.4.2.win-amd64-py2.7.exe](../pub/matplotlib-1.4.2.win-amd64-py2.7.exe)
9. [VPython-6.04.win-amd64-py2.7.exe](../pub/VPython-6.04.win-amd64-py2.7.exe)
10. [wxPython3.0-win64-3.0.1.1-py27.exe](../pub/wxPython3.0-win64-3.0.1.1-py27.exe)

11. [StructureAnalysisEnvironment-0.0.1.win-amd64](../pub/StructureAnalysisEnvironment-0.0.1.win-amd64.exe)

## Python2.7 関係のパスを忘れずに通す
デフォルトでは **c:\Python27**  に導入されますので。

- c:\Python27
- c:\Python27\Scripts

へパスを通しておいてください。

## xyz から FDMNES 形式への変換方法
xyz 形式(md形式) は割と標準的だと思いますが、定義されてない情報を載せているファイルもあるので注意です。念のため、ここで対応している書式は下記になります。

```
225
femes2
Fe     14.843250    4.947750   20.518487
P      13.420673    5.512189   22.218510
C      12.687812    3.765040   18.875746
C      13.662123    7.412917   18.519394
...
...
省略
```

1. 225: 総原子数
2. femes2: コメント(材料名)
3. Fe  14.843250  4.947750 20.518487: 元素名 x,y,z

の意味になります。SAE を導入後に、SAEを用いてコーディングされた支援ツール **FDxyz2fdm.py** を用います。

入力ファイルが FeMes2SciOpp.xy の時

```
FDxyz2fdm.py FeMes2SciOPP
```

出力ファイルとして

- FeMes2SciOPP.fdmnes
- read\_pdb.inp　(FDMNESの入力ファイル)

になります。\*.fdmnes は構造情報のみを出力したファイル。read\_pdb.inp (出力ファイル名のデフォルトである \_pdbの名前は開発の歴史的経緯によるもので意味は無いです）は FDMNES の入力ファイルの テンプレート＋ \*.fdmnes の内容を追加したものになります。


## POSCAR or P1形式 から FDMNES 形式への変換方法

VASP の POSCAR 形式(*.vasp, POSCAR or CONTCAR) およびそれらとほぼ同等の形式である P1形式(VESTA で P1 出力で作れる \*.p1 ファイル) を FDMNES 形式に変換できます。P1 形式(+格子の情報付き)なので xyz 以上に使いやすい形式です。xyz 形式の情報をすべて含めることが出来ます。構造情報管理の書式としてはおすすめす。

```
FDvasp2fdm.py 
```

と実行すると、カレントに POSCAR があれば勝手にそれを読み込んで

- POSCAR.fdmnes
- read\_pdb.inp　(FDMNESの入力ファイル)

を作ります。