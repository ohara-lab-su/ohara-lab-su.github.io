# Universal Robots の制御アーキテクチャ

Universal Robots の制御を理解するには、
「実際にロボットを動かしている制御はどこにあり、
それぞれの I/F がその制御にどう接続するか」を見る必要がある。

## Robot Arm と Control Box

UR3e の公式ユーザーマニュアルでは、
システムは Robot Arm、Control Box、
Teach Pendant から構成されると説明されている。
**Robot Arm** は 6 つの joint を持つ機械部分であり、
各 joint の動きを協調させて Robot Arm を動かすのは controller である。
Control Box にはその controller と、外部接続ポート、I/O が収められている。

したがって、Robot Arm が単独で軌道を生成しているわけではない。
外部から見たハードウェア上の境界は、
Robot Arm が実際の actuator / sensor を持つ機械側、
Control Box がそれらを統括する controller 側である。

**URControl** は Control Box 内の Embedded PC 上で動作する
**low-level robot controller** として Universal Robots の Script Manual に記載されている。
一般ユーザーが利用する URScript や各種通信 I/F は、この **URControl** を通して実際のロボット制御へ接続される。

URControl よりさらに下には、軌道生成、joint 制御、サーボ、モータ・センサとのやり取りが存在する。
しかし、**その内部 I/F は一般ユーザー向けの外部 API として公開されていない**。
したがって、PC から UR を制御するときに外部から直接触れる最も低い公開境界は、
**URControl** が公開する **Script 実行系**と通信 I/F である、
と考えるのが実用上分かりやすい。

## Teach Pendant と PolyScope

Teach Pendant は Control Box に接続された操作端末であり、
その画面上で動作する GUI が PolyScope である。
公式ユーザーマニュアルは PolyScope を、Robot Arm を操作し、
ロボットプログラムを作成・読み込み・実行するための GUI として説明している。

ここで重要なのは、
TP が Robot Arm の motor driver を直接操作しているわけではないことである。
TP 上でユーザーが waypoint や Move node を作成し、Play を押すと、
そのプログラムは Control Box 側のロボット制御系で実行される。
PolyScope は「ロボットそのものの制御器」ではなく、
controller に対する上位の操作・プログラミング環境である。

Universal Robots は **URScript** を Robot Controller の Script 言語として公開している。
**PolyScope** で構成された動作も、
外部 PC から直接送信した URScript も、
**最終的には URControl 上の Script 実行系からロボット動作へ接続される**。
`movej`、`movel`、`servoj`、`speedj` などはこの **URScript 側の motion command であり**、
これらを URControl が実行して下位の制御へ渡す。

この意味では DENSO WAVE の TP / WINCAPS と PacScript の関係に近い。
TP は人間向けの操作・教示環境、S
cript は controller 上で実行されるロボット言語、その下に実際の motion control がある、という階層である。

## 外部 PC からの制御

Universal Robots は外部 PC から controller に接続する複数の I/F を公開している。
これらは同じ責務ではない。

**Primary / Secondary Interface** は URScript program や controller の**情報を扱う I/F** であり、
外部 PC から URScript を controller に送信する経路として利用できる。
この場合、**PolyScope を経由せずに URScript 実行系**へ入る。

**Dashboard Server** はロボットプログラムの load / play / stop、power、brake release など、
controller の運転状態を管理するための I/F である。
ロボット軌道を記述するための I/F ではない。

**RTDE** はさらに性質が異なる。
RTDE は外部 application と UR controller の間で、
controller が公開する変数を双方向に同期する公式 I/F である。
joint や TCP の状態、robot mode、safety、I/O、汎用 register などを読み出すことができ、
外部からは digital / analog output、speed slider、汎用 input register などを書き込むことができる。

つまり **RTDE client は controller と直接通信**しており、監視専用ではない。
しかし、RTDE の標準 input field に `movej`、`movel`、`servoj` のような motion command が存在するわけでも、
`target_q` をそのまま外部から書き込めば joint servo の目標値になるわけでもない。
RTDE は「**controller が公開した値を PC と交換する I/F**」であり、その値をどのロボット動作に結び付けるかは別の責務である。

## 公式 RTDE で動作を作る場合

Universal Robots は
RTDE protocol の reference implementation として Python の **RTDE Client Library** を公式 GitHub で公開している。
これは **RTDE protocol を使って controller と通信するための client library である**。

公式 repository には `example_control_loop.py` という robot motion の例もある。
ここで重要なのは、この example が PC 側の RTDE client だけで完結していない点である。
README は、対応する `rtde_control_loop.urp` を robot にコピーし、
Python client と robot program を組み合わせて実行するよう指示している。

この構成を **「RTDE の後ろに別の通信層がある」と理解するのは誤り**である。
PC の RTDE client はすでに UR controller と直接通信している。
robot-side program の役割は通信ではなく、
RTDE で controller に書き込まれた値を、どの robot motion に変換するかを定義することである。

つまり、公式 RTDE を使った motion example は、
PC 側が制御量を計算して RTDE input を更新し、
controller 側の program がその値を robot motion の意味へ変換する協調構成になっている。

## Universal Robots の公開アーキテクチャとして見る

以上から、UR の外部制御は「TP と PC がまったく別のロボット制御器を叩いている」構造ではない。

通常運転では PolyScope が人間向けのプログラム作成・実行環境となり、
その結果が URScript / URControl を通して Robot Arm を動かす。
外部 PC から URScript を直接送る場合は PolyScope を飛ばして同じ Script 実行系へ入る。
RTDE を利用する場合は、PC が UR controller の公開変数を直接読み書きし、
必要であれば controller-side program と組み合わせてその値を motion に結び付ける。

したがって、Universal Robots の構造を説明するときには、
PolyScope、URScript、RTDE を同じ階層の「制御方法」として横並びにするのではなく、
PolyScope は上位 GUI、
URScript は controller 上のロボット言語、
RTDE は controller と外部 application の双方向データ I/F として責務を分けて理解する必要がある。

## 参考資料

- Universal Robots, UR3e User Manual / PolyScope 5
  https://www.universal-robots.com/manuals/
- Universal Robots, Connecting to URControl
  https://www.universal-robots.com/manuals/EN/HTML/SW10_11/Content/prod-scriptmanual/all_scripts/Connecting_to_URControl.htm
- Universal Robots, URScript
  https://www.universal-robots.com/developer/urscript/
- Universal Robots, Real-Time Data Exchange (RTDE) Guide
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-guide.html
- Universal Robots, RTDE Client Python Module
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-python-client-guide.html
- Universal Robots, RTDE Python Client Library
  https://github.com/UniversalRobots/RTDE_Python_Client_Library
