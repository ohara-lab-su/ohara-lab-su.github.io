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

スサノオでは SPring-8 における [MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
ESRF の [TANGO](https://www.tango-controls.org/) のようなフルスタック型の
プロトコル・フレームワークの開発設計はせずに
**マイクロサービス** を軸としたコンパクトなフレームワークの組み合わせとして開発を進める。
システムの中核となる通信フレームは、
ターゲットとなるデバイスと目的の通信速度・フレークワークとの結合をしやすいように、
フレームを切り替えても同じように使えるようにする。
つまり基本は**シンプルな透過型プロキシ**を採用している。

<img src="fig/ese_774.004.png" width="70%" style="display:block; margin:auto;">

[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
互換としての立ち位置は、
公式に**BL774 REST server** のコードを基盤にしており、
get や post のルールを
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
側の真似をしているところである。
ただ、マネージメントやAPIセットにははまだ大きな規定や仕組みはない。
つまり774APIセットに対応しているわけではなく、
774 Basic System 未満である。

基本センスとしては、スサノオはフレームワーク側として API を統一整理する代わりに、
制御クラス側に API の規定は任せている。
つまり、透過型プロキシとして動的ディパッチを軸としたフレームであり、
制御クラス側の python の API がそのままクライアント上での API となる。
APIを揃える場合は制御クラス側で揃える。

これは、最初からデバイスサーバーを増やす前提のもとで設計されているためであり、
デバイスごとに基本となるAPIが異なるためだ。モーター系などすでに揃えるべきAPI
セットが固定なものを扱うことよりも、**多種多様なデバイスに対する対応の容易さ**の方を重視している。
いいかえると徹底的にミニマム志向で作られているともいえる。

- [基本: 方針/設計](susanoo_intro.md)

## スサノオ: 分散システム

スサノオでは [MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
[TANGO](https://www.tango-controls.org/)
のような本当の意味での分散システムは目指さない。
つまりサーバー・サーバー間通信を含めた意味で分散ではなく、
単純なサーバー・クライアント通信がベースのシステム構成とする。
ミニマムな実験支援系システムではそれほど本格的な分散システムは必要ないという判断が根底にあるからだ。
単純に [BL774](https://user.spring8.or.jp/sp8info/?p=42759)
型の互換であるからという理由もあるし、
設計・開発・保守メンテナンスをミニマムなコストで行うためである。

- [分散制御システム](susanoo_dcs.md)
- [スサノオのシステム](susanoo_system.md)
 
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
はメインとしては RestAPI を採用している。
これは大変遅い通信である。
しかし、webに立脚した技術体系の普及率と裾の広さ、簡便さには捨てがたく、
RestAPI に立脚することは、遅い機器制御においてはそれほど間違っていない。
開発効率と一般的で普及しているシステムであることは何より大切である。
同システムのサブセットであるスサノオも同等である

<img src="fig/ese_774.005.png" width="70%" style="display:block; margin:auto;">

それに対して、
それなりに高速な通信やイベント起動などの高度な通信が必要な場合も存在する。
この場合は、
[MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
[TANGO](https://www.tango-controls.org/) のような ZMQベースの通信が
圧倒的に有利になってしまうが、
同じ web技術の範囲でも gRPC ならば、バイナリ通信であり、選択肢としてそれほど悪くない。
(実はデンソーウェーブのORiN3でも gRPC に進んだのはある意味トレンドを彼らなりに、採用は遅いにしても、
追いかけた結果と評価できなくもない)
そのような gRPC を web通信のカテゴリの一種として、スサノオでは選択可能になっている。
この gRPC への拡張は本家BL774でも行われており、
BL774対応の一つでもある

分散環境というチョイスでは、世界的標準になりつつあるのは、DDS であり、
最初から DDS ベースで設計するというのは一つの手段として正解である気もしないでもない。
その視点で最初から DDS ベースで作ったものが、ロボットベースでよく使われる、ROS2 という
フレームワークである。

webベースであるか？DDSのような本格的な分散ベースか？の選択肢となるが、
スサノオでは BL774 ベースであるため、DDSベースはとりあえずはコアライブラリとしては除外する。
DDSとの接続はロボットを使う上では必須であるため、枠組みに入れていく形にする。

## スサノオ: インストール方法

スサノを構成する基本モジュールを導入する

- [スサノオの基本構成のインストール](susanoo_install.md)

次にデバイスサーバーを導入する必要がある。 
後述する、すでに開発済みのデバイスサーバーを使うだけならば次のセクションは飛ばして良い

## スサノオ: デバイスサーバー作成

スサノオは、サーバー・クライアント型のシンプルな分散システムである。
そのため、使用するにあたっては、デバイスサーバの形でデバイス(実験機器)側の
サーバーを立ち上げる必要がある。
スサノオはほぼ完全な透過型プロキシであるため、
基本は制御クラス(デバイスクラス)があればデバイスサーバー・クライアント作成はほぼ終わる。

1. スサノオに関係なくデバイス制御クラス(プログラム)を書く。 
2. スサノオフレームを用いて、デバイス制御プログラムからデバイスサーバーを作る (**わずか数行**)
3. スサノオフレームを用いて、デバイスサーバーの**API定義**を記述する (ある意味これがサーバを作る作業の本丸だが、実はただのコピペ作業)
   pydantic/OpenAPI という一般的なweb技術とその記法で記述されており スサノオが用意するクライアントを使わなくてもデバイスサーバーを使うことができる
4. スサノオフレームにより自動で作られるデバイスクライアント用いて、 実験制御プログラムを書く。
 
この4つのステップで機器制御・開発を行う。
4の作業をより簡略化するために、1 をうまく作ると良い。すでに我々他用意しているものはこの後のセクションにある。
これらの具体的作業を下記に記す

- [スサノオに対応するデバイスサーバの作成](susanoo_device_server.md) (自分でデバイスサーバーを作る場合)

実際にデバイスサーバーを作る例を下記に示す。
すでにデバイスクラス(機器制御用のクラスが存在するとき)にデバイスサーバーまでを作る例である。

- [cobotta制御サーバ (ese774)](https://ohara-lab-su.github.io/cobotta2/tutorials/install_server.html) の導入
- [cobotta制御クライアント (ese774)](https://ohara-lab-su.github.io/cobotta2/tutorials/install_client.html) 導入
- [電子天秤サーバ (ese774)](https://ohara-lab-su.github.io/aandd_reader/tutorials/intro.html#a-ese774) の導入
- [電子天秤クライアント (ese774)](https://ohara-lab-su.github.io/aandd_reader/tutorials/intro.html#a-ese774) の導入0

クライアントコードは async 対応であるが、厳密にはサーバー側の制御 class が非同期に正しく対応してないと
唯のハッタリ async となる。
もともとサーバーとクライアントで分離しているために、
同期非同期はそれぞれの責務となる。
クライアント側の責務は async と sync には正しく対応している。
問題はサーバ側、つまり機器側の対応になる。
つまり、async で非同期並行処理っぽく見せていて、
サーバー側はコテコテのマルチスレッドやマルチプロセスで、非同期並列処理となっている場合がありうる。
注意が必要である。この非同期性の担保・実装は個別のデ**バイスサーバーの責務**となる。
原理的に不可能なデバイスも多い。

## スサノオ: 作成済みデバイスサーバ docs

以下は各機器ごとに制御プログムと
スサノオに対応したデバイスサーバーが公開されている。そのドキュメントである。
機器制御側は基本的に全てスサノオとは独立して記述してあるために、
**他の機器制御フレームからでもそのまま使える**。
スサノオを使われない場合でも下記の制御クラスはぜひ使っていただければと思う。

- 電子天秤制御class: [aandd_reader](https://ohara-lab-su.github.io/aandd_reader)
- ロボット制御class: [cobotta](https://ohara-lab-su.github.io/cobotta2)
- ロボット制御class: UR3e
- ロボットGUI: [cobotta_joypad (GUI)](https://ohara-lab-su.github.io/cobotta2_joypad)
- 二次元検出機class: [MiniPIX](https://ohara-lab-su.github.io/mini_pix) 開発始め
- 通信Frame: [ese774 frame](https://ohara-lab-su.github.io/ese774_frame) (SPring-8 BL774互換風味)
- 通信Frame: [grpc frame](https://ohara-lab-su.github.io/grpc_frame)
- 通信Frame: [TANGO frame](https://ohara-lab-su.github.io/tango_frame) (beta-stage)
- 通信Frame: DDS frame
- ロガーclass: [x_logger](https://ohara-lab-su.github.io/x_logger/)

## スサノオ: 作成済みデバイスサーバ source (2026/03/03 アクセス制限)

- 電子天秤制御clss: [aandd_reader](https://github.com/ohara-lab-su/aandd_reader/)
- ロボット制御clss: [cobotta](https://github.com/ohara-lab-su/cobotta2/)
- ロボット制御class: UR3e
- ロボットGUI: [cobotta_joypad (GUI)](https://github.com/ohara-lab-su/cobotta2_joypad/)
- 二次元検出機class: [MiniPIX](https://github.com/ohara-lab-su/mini_pix)
- 通信Frame: [ese774 frame](https://github.com/ohara-lab-su/ese774_frame/) 開発始め
- 通信Frame: [grpc frame](https://github.com/ohara-lab-su/grpc_frame/)
- 通信Frame: [TANGO frame](https://github.com/ohara-lab-su/tango_frame) (beta-stage)
- 通信Frame: DDS frame
- ロガーclass: [x_logger](https://github.com/ohara-lab-su/x_logger/)

## スサノオ: デバイスサーバのサルベージ

今後、隙をみて過去に作ったことのあるデバイスクラスを移植していく
 
- 2D検出器: PILATUS
- 2D検出器: PerkinElmer
- 2D検出器: Rigaku HyPix
- 2D検出器: Andor Zyla
- 2D検出器: Andor iKonL
- 2D検出器: HiPic 9.x
- 2D検出器: HiPic 8.x
- 2D検出器: Merlin
- 2D検出器: Hexitec
- 2D検出器: Lambda
- DSP: TechnoAP APN504
- 光電子分光: sientaomicro
- SIENTA: SESソフト制御
- ラマン: LightField automation
- ラマン: LightField GUI ctrl
- DAQ: USB-USB6000/6003
- DAQ: NI-USB6210
- DAQ: NI-6612
- DAQ: NI-6602
- DAQ: TTL
- DIO/AIO: PXI:NI-4492
- Motor: ツジ電子 PM16C-04XDL/16
- Motor: ツジ電子 UPM2C-01
- Motor: SIGMA TECH FC-111/511/911
- Motor: MDrive (ScatterLessSlit)
- Motor: Arduino sg92 サーボ
- Motor: IAIサーボモータRA4R
- Counter: ツジカウンタ
- Counter: ミツトヨ リニアスケール用 KA-12,200 カウンター
- Counter: NI-6602
- DMM: Kethley デジタルマルチメータ 2701
- DMM: ADCMT デジタルマルチメータ 7352A
- 温調: Cryo-con Model 24C
- 温調: Simaden FP23 (リガク temperature ctrler)
- 温調: リガク プログラム温度コントローラー(PTC-20/20A/20C)
- 温調: チノー温調コントローラー chino KP1000C
- 温調: チノー温調コントローラー chino DB1000
- ポテンショスタッド Gamry 制御
- ポテンショスタッド EmStat4M 制御
- MFC: FCST1000
- センサー: Arduino MQ8ガスセンサー

## スサノオ: 実験用スクリプトを作る

実験制御をするエンドユーザーにって簡便であること。これがスサノオの究極的な目的である。
スサノオ使用者はロボットのプログラムも通信のプログラムも複雑なプログラムを書くことも理解する必要もない。
[簡単なシーケンススクリプト](susanoo_robo.md)だけで操作が可能となる。python は多少は知っておく必要はある。

### スサノオ環境の構築: 研究室の学生向けのドキュメント 

おそらく、学生にとっては cobotta やスサノオのシステムの導入より、
サーバーPC と python 環境などの環境構築が大変な障壁になる。
以下にに学生の試行錯誤の記録を記す

<a href="https://w1769571594-yzx230902.slack.com/archives/C0AJHG8VBA5/">
<img src="fig/slack.png" width="20">
</a> [Ohara Lab Slack Robo Channel](https://w1769571594-yzx230902.slack.com/archives/C0AJHG8VBA5/)

- [学生が書いた学生向けドキュメント (研究室内部doc)](https://github.com/shimane-dev/docs/tree/main/cobotta_setup/ohara_lab.md)
- [学生が書いた学生向けドキュメント (公開を目指している途中doc)](https://github.com/shimane-dev/docs/tree/main/cobotta_setup/cobotta_setup.md)
 
## スサノオ: その他alpha段階 & 支援page (2026/03/03 アクセス制限)

- webカメラ制御: [camera_control](https://github.com/shimane-dev/web_camera) webカメラ画像を gRPC 転送するだけ
- websocketによるリアルタイム通信

## データ解析: source (2026/03/03 アクセス制限)

スサノオを用いて実験データーが得られた後は、そのデータを解析する必要がある。
ここではそのための手法として、第一原理計算を軸にして、
機械学習ポテンシャル、古典分子動力学、逆モンテカルロ法などの
計算よるシミュレーションプログラムをまとめている。
それらのプログラム開発とその解析プログラムなどの提供する。

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
4. R.Hinohara