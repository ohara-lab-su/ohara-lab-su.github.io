# Dobot の制御アーキテクチャ・SDK・通信 I/F

[return](index.html#dobot)

Dobot の CR / CRA 系を PC から扱う場合、Robot Arm、Controller、DobotStudio Pro、Controller 上の program、公開 TCP/IP protocol、公式 Python wrapper、ROS / ROS2、PLC 用通信を分けて考える必要がある。Dobot の特徴は、外部 PC 用 TCP/IP protocol と、その Python 実装の双方を追いやすいことである。

## 制御系の責務

```text
Robot Arm
   ↑
Controller / motion control
   ↑
   ├─ DobotStudio Pro ── 教示・Jog・設定・program 操作
   ├─ Controller program ── Controller 上での自律実行
   ├─ TCP/IP API ── PC からの remote control
   ├─ official Python wrapper
   └─ Modbus 等 ── PLC / 設備連携
```

## DobotStudio Pro / TP

DobotStudio Pro は Enable、Jog、教示点、Tool / User coordinate、I/O、
global variable、program 作成・実行等を行う標準操作環境である。
これは robot operator が使用する教示・programming 層であり、
外部 PC から socket で robot を操作する TCP/IP API とは別の責務を持つ。

## Controller 上の program

Dobot の Controller 上では robot program / script を実行できる。
Lua 系 script を利用する世代もあり、Controller 上で sequence を自律実行する経路と、
PC から TCP/IP command を逐次送信する経路は分けて考える必要がある。

## 公開 TCP/IP protocol

CR / Nova 系では Controller 自身が TCP server となり、
外部 PC が socket connection を張って command を送る。
管理 command、motion command、real-time feedback が port / connection ごとに分離されている。

公式 Python repository でも main thread が
control port、
motion port、
feedback port にそれぞれ接続する構成になっており、
Controller 側の責務分離をそのまま反映している。

代表例として V3 系では
Dashboard / control、
motion、feedback を別 connection として扱う。
使用 port や packet layout は Controller / protocol version に依存するため、
実機 version に対応する protocol document を確認する必要がある。

## 公式 Python library

Dobot は公式 GitHub Organization `Dobot-Arm` を公開している。

* [Dobot-Arm - GitHub](https://github.com/Dobot-Arm)
* [Dobot TCP-IP-Python-V3](https://github.com/Dobot-Arm/TCP-IP-Python-V3)

`TCP-IP-Python-V3` は
CR / Nova の V3 系 Controller を対象とした公式 Python wrapper である。
README では Dobot TCP/IP control protocol に従い、
Python socket で robot terminal に TCP connection を作り、
使いやすい API として公開する SDK と説明されている。

`dobot_api.py` には Controller 管理、
motion、feedback 等の処理が class としてまとめられており、
独自 device class を作る際にも通信構造を把握しやすい。

## SDK / library は無料か / OSS か

公式 `TCP-IP-Python-V3` repository は MIT License で公開されている。
したがって、この公開 Python library は無料で source を利用・改変できる OSS と明確に扱える。

通信 protocol そのものも公開されているため、
公式 wrapper を使わず独自 socket client を実装することも原理的には可能である。
ただし通常は version 差や packet handling を吸収するため、
公式 wrapper を基盤とする方が保守しやすい。

## ROS / ROS2

Dobot は ROS / ROS2 関連 repository も公式に公開している。

* [Dobot TCP-IP ROS](https://github.com/Dobot-Arm/TCP-IP-ROS-6AXis)
* [Dobot 6Axis ROS2 V4](https://github.com/Dobot-Arm/DOBOT_6Axis_ROS2_V4)

ROS / ROS2 は TCP/IP 制御層の上に robot model、
node、MoveIt 等を構築する上位 layer と考えるとよい。

## Modbus / 設備通信

PLC・設備連携には Modbus 等を利用できる。
これは PC から motion API を呼ぶ TCP/IP remote control とは目的が異なる。

```text
TCP/IP API : PC から robot motion / state を直接扱う
Modbus     : PLC・設備 sequence との連携
```

## `ur_rtde` のような第三者 library はあるか

第三者 Python package として `DobotTCP` 等が存在する。

* [DobotTCP - PyPI](https://pypi.org/project/DobotTCP/)

ただし Universal Robots と異なり、
Dobot 自身が TCP/IP protocol と MIT License の Python wrapper を公開している。
そのため第三者 library が事実上必須になる状況ではなく、
`ur_rtde` と同じ位置付けの圧倒的な標準第三者 library は2026年8月時点では確認できない。

独自 device class の基盤としては、まず公式 `TCP-IP-Python-V3` を評価するのが自然である。

## スサノオで扱う場合

スサノオでは次の構成が単純である。

```text
SUSANOO device class
        ↓
Dobot official TCP-IP-Python-V3
        ↓
TCP/IP
        ↓
Dobot Controller
        ↓
Robot Arm
```

公式 Python wrapper が薄い TCP/IP wrapper であり source も MIT で公開されているため、必要ならば protocol level まで追跡して device class の挙動を確認できる。
