
# 計算関係の役立ちリンク

旧DARUMA Project HP(2019.12)から抜粋

### 解析支援/可視化

- [Atomic Simulation Environment (ASE)](https://wiki.fysik.dtu.dk/ase/) 構造に関するPythonフレームワーク、死ぬほど便利。必須。
- [pymatgen](http://pymatgen.org/index.html) 物質解析の支援の Python フレームワーク。[MaterialProject](https://materialsproject.org) および[Crystallograpy Open DB](http://www.crystallography.net/cod/) と RestAPI で連携する。
- [FINDSYM](http://iso.byu.edu/iso/findsym.php) 空間群などを探すための必須ツール、結晶晶系も越えられるので、巨大なセルを容易にシュリンク出来る。無いと死ぬ。
- [空間分のプログラム](http://phoenix.mp.es.osaka-u.ac.jp/~tspace/) 柳瀬先生の空間群のプログラム、古いバンド屋さんの常識
- [spglib](https://atztogo.github.io/spglib/) 空間分のプログラムの国際的なやつ、こっちが今では業界標準
- [フェルミ面の書き方](http://www.cmp.sanken.osaka-u.ac.jp/~koun/o2knano/tnotes/tr104.pdf) 柳瀬プログラムを使いこなすとわりと自由自在にフェルミ面を各プログラムを作れます。
- [FermiSurface](http://fermisurfer.osdn.jp/index.html.ja) もうこし汎用的なやつ。似たようなやつを（もっとしょぼいもの) AVS (OpenDXでも動く)で書いたことあります
- [LibTetraBZ](http://libtetrabz.osdn.jp) みんな一度は通るテトラヘドロン法の開発。容易に実装できるライブラリです。マニュアル有り。
- [cif2cell](https://sourceforge.net/projects/cif2cell/) ASEでプログラムを書けば必要ないのだが、単品でプログラムとしては便利。

### 情報系/データベース

- [MateriApps](https://ma.issp.u-tokyo.ac.jp) ソフトウェア情報サイト。CMSI が終わっても以外に元気。情報の質は低いけど、量が増えてきた
- [Crystallography open database](http://www.crystallography.net/cod/) 結晶構造DB、お金がないときに便利。Crystallography や ICSD の代わりになるかも？ [pymatgen](http://pymatgen.org/index.html)から RestAPI で呼び出せる
- [Materials Project](https://materialsproject.org) 米国:材料科学DB、計測した XANES スペクトルに近い材料を検索することも出来る [pymatgen](http://pymatgen.org/index.html)から RestAPI で呼び出せる
- [MatNav](https://mits.nims.go.jp) NIMS:材料科学DB

### 計算コードの支援/lib

- [unfolding](https://www.ifm.liu.se/theomod/compphys/band-unfolding) バンドのフォールディングが出来る！
- [lobster](http://schmeling.ac.rwth-aachen.de/cohp/index.php?menuID=6) COHP 計算
- [Bader](http://theory.cm.utexas.edu/henkelman/code/bader/)  Bader によるAIM 計算のコードの VASP で動くやつ, 超重要
- [Yambo](http://www.yambo-code.org) GW,BSE
- [Phonopy](https://atztogo.github.io/phonopy/) もはやフォノン計算の常識
- [Wannier90](http://www.wannier.org) ワニエ関数はこれ
- [BoltzTraP](https://www.imc.tuwien.ac.at//forschungsbereich_theoretische_chemie/forschungsgruppen/prof_dr_gkh_madsen_theoretical_materials_chemistry/boltztrap/) ゼーベックからボルツマン係数の計算まで輸送係数あれこれ
- [EXC code](http://etsf.polytechnique.fr/exc/) EXC 計算に関してのデファクトスタンダート化しつつあるライブラリ
- [MUMPS](http://mumps.enseeiht.fr) 超高速な疎行列ソルバー、ライバルはまだいくつかある
- [FFTE](http://www.ffte.jp) FFTの業界標準 FFTW に匹敵する国産のソフト。FFTWよりライセンスが緩いのに同等レベルなのでアカデミアにはおすすめ。

### 各種コードへのリンク

- [WIEN2k](http://www.wien2k.at) FLAPW御三家の一つ
- [FLEUR](http://www.flapw.de/site/) FLAPW御三家の一つ、気がついたらDL可能なオープン化されていた
- [FLK-CODE](http://elk.sourceforge.net) 実質的にはFLAPW御三家からのブランチ（ネガティブには開発者の裏切り）からのスタートされたプロジェクトの一つ
- [HiLAPW](http://www.cmp.sanken.osaka-u.ac.jp/~oguchi/HiLAPW/index.html) 小口先生のコード。FLAPWとしては、御三家派生でも、国内の柳瀬系譜でない独自のFLAPWコード。SW-LAPW 基底の実用コードでは世界唯一。余り知られてないが、PDのときに、このコードに SWではくKAでノンコリを実装したのは私。
- [ABCAP](https://www.rs.noda.tus.ac.jp/bands001/contents/abcap/abcap.html) 柳瀬系譜の国産FLAPWは二つあるのだがそのうちの一つ、東のコード。
- [KANSIA-94/2000](http://www.phys.sci.kobe-u.ac.jp/faculty/harima.html) 柳瀬系譜の国産FLAPWのうちの西の雄。播磨大先生のコード。4年からD3まで、学生の頃 KANSAI-92 でずっと仕事していた。非公開コードっぽい。
- [LmtART](http://savrasov.physics.ucdavis.edu/mindlab/MaterialResearch/Scientific/index_lmtart.htm) Fullpotenail な LMTO コード。結果的にほぼ FLAPW ちっくなので、今となっては歴史的存在かもしれないが。学生の頃結構使ってました。
- [LMTO-CPA](http://titus.phy.qub.ac.uk/packages/LMTO/v7.11/doc/cpa.htm), [グループ](http://physics.unl.edu/~kirillb/), LMTO-ASA などで計算したことのある人はかならずつかっていたことのあるはずの Mark さんのコード。私も学生の頃使ってました。
- [Quantum Espresso](https://www.quantum-espresso.org) PAW, US-PP のオープンソースの代表。PAW化が遅れた abinit を尻目にOSSのPPコードでは最大手にのし上がった。
- [OpenMX](http://www.openmx-square.org) 世界で戦える日本オリジナルに近いコード。擬ポテンシャル + 擬原子基底の変態コード。国際的にはSIESTAがNo1
- [SIESTA](https://departments.icmab.es/leem/siesta/) 擬ポテンシャル + 擬原子基底の代表格の一つ。OpenMXのライバル。
- [SPRKKR](http://olymp.cup.uni-muenchen.de/index.php?option=com_content&view=article&id=8&catid=4&Itemid=7) KKR 法の現存する唯一の実用コード(OSS)
- [AKAI-KKR](http://kkr.issp.u-tokyo.ac.jp/jp/) KKR 法コードの国産版 (KKRなので当たり前ではあるが、CPAが使える国産コードではそれなりに価値が高い)
- [FPLO](http://www.fplo.de/) 売り物。欧州らしい今更の新しい基底での新しいフルポテンシャル手法(XANESも可)
- [FHI-aims](https://aimsclub.fhi-berlin.mpg.de) 売り物。数値基底 + Fullpotential という変態コード(ただし、最近流行のPAW流の変態ではないところがミソ)。PDのころつかってました。
- [BigDFT](http://bigdft.org) 旧ESRFの理論グループが作ったコード。ウェーブレット + 擬ポテンシャルの変態コード。大規模計算。
- [ecalj](https://github.com/tkotani/ecalj) 混合補強基底法(PMT法) に基づくコード。LAPW + LMTO 的な（意訳）王道中の王道の流れを、PAWのアイデアから結合させたコードといっては乱暴だが。時流からはそれるが面白い。小谷大先生のコード。
- [GPAW](https://wiki.fysik.dtu.dk/gpaw/) Pythonで書かれた計算コード(ASEベース)でなにげに基底の組み合わせがマニアックだが、OSSとしての体裁は進んでいる。PAW,LCAO, FDM での計算が使える。
- [cp2k](https://www.cp2k.org) GAUSSIAN + PP の変態コード。
- [FDMNES](http://neel.cnrs.fr/spip.php?rubrique1007&lang=en) FDM を用いたフルポテンシャルXANESコード。日本国内でFDMNES計算事例が急速に増えたのは私の功績(産業利用のセミナーで講義したおかげ)。
- [RMC POT++](https://www.szfki.hu/~nphys/rmc++/opening.html)
