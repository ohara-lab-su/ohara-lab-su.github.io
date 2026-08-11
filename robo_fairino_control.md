# FAIRINO の制御アーキテクチャ・SDK・通信 I/F

[return](index.html#fairino)

FAIRINO は
Robot Arm / Control Box、
WebAPP / Teach Pendant、
Controller 上の Lua program、外部 PC 用 SDK、
ROS / ROS2、fieldbus を分けて考えると構造が分かりやすい。
特に公式 Python SDK 自体が公開されていることが、
PC ベースの研究用途では大きな特徴となる。

## 制御系の責務

```text
Robot Arm
   ↑
Control Box / motion control
   ↑
   ├─ WebAPP / Teach Pendant ── 教示・Jog・設定・program 操作
   ├─ Lua program ── Controller 上での自律実行
   ├─ FAIRINO SDK ── Python / C++ / C# / Java
   ├─ status feedback ── 状態データ取得
   └─ fieldbus ── PLC / 設備連携
```

## WebAPP / Teach Pendant

FAIRINO の標準操作環境では WebAPP が重要な位置を占める。
Controller と同一 network 上の PC 等から browser で接続し、
Jog、教示点、I/O、parameter、program の作成・実行などを行える。
これは外部 PC SDK とは異なり、robot operator / programmer 向けの標準操作環境である。

## Lua program

Controller 上で実行する robot program には Lua が用いられる。
Lua program は Controller 上で自律実行される program 層であり、
外部 PC SDK とは別物である。

SDK からは Lua file の upload / download、
program load / run / pause / resume / stop 等も操作できるため、
PC 側 application は「motion を直接 API で指示する」方法と「Controller
上の Lua program を管理・実行する」方法の双方を選択できる。

## 公式 SDK

FAIRINO は Python、C++、C#、Java の公式 SDK を GitHub で公開している。

* [FAIRINO - GitHub](https://github.com/FAIR-INNOVATION)
* [FAIRINO Python SDK](https://github.com/FAIR-INNOVATION/fairino-python-sdk)
* [FAIRINO C++ SDK](https://github.com/FAIR-INNOVATION/fairino-cpp-sdk)
* [FAIRINO C# SDK](https://github.com/FAIR-INNOVATION/fairino-csharp-sdk)
* [FAIRINO Java SDK](https://github.com/FAIR-INNOVATION/fairino-java-sdk)

Python SDK では `Robot.RPC(robot_ip)` を入口として Controller と接続し、
Joint / Cartesian motion、
Jog、
Servo motion、
I/O、
state、
force control、
peripheral control 等を API として扱える。

## SDK は無料か / OSS か

公式 `fairino-python-sdk` repository は Apache License 2.0 で公開されている。
したがって少なくともこの Python SDK は、ソースを確認・利用・改変できる OSS と明確に扱える。

メーカーが公式 SDK の source を GitHub に出しているため、
Universal Robots における `ur_rtde`
のように「公式 protocol を第三者 library で使いやすく包む」ことを前提にしなくてもよい。研究用途で独自 Python device class を作る場合にはかなり扱いやすい。

## 通信 I/F

SDK の RPC I/F のほか、
robot state feedback、
Modbus TCP、
PROFINET、
EtherCAT 等の I/F が存在する。
これらは目的が異なる。

```text
RPC SDK              : PC application から robot API を呼ぶ
state feedback        : robot state の連続取得
Lua program           : Controller 上で robot sequence を実行
Modbus / PROFINET 等  : PLC・設備との接続
```

したがって Modbus があるから SDK が不要という関係ではない。
PLC から設備 sequence の一部として扱う場合と、
PC から robot motion API を利用する場合では責務が異なる。

## ROS / ROS2

FAIRINO は ROS1 / ROS2 の公式 repository も公開している。

* [FAIRINO ROS](https://github.com/FAIR-INNOVATION/frcobot_ros)
* [FAIRINO ROS2](https://github.com/FAIR-INNOVATION/frcobot_ros2)

ROS2 を利用する場合には FAIRINO SDK / Controller API の上に
ROS2 service、MoveIt2 等を構築する形になる。

## `ur_rtde` のような第三者 library はあるか

FAIRINO では、
著名な第三者 wrapper を探す必要性そのものが比較的小さい。
公式 Python SDK が Apache-2.0 で公開されているためである。

つまり UR では

```text
UR official RTDE + URScript
        ↓
ur_rtde (third party)
        ↓
Python / C++ application
```

という選択が有力なのに対し、FAIRINO では

```text
FAIRINO official Python SDK
        ↓
Python application
```

をそのまま採用できる。
第三者 package は存在し得るが、
公式 SDK を置き換える事実上の標準 library は2026年8月時点では確認できない。

## スサノオで扱う場合

スサノオでは公式 Python SDK を device class の下位 driver として直接利用する構成が自然である。

```text
SUSANOO device class
        ↓
FAIRINO official Python SDK
        ↓
RPC / Controller communication
        ↓
Control Box
        ↓
Robot Arm
```

Python SDK が Apache-2.0 で公開されているため、
API の挙動や実装を確認しながら device class を設計できる点は大きい。
