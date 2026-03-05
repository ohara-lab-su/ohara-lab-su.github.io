# SAE (仮) + RMC 変換ツールの導入

[TOC]

## はじめに

RMC形式への変換を始めとした各種ツール([マニュアル](README.md),[概要](http://www.spring8.or.jp/pdf/ja/ann_rep/14/054.pdf))は、

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

ただ、RMC 関係の構造変換ができる数少ない汎用コード（の基盤ライブラリ）でもあるため、時々需要があります。コードはアホですが、ツールとしては普通に便利に使えると思います。

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

## cif から RMC 形式への変換方法
正しくは、VASP の POSCAR形式 (P1形式) から cif へ変換が可能です。それぞれインストールと設定(パス)が終わればコマンドプロンプトから自由に使えます。

### 第一引数のみを指定する(出力ファイルは自動生成)

```
Rvasp2cfg.py Li2MnO3.vasp
```

と実行すると。 Li2MnO3.vap.cfg が自動生成されます。この場合拡張子に特に意味は無いので。もし構造ファイルが POSCAR という名前でしたら

```
Rvasp2cfg.py POSCAR
```
と入力したら。POSCAR.cfg が出力ファイルになります。

### 第二引数を指定する(出力ファイルの指定)

は出力ファイル名を第二引数に指定します。

```
Rvasp2cfg.py Li2MnO3.vasp Li2MnO3
```

とすると、第二引数の Li2MnO3 に cfg を加えて。Li2MnO3.cfg が出力されます。