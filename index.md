# Ohara Lab | Software
Software for data analysis and device control used in our research projects.  
[尾原研](https://ohara.mat.shimane-u.ac.jp/) / [ohara-lab-su (github)](https://github.com/ohara-lab-su) / [ohara-lab-su (docs)](https://ohara-lab-su.github.io/)

<!--
* Toc
{:toc}
-->

## スサノオ: スサノオとは？

島根大学が開発する、SPring-8 の **[BL774](https://user.spring8.or.jp/sp8info/?p=42759)** 互換(ese774)
を用いた一連の計測システムを**スサノオ**と読んでいる。BL774のサブセットの一種である

## スサノオ: システムの概要

SPring-8 における [MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
ESRF の [TANGO](https://www.tango-controls.org/) のようなフルスタック型の
プロトコル・フレームワークの開発設計はせずに **マイクロサービス** を軸としたコンパクトな
組み合わせにする。
システムの中核となる通信フレームは、ターゲットとなるデバイスと目的の通信速度・フレークワークとの
結合をしやすいように、フレームを切り替えても同じように使えるようにする。
つまり基本は**シンプルな透過型プロキシ**を採用している。

<img src="fig/ese_774.004.png" width="70%" style="display:block; margin:auto;">

[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
互換としての立ち位置は、公式に**BL774 REST server** のコードを基盤にしており、
get や post のルールを
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
側の真似をしているところである。
ただ、マネージメントやAPIセットにははまだ大きな規定や仕組みはない。つまり774APIセットに対応しているわけではなく、
BL774 Basic System 未満である。

基本センスとしては、スサノオはフレームワーク側として API を統一整理する代わりに、
制御クラス側に API の規定は任せている。つまり、透過型プロキシとして動的ディパッチを軸としたフレームであり、
制御クラス側の python の API がそのままクライアント上での API となる。APIを揃える場合は
制御クラス側で揃える。徹底的にミニマム志向で作られている。

- [基本: 方針/設計](susanoo_intro.md)

## スサノオ: 分散システム

[MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
[TANGO](https://www.tango-controls.org/) のような本当の意味での分散システムは目指さない。
つまりサーバー・サーバー間通信を含めた意味で分散ではなく、単純なサーバー・クライアント通信が
ベースのシステム構成となる。ミニマムな実験支援系システムではそれほど本格的な分散システムは
必要ないという判断が根底にある。単純に
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
型の互換であるからという理由もあるし、
設計・開発・保守メンテナンスをミニマムなコストで行うためである。

[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
は遅い通信である RestAPI を採用している。これは、
webに立脚した技術体系の普及率と簡便さに立脚しているからである。
開発効率と一般的で普及しているシステムであることは何より大切である。
同システムのサブセットであるスサノオも同等である

それに対して、それなりに高速な通信やイベント起動などの高度な通信が必要な場合は、
同じ web技術の範囲でも、gRPC をスサノオでは選択可能になっている。この gRPC
への拡張は本家BL774でも行われており、BL774対応の一つである

- [分散制御システム](susanoo_dcs.md)
- [スサノオのシステム](susanooo_system.md)

## スサノオ: インストール方法

スサノオは、サーバー・クライアント型のシンプルな分散システムである。
そのため、使用するにあたっては、デバイスサーバの形でデバイス(実験機器)側の
サーバーを立ち上げる必要がある。

スサノオはほぼ完全な透過型プロキシであるため、(1)スサノオに関係なく
デバイス制御プログラムを書く。 (2)スサノオフレームを用いて、デバイス制御プログラムからデバイスサーバー
を作る。 (3)スサノオフレームにより自動で作られるデバイスクライアントを
用て、実験制御プログラムを書く。この３つのステップで機器制御・開発を行う。

- [スサノオの基本構成のインストール](susanoo_install.md)

基本構成の導入の後は、個別の装置ごとのモジュールを導入すればいい。
ここでは cobotta と電子天秤のデバイスを用いるのでそのためのモジュールを導入して設定を行う。

- [cobotta制御サーバ (ese774)](https://ohara-lab-su.github.io/cobotta2/tutorials/install_server.html) の導入
- [cobotta制御クライアント (ese774)](https://ohara-lab-su.github.io/cobotta2/tutorials/install_client.html) 導入
- [電子天秤サーバ (ese774)](https://ohara-lab-su.github.io/aandd_reader/tutorials/intro.html#a-ese774) の導入
- [電子天秤クライアント (ese774)](https://ohara-lab-su.github.io/aandd_reader/tutorials/intro.html#a-ese774) の導入0

使用者はロボットのプログラムも通信のプログラムも複雑なプログラムを書くことも理解することもなく、
[簡単なシーケンススクリプト](susanooo_robo.md)だけで操作が可能となる。

### スサノオ環境の構築: 研究室の学生向けのドキュメント 

おそらく、cobottaやスサノオのシステムの導入より、サーバーPCとpython環境などの環境構築が大変な障壁になる。以下にに学生の試行錯誤の記録を記す

- [学生が書いた学生向けドキュメント (研究室内部doc)](https://github.com/shimane-dev/docs/tree/main/cobotta_setup/ohara_lab.md)
- [学生が書いた学生向けドキュメント (公開を目指している途中doc)](https://github.com/shimane-dev/docs/tree/main/cobotta_setup/cobotta_setup.md)
 
## スサノオ: docs

以下は各機器ごとに制御プログムと
スサノオに対応したデバイスサーバーが公開されている。そのドキュメントである。
機器制御側は基本的に全てスサノオとは独立して記述してあるために、
他の機器制御フレームからでもそのまま使える

- 電子天秤制御class: [aandd_reader](https://ohara-lab-su.github.io/aandd_reader)
- ロボット制御class: [cobotta](https://ohara-lab-su.github.io/cobotta2)
- ロボット制御class: UR3e
- ロボットGUI: [cobotta_joypad (GUI)](https://ohara-lab-su.github.io/cobotta2_joypad)
- 二次元検出機class: MiniPIX
- 通信Frame: [ese774 frame](https://ohara-lab-su.github.io/ese774_frame) (SPring-8 BL774互換風味)
- 通信Frame: [grpc frame](https://ohara-lab-su.github.io/grpc_frame)
- 通信Frame: TANGO frame
- 通信Frame: DDS frame
- ロガーclass: [x_logger](https://ohara-lab-su.github.io/x_logger/)

## スサノオ: source (2026/03/03 アクセス制限)

- 電子天秤制御clss: [aandd_reader](https://github.com/ohara-lab-su/aandd_reader/)
- ロボット制御clss: [cobotta](https://github.com/ohara-lab-su/cobotta2/)
- ロボット制御class: UR3e
- ロボットGUI: [cobotta_joypad (GUI)](https://github.com/ohara-lab-su/cobotta2_joypad/)
- 二次元検出機class: MiniPIX
- 通信Frame: [ese774 frame](https://github.com/ohara-lab-su/ese774_frame/)
- 通信Frame: [grpc frame](https://github.com/ohara-lab-su/grpc_frame/)
- 通信Frame: TANGO frame
- 通信Frame: DDS frame
- ロガーclass: [x_logger](https://github.com/ohara-lab-su/x_logger/)

## スサノオ: alpha段階 & 支援page (2026/03/03 アクセス制限)

- webカメラ制御: [camera_control](https://github.com/shimane-dev/web_camera) webカメラ画像を gRPC 転送するだけ
- websocketによるリアルタイム通信

## データ解析: source (2026/03/03 アクセス制限)

スサノオを用いて実験データーが得られた後は、そのデータを解析する必要がある。
ここではそのための手法として、第一原理計算を軸にして、機械学習ポテンシャル、古典分子動力学、逆モンテカルロ法などの
計算よるシミュレーションプログラムをまとめている。それらのプログラム開発とその解析プログラムなどの提供する。

- [Power スペクトル (using lammps トラジェトリ) 計算コード](https://github.com/kengo-nakada/md_analysis) MD解析支援project
- [x_poscar](https://github.com/shimane-dev/x_poscar) VASP 構造と Bader 電荷密度とMD関係の解析支援クラスライブラリおよびその使用例
- [周波数解析](https://github.com/shimane-dev/x_frequency) ゼロクロッシング法による周波数推定とSynchrosqueezing Transform (SST) による周波数セグメント検出
- [COHP にる結合解析](https://github.com/shimane-dev/x_lobster)
- [ワニエ関数による局在化軌道解析 (結合解析)]()
- [ワニエ関数による局在化軌道解析 (電荷のずれ)]()
- [webPDF local](https://github.com/kengo-nakada/local_pdf)
- [RMC-DFT](https://github.com/shimane-dev/rmc_dft) RMC/DFTに関するクラスライブラリとRMC-DFT計算コード
- [SAE](https://github.com/shimane-dev/sae) DFT計算と結晶構造と群論に関して支援ツール集(古すぎるのでほぼ死亡)
- [vasp1](https://github.com/shimane-dev/vasp1) VASP 支援スクリプト集
- [bader1](https://github.com/shimane-dev/bader1) Bader 支援スクリプト集
- [真空層 関連ツール](https://github.com/shimane-dev/change_lattice_constant)
- [構造の結合 ツール](https://github.com/shimane-dev/merge_cells)
- [lammps to vasp](https://github.com/shimane-dev/lammps_to_vasp)
- [rote クラスター](https://github.com/shimane-dev/rotate_cluster) クラスター回転
- [VCA (仮想結晶近似)](https://github.com/shimane-dev/make_vca) 仮想結晶近似
- [SQS を用いた構造作成・計算]()
- [表面構造作成支援(突貫)](https://github.com/shimane-dev/make_surface)
- [機械学習ポテンシャル ACE](https://github.com/kengo-nakada/ace_env)
- [機械学習ポテンシャル SNAP]()
- [機械学習ポテンシャル GAP]()
- [全電子計算手法(FLAPW)によるDFT計算手法開発](https://github.com/kengo-nakada/flapw) (HiLAPW基盤から、FLEUR/exting基盤へ移行中)
- キュリー温度の計算コード開発

## データ解析: docs

計算手法の基礎とその応用について

- [第一原理計算の基礎知識](abinit/intro/intro.md)
- [第一原理計算の選び方 (プレゼン資料)](https://support.spring8.or.jp/Doc_workshop/PDF_20150728/5.nakada.pdf)
- [実空間差分法によるXANESスペクトル計算の方法](https://support.spring8.or.jp/assets/materials/20230309_1.koide.pdf)
- [実習](https://support.spring8.or.jp/assets/materials/190228_5.nakada.pdf)
- 遍歴電子モデルによる強磁性発現機構
 

## 古い記事へのリンク

- DARUMA project (2019.12 プロジェクト更新は無くなりました。その時点でのproject内容)
- [計算関係の役立ちリンク](abinit/index.md)

## 主な開発者
1. K.Ohara
2. K.Kobayashi
3. K.Nakada