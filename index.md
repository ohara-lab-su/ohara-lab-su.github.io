# Ohara Lab
Software for data analysis and device control used in our research projects.  
[github](https://github.com/ohara-lab-su) / [docs](https://ohara-lab-su.github.io/) / [尾原研](https://ohara.mat.shimane-u.ac.jp/)

<!--
* Toc
{:toc}
-->

## スサノオプロジェクト docs

- 電子天秤制御: [aandd_reader](https://ohara-lab-su.github.io/aandd_reader)
- ロボット制御: [cobotta](https://ohara-lab-su.github.io/cobotta2)
- ロボットGUI: [cobotta_joypad (GUI)](https://ohara-lab-su.github.io/cobotta2_joypad)
- ロボット制御: UR3e
- 二次元検出機: MiniPIX
- 通信Frame: [ese774 frame](https://ohara-lab-su.github.io/ese774_frame) (SPring-8 BL774互換風味)
- 通信Frame: [grpc frame](https://ohara-lab-su.github.io/grpc_frame)
- 通信Frame: tango frame
- 通信Frame: DDS frame
- ロガー: [x_logger](https://ohara-lab-su.github.io/x_logger/)
 
## スサノオプロジェクト source (2026/03/03 アクセス制限)

- 電子天秤制御: [aandd_reader](https://github.com/ohara-lab-su/aandd_reader/)
- ロボット制御: [cobotta](https://github.com/ohara-lab-su/cobotta2/)
- ロボットGUI: [cobotta_joypad (GUI)](https://github.com/ohara-lab-su/cobotta2_joypad/)
- ロボット制御: UR3e
- 二次元検出機: MiniPIX
- 通信Frame: [ese774 frame](https://github.com/ohara-lab-su/ese774_frame/)
- 通信Frame: [grpc frame](https://github.com/ohara-lab-su/grpc_frame/)
- 通信Frame: tango frame
- 通信Frame: DDS frame
- ロガー: [x_logger](https://github.com/ohara-lab-su/x_logger/)

## スサノオプロジェクト alpha段階 & 支援page

- webカメラ制御: [camera_control](https://github.com/shimane-dev/web_camera) webカメラ画像を gRPC 転送するだけ
- websocketによるリアルタイム通信
 
## スサノオプロジェクト システムの概要

SPring-8 の BL774 互換(ese774)を用いた一連の計測システム**スサノオ**と読んでいる。

思想として、SPring-8 における MADOCA/DARUMA や ESRF の TANGO のようなフルスタック型の
プロトコル・フレームワークの開発設計はせずに **マイクロサービス** を軸としたコンパクトな
フレームを組み合わせる形をめざす。その意味では思想的にも SPring-8 BL774 互換でもある。
システムの中核となる通信フレームは、ターゲットとなるデバイスと目的の通信速度・フレークワークとの
結合をしやすいように、フレームを切り替えても同じように使えるようにしている。 **シンプルな透過型プロキシ**を用いる採用している。

- [基本: 方針/設計](susanoo_intro.md)

## スサノオプロジェクト インストール方法


## 第一原理計算関係 source (2026/03/03 アクセス制限)

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

## 第一原理計算関係 docs

- [基礎知識](abinit/intro/intro.md)
- [第一原理計算の選び方 (プレゼン資料)](https://support.spring8.or.jp/Doc_workshop/PDF_20150728/5.nakada.pdf)
- [実空間差分法によるXANESスペクトル計算の方法](https://support.spring8.or.jp/assets/materials/20230309_1.koide.pdf)
- [実習](https://support.spring8.or.jp/assets/materials/190228_5.nakada.pdf)

## 古い記事へのリンク

- DARUMA project (2019.12 プロジェクト更新は無くなりました。その時点でのproject内容)
- [DARUMA (spring8 サイト内)](http://daruma.spring8.or.jp/)
- [計算関係の役立ちリンク](abinit/index.md)

## 主な開発者
1. K.Ohara
2. K.Kobayashi
3. K.Nakada