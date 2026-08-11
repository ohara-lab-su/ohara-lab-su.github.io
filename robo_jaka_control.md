# JAKA の制御アーキテクチャ・SDK・通信 I/F

[return](index.html#jaka)

JAKA を PC から制御する場合、Robot Arm、Controller、JAKA App / TP、Controller 上のロボットプログラム、外部 PC 用 SDK、通信 protocol を分けて考える必要がある。特に SDK と通信 protocol は同じものではない。

## 制御系の責務

概念的には次のように整理できる。

```text
Robot Arm
   ↑
Controller / motion control
   ↑
   ├─ JAKA App / TP ── 教示・Jog・設定・program 操作
   ├─ Controller program ── Controller 上での自律実行
   ├─ JAKA SDK ── C/C++ / C# / Python からの API 制御
   └─ 外部通信 ── TCP/IP / gRPC / fieldbus
```

Robot Arm のサーボや各軸を実際に協調制御する責務は Controller 側にある。JAKA App はその上位の操作・教示環境であり、外部 PC 用 SDK は Controller の機能を API として呼び出す別経路である。

## JAKA App / TP

JAKA App はロボットの Jog、教示、座標系や I/O 等の設定、program の作成・実行、Controller の設定などを行う標準の操作環境である。SDK を使用する場合も App が不要になるわけではなく、Controller V3.2 以降では App 側で SDK account の password を設定し、control source を SDK に切り替える必要があると公式 SDK document に記載されている。

## Controller 上の program と外部 PC 制御

通常の robot program は Controller 側で実行される。一方、外部 PC から SDK を利用する場合は、PC 上の application が JAKA SDK API を呼び出し、Controller に motion や I/O 操作を要求できる。したがって「Controller 上に program を置いて実行する方法」と「PC から SDK で直接 API を呼ぶ方法」は別の制御形態である。

## 公式 SDK

JAKA は公式 SDK を提供しており、公式 document では C/C++、C#、Python をサポートする。Python では `jkrc` module を使用し、`jkrc.RC(ip)` で robot object を生成する。

代表的には以下を扱える。

* login / logout
* power / enable / disable
* Joint / Cartesian motion
* Jog
* Servo motion
* robot state
* I/O
* coordinate / tool 関連

公式 Python document では Linux で `libjakaAPI.so` と `jkrc.so`、Windows で `jakaAPI.dll` と `jkrc` を配置する構成が示されている。このため Python interface の外観は Python API であっても、その下位にはメーカー提供 native library が存在する。

* [JAKA SDK 公式 document](https://www.jaka.com/docs/ja/guide/V3/SDK/introduction.html)
* [JAKA SDK Python API](https://www.jaka.com/docs/ja/guide/V3/SDK/Python.html)
* [JAKA SDK English document](https://www.jaka.com/docs/en/guide/V3/SDK/introduction.html)

## SDK は無料か / OSS か

公式 document と公開 repository から、SDK を利用するための別売 runtime license を要求する記述は確認できない。一方で、Python SDK は `libjakaAPI.so` / `jakaAPI.dll` 等の native library を利用するため、「無料で取得・利用できる SDK」と「SDK 全体が OSS」は区別した方がよい。

JAKA 公式 GitHub Organization には SDK / ROS 関連 repository が存在するが、実機導入時には使用する Controller version と SDK package に付属する license / redistribution 条件を確認するのが安全である。

* [JAKA Robotics - GitHub](https://github.com/JAKARobotics)
* [JAKA official Python SDK - GitHub](https://github.com/JAKARobotics/jakasdk-python)
* [JAKA official C++ SDK - GitHub](https://github.com/JAKARobotics/jakasdk-cpp)

## TCP/IP と gRPC

JAKA は TCP/IP external control protocol を公開している。Controller 内に TCP server があり、代表的には次の port を利用する。

* `10001`: command の送信と Controller response
* `10000`: robot state data の受信

* [JAKA TCP/IP 制御 protocol](https://www.jaka.com/docs/ja/guide/V3/tcpip.html)

ただし SDK の通信方式は Controller / SDK 世代で異なる。公式 SDK document では SDK 2.2.x 以降が TCP/IP と gRPC に対応し、V3 Controller では gRPC を優先するよう記載されている。したがって JAKA SDK を単純な TCP socket wrapper と理解するのは適切ではない。

また Modbus TCP / RTU、EtherNet/IP、PROFINET 等の fieldbus は PLC や設備との接続を目的とする別レイヤーであり、PC 用 SDK と責務を混同しない方がよい。

## ROS / ROS2

JAKA は ROS / ROS2 関連資産も公式 GitHub で公開している。ROS2 を使用する場合は、Controller の API / SDK の上位に ROS2 node や MoveIt 系 I/F を構築する形になる。

* [JAKA ROS2 - GitHub](https://github.com/JAKARobotics/jaka_ros2)

## `ur_rtde` のような第三者 library はあるか

Universal Robots では公式 RTDE の上に SDU Robotics の `ur_rtde` が存在し、PC からの motion control で広く使われている。JAKA についても非公式 library は存在するが、2026年8月時点で `ur_rtde` と同程度に広く利用される事実上の標準第三者 library は確認できない。

例として PyPI には非公式 `libjaka` が存在する。

* [libjaka - PyPI](https://pypi.org/project/libjaka/)

しかし JAKA 自身が Python SDK と ROS2 資産を提供しているため、独自 device class の基盤としては、まず公式 SDK を利用するのが自然である。

## スサノオで扱う場合

スサノオの device class を作る場合には、JAKA App や Controller program を置換するのではなく、PC 制御 I/F である公式 Python SDK を下位 driver として包む構成が最も単純である。

```text
SUSANOO device class
        ↓
JAKA official Python SDK (jkrc)
        ↓
TCP/IP / gRPC
        ↓
JAKA Controller
        ↓
Robot Arm
```

Controller version による gRPC / TCP/IP の差を device class より下位の SDK に任せられることも、この構成の利点となる。
