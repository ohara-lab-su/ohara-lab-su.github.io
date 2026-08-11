# Universal Robots の制御構造と公式 I/F

Universal Robots の制御を理解するには、
ロボット本体の制御、TP / PolyScope、URScript、外部通信 I/F を分けて考える必要がある。

特に RTDE については、
**Universal Robots 公式 RTDE** と
第三者ライブラリ **SDU Robotics `ur_rtde`** を混同してはいけない。

## 1. Robot Arm / Control Box / Teach Pendant

Universal Robots は Robot Arm、Control Box、Teach Pendant から構成される。

Control Box 内の Embedded PC 上では **URControl** が動作する。
Universal Robots の公式資料では、URControl は Control Box 上で動作する
low-level robot controller と説明されている。

URControl より下位には、実際の軌道生成、関節制御、モータ・センサを扱う内部制御が存在する。
ただし、その内部 API は一般ユーザー向けの Ethernet 制御 API として公開されていない。

外部ユーザーから見た主要な公開境界は、
URControl、URScript、および Universal Robots が公開する各通信 I/F である。

- Universal Robots, Connecting to URControl  
  https://www.universal-robots.com/manuals/EN/HTML/SW10_11/Content/prod-scriptmanual/all_scripts/Connecting_to_URControl.htm

## 2. TP / PolyScope と URScript

Teach Pendant 上の **PolyScope** は、
ロボットの操作、教示、プログラム作成・実行を行う上位環境である。

PolyScope は URControl そのものではない。
Universal Robots は、PolyScope 上で行われる操作が URScript command に変換され、
ロボット側で実行されると説明している。

したがって TP からの通常操作では、

- TP / PolyScope が上位の操作・教示を担当する
- URScript がロボット動作を記述する
- URControl が URScript command を実行して実際のモーション制御へ接続する

という責務分担になる。

`movej`、`movel`、`servoj`、`speedj` などは URScript の motion command であり、
モータドライバそのものではない。
これらを URControl が解釈・実行し、下位のロボット制御へ渡す。

- Universal Robots, URScript  
  https://www.universal-robots.com/developer/urscript/
- Universal Robots, Script Manual / Motion  
  https://www.universal-robots.com/manuals/

## 3. 外部 PC から URScript を直接送る経路

Universal Robots は、外部 PC から URControl へ接続する TCP/IP I/F を公開している。
Primary / Secondary Interface などを利用すると、
PolyScope を介さず URScript program / command を送信できる。

この場合、

- TP / PolyScope から URScript を実行する経路
- 外部 PC から URScript を直接送信する経路

は入口こそ異なるが、どちらも URControl の URScript 実行系へ接続する。

### Evidence

- Universal Robots, Connecting to URControl  
  https://www.universal-robots.com/manuals/EN/HTML/SW10_11/Content/prod-scriptmanual/all_scripts/Connecting_to_URControl.htm
- Universal Robots, Communication Protocols  
  https://www.universal-robots.com/developer/communication-protocol/

## 4. Universal Robots 公式 RTDE

**RTDE (Real-Time Data Exchange)** は Universal Robots が公式に提供する、
外部 application と UR controller の間の双方向データ I/F である。

RTDE client は controller の状態を読むだけではなく、
controller が公開している入力項目へ値を書き込むこともできる。

代表的な入力には、

- digital / analog output
- speed slider
- general-purpose bit register
- general-purpose integer register
- general-purpose double register

などがある。

代表的な出力には、

- joint / TCP state
- target / actual position・velocity
- robot mode
- safety state
- I/O
- register

などがある。

したがって RTDE は「監視専用」ではない。
**PC から UR controller の公開入力へ直接書き込める公式の双方向 I/F** である。

一方で、標準 RTDE input field に、
`movej`、`movel`、`servoj` のような motion command 自体は定義されていない。
また、外部から joint target を標準 RTDE input として書けば、
そのまま URControl の軌道生成・サーボ指令になる、という I/F でもない。

ここは、

**RTDE client が controller を操作できること**

と、

**RTDE protocol 自体が汎用 motion command を持つこと**

を分けて理解する必要がある。

- Universal Robots, RTDE Guide  
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-guide.html
- Universal Robots, RTDE  
  https://www.universal-robots.com/developer/communication-protocol/rtde/

## 5. 公式 RTDE client でロボット動作を構成する場合

Universal Robots は公式の **RTDE Python Client Library** を公開している。
これは Universal Robots の公式リポジトリで公開されているオープンソース実装である。

公式リポジトリには robot motion を扱う control loop example がある。
この例では PC 側 RTDE client だけで完結せず、
対応する robot-side program (`rtde_control_loop.urp`) も使用する。

ここで重要なのは、
「RTDE client が制御していない」という意味ではない。

責務としては、

- PC 側 RTDE client が controller の RTDE input を更新する
- UR controller がその RTDE input を受け取る
- controller 側 program が、その値をどのロボット動作に使うかを定義する

という協調動作である。

つまり公式 RTDE は controller と直接通信している。
ただし、**RTDE で渡した数値をどの motion semantics に結び付けるかは、
controller 側の program / URScript が担当する**。

### Evidence

- Universal Robots, RTDE Python Client Library  
  https://github.com/UniversalRobots/RTDE_Python_Client_Library

## 6. 「公式 RTDE で低レベル制御できるか」

答えは、何を低レベル制御と呼ぶかで分ける必要がある。

公式 RTDE は、

- controller の状態を直接取得する
- controller の I/O や speed slider を直接書き換える
- controller の汎用 register を直接読み書きする

という意味では、明確に controller-level の公式制御 I/F である。

一方、

- joint target を標準 RTDE input として与える
- trajectory generator を直接呼び出す
- servo controller へ直接目標値を投入する

といった一般ユーザー向けの標準 RTDE motion I/F は公開仕様では確認できない。

したがって、

**公式 RTDE は controller に対する低次元の双方向 I/F ではあるが、
それ自体が汎用的なロボットモーション命令セットではない**

と整理するのが正確である。

## 7. 公式部分と第三者部分の境界

Universal Robots 公式として整理できる主なものは、

- Robot Arm
- Control Box
- URControl
- Teach Pendant / PolyScope
- URScript
- Primary / Secondary Interface
- RTDE protocol
- Dashboard Server
- Universal Robots 公式 RTDE Python Client Library

である。

一方、現在スサノオで使用している **SDU Robotics `ur_rtde`** は第三者 OSS である。

その違いについては
[公式 RTDE と SDU Robotics `ur_rtde`](ur_rtde_control.md)
に分けて記す。
