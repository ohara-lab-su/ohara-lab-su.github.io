# 公式 RTDE と SDU Robotics `ur_rtde`

Universal Robots の RTDE を調べると、
検索結果には Universal Robots 公式の RTDE Client と、
SDU Robotics の `ur_rtde` が混在して出てくる。
名称が非常に似ているため混同しやすいが、これは同じライブラリではない。

## Universal Robots 公式の RTDE

RTDE (Real-Time Data Exchange) は Universal Robots が controller に実装している公式の通信 I/F である。
外部 PC の RTDE client は TCP/IP で UR controller に接続し、recipe として選択した controller の変数を読み書きする。

Universal Robots の公式 RTDE Guide は、
RTDE の出力として robot、joint、tool、safety、I/O、general-purpose register などを挙げ、
入力として digital / analog output と general-purpose input register などを定義している。
したがって RTDE は controller の状態を読むだけの monitor I/F ではない。
PC から controller の公開入力値を書き換えることができる。

ただし、RTDE protocol 自体には `movej` や `movel` といった URScript の motion command はない。
RTDE が扱うのは controller が公開した data field である。外部 PC が RTDE で値を書き込むことと、
その値が robot motion としてどう解釈されるかは別の問題である。

Universal Robots 自身も RTDE の用途を「register の監視・変更」を中心とする protocol として整理している。
公式の「外部監視・制御のためのクライアントライブラリ」の説明では、Universal Robots 製の RTDE Client Library と、
デンマーク南部大学で開発された `UR RTDE` を明確に別のライブラリとして紹介している。

## Universal Robots 公式 RTDE Client Library

Universal Robots は公式 GitHub organization で `RTDE_Python_Client_Library` を公開している。
これは Universal Robots 公式 RTDE protocol の Python reference implementation であり、
BSD-3-Clause のオープンソースである。

この library は RTDE connection、recipe、data package の送受信を扱う。
公式 documentation の `example_control_loop.py` も、RTDE server に input / output recipe を設定し、
controller から読み取った値を処理した後、新しい値を controller に送る control loop として説明されている。

robot motion の example では、
PC 側の Python program とともに `rtde_control_loop.urp` を robot 上で実行する。
ここで `.urp` program は RTDE の代わりに通信しているのではない。
RTDE client はすでに controller と直接通信している。robot-side program は、
RTDE で受け取った値を robot motion に変換する controller-side logic を持つ。

この点を明確にすると、
公式 RTDE の責務は「controller との双方向の data I/F」であり、
robot-side program の責務は「その data を robot motion の意味にすること」である。

## SDU Robotics の `ur_rtde`

現在スサノオで使用している `ur_rtde` は Universal Robots 純正 SDK ではない。
**SDU Robotics、すなわち University of Southern Denmark 系で開発された第三者のオープンソースライブラリ**である。

これは私的な出所不明ライブラリという意味ではない。
Universal Robots 自身の開発者向けページでも、
Universal Robots 公式の RTDE Client Libraryとは別に、
「**UR RTDE — デンマーク南部大学で開発されたライブラリ**」として紹介されている。
ただし開発主体は Universal Robots ではないため、純正 SDK と呼ぶべきではない。

SDU `ur_rtde` は、Universal Robots 公式 RTDE protocol を利用しながら、
`RTDEControlInterface`、`RTDEReceiveInterface`、`RTDEIOInterface`
という高水準 API を提供する。
Receive と IO は RTDE の data field を扱う wrapper として理解しやすいが、Control は一段異なる。

SDU の公式 documentation は、
`RTDEControlInterface` を利用するには robot 上で control script が動作している必要があり、
その script は標準では自動 upload されると明記している。
つまり `RTDEControlInterface.moveJ()` は「Universal Robots 公式 RTDE protocol に `moveJ` packet がある」から動くのではない。

PC 側の `RTDEControlInterface` は RTDE register を利用して command と parameter を controller に書き込む。
robot 側で動作する SDU の control URScript がそれを読み、
`movej`、`movel`、`servoj` などの URScript motion command を実行する。
URControl はその URScript を通常の robot program と同様に実行し、
実際の Robot Arm を動かす。

したがって SDU `RTDEControlInterface` の実体は、
**Universal Robots 公式 RTDE を通信路として使い、
SDU が用意した controller-side URScript を組み合わせて PC 側の motion API を構築したもの**である。

## 公式 RTDE と SDU `ur_rtde` の違い

両者の違いは「公式 RTDE は本物、SDU は偽物」という意味ではない。
SDU `ur_rtde` が通信に使っている RTDE は Universal Robots 公式の RTDE そのものである。

違いは、どこまでを library の責務に含めているかである。

Universal Robots 公式 RTDE Client Library は RTDE protocol の client 実装であり、
controller の data field を読み書きする。
その data を robot motion に使う場合、motion の意味付けは controller-side program 側で設計する。

SDU `ur_rtde` はその先まで引き受ける。
control URScript と PC 側 API をセットで用意し、
ユーザーからは `moveJ`、`moveL`、`servoJ` などを直接呼べるように見せている。
つまり「RTDE protocol の wrapper」に加えて、
「RTDE register と URScript を使った独自の motion command layer」まで実装している。

Universal Robots 公式の RTDE motion example も controller-side program と組み合わせているので、
SDU が奇妙な方式を発明したというわけではない。
SDU はその構造を汎用化し、controller-side script の準備と PC-side API を一つの library としてまとめた、
と理解する方が正確である。

## 現在のスサノオ実装

現在のスサノオ UR 制御コードは SDU Robotics の `ur_rtde` を利用している。
したがって、現在の `moveJ()`、`moveL()`、`servoJ()` 等は Universal Robots 純正 RTDE Client Library の API ではなく、
SDU `RTDEControlInterface` の API である。

モーション制御では `RTDEControlInterface` を使用し、
その背後で SDU control URScript が controller 上で動作する。
状態取得には `RTDEReceiveInterface`、I/O には `RTDEIOInterface` を利用する。
さらに、電源、brake release、program 管理などには Dashboard Server、
controller message / error の取得には Primary Interface を別経路で利用している。

したがって現在の実装を単に「RTDE で UR を制御している」と呼ぶと不正確である。
正確には、**Universal Robots 公式 RTDE を基盤として、
SDU Robotics `ur_rtde` の control / receive / IO layer と、
Universal Robots 公式の Dashboard / Primary Interface を組み合わせている**。

この区別は、今後制御コードを見直すときにも重要である。
SDU `ur_rtde` を使い続けるか、Universal Robots 公式の client library や別の公式系 driver を使うかを判断するには、まず「RTDE protocol」と「SDU がその上に作った motion API」を別の層として扱う必要がある。

## 参考資料

- Universal Robots, 外部監視・制御のためのクライアントライブラリ
  https://www.universal-robots.com/ja/developer/client-libraries-for-external-monitoring-and-control/
- Universal Robots, Real-Time Data Exchange (RTDE) Guide
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-guide.html
- Universal Robots, RTDE Client Python Module
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-python-client-guide.html
- Universal Robots, RTDE Python Client Library
  https://github.com/UniversalRobots/RTDE_Python_Client_Library
- SDU Robotics, ur_rtde Introduction
  https://sdurobotics.gitlab.io/ur_rtde/introduction/introduction.html
- SDU Robotics, ur_rtde Examples
  https://sdurobotics.gitlab.io/ur_rtde/examples/examples.html
