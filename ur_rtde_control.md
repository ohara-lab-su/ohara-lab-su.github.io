# 公式 RTDE と SDU Robotics `ur_rtde`

Universal Robots の制御では、
**Universal Robots 公式 RTDE** と
**SDU Robotics `ur_rtde`** を明確に区別する必要がある。

## 1. Universal Robots 公式 RTDE

RTDE (Real-Time Data Exchange) は Universal Robots が公式に提供する通信 I/F である。

外部 PC 上の RTDE client は UR controller と直接通信し、
controller が公開する出力値を受け取り、
公開されている入力値を書き込む。

したがって公式 RTDE は単なるログ転送や監視専用 I/F ではない。
外部 PC から controller の公開入力を変更できる双方向 I/F である。

ただし標準 RTDE input には、
`movej` や `movel` のような motion command は定義されていない。
また標準 RTDE input の joint target を直接書けば、
そのまま下位 servo controller が追従する、という公開仕様でもない。

- Universal Robots, RTDE Guide  
  https://docs.universal-robots.com/tutorials/communication-protocol-tutorials/rtde-guide.html
- Universal Robots, RTDE  
  https://www.universal-robots.com/developer/communication-protocol/rtde/

## 2. Universal Robots 公式 RTDE Python Client

Universal Robots は公式の RTDE Python Client Library を公開している。

これは Universal Robots の公式 GitHub repository にあるオープンソース実装である。

この client は公式 RTDE protocol を使って UR controller と直接通信する。

公式 repository には robot motion を扱う example も含まれるが、
その例では対応する robot-side program (`rtde_control_loop.urp`) も使用する。

したがって公式例の責務は、

- PC 側 client: RTDE input を計算・更新する
- RTDE: PC と UR controller 間で値を交換する
- controller-side program: 受け取った値を robot motion に結び付ける

という分担である。

ここで RTDE client 自体が controller と直接通信していることと、
motion semantics を controller-side program が持つことは矛盾しない。

- Universal Robots, RTDE Python Client Library  
  https://github.com/UniversalRobots/RTDE_Python_Client_Library

## 3. SDU Robotics `ur_rtde`

現在スサノオで利用している **`ur_rtde`** は Universal Robots 純正 SDK ではない。

**SDU Robotics が開発している第三者のオープンソースライブラリ**である。

主な I/F として、

- `RTDEControlInterface`
- `RTDEReceiveInterface`
- `RTDEIOInterface`

を提供する。

これらは Universal Robots 公式 RTDE protocol を利用しているが、
`RTDEControlInterface` という API 自体は Universal Robots 純正 RTDE の API ではない。

- SDU Robotics, ur_rtde  
  https://sdurobotics.gitlab.io/ur_rtde/
- SDU Robotics, Introduction  
  https://sdurobotics.gitlab.io/ur_rtde/introduction/introduction.html

## 4. SDU `RTDEControlInterface` の実体

SDU Robotics は `RTDEControlInterface` について、
robot 上で **control script が動作している必要があり、
その script をデフォルトで自動 upload する**と明記している。

したがって `RTDEControlInterface.moveJ()` は、
Universal Robots 公式 RTDE protocol に存在する `moveJ` command を呼んでいるわけではない。

実際には、

- PC 側 `RTDEControlInterface` が command ID や target を RTDE register に書く
- robot 側の SDU control URScript がその register を読む
- control URScript が `movej`、`movel`、`servoj` 等を実行する
- URControl がその URScript motion command を実行する

という構成である。

つまり SDU `RTDEControlInterface` は、

**Universal Robots 公式 RTDE + SDU 独自の robot-side control URScript**

を組み合わせて構成された PC 側モーション API である。

- SDU Robotics, Introduction  
  https://sdurobotics.gitlab.io/ur_rtde/introduction/introduction.html
- SDU Robotics, Examples  
  https://sdurobotics.gitlab.io/ur_rtde/examples/examples.html

## 5. SDU は「偽 RTDE」ではない

SDU `ur_rtde` が使っている通信そのものは、
Universal Robots 公式 RTDE である。

したがって「擬似 RTDE」という言い方をするなら、
RTDE protocol 自体ではなく、

**公式 RTDE の汎用 register を command channel として利用し、
robot-side URScript と組み合わせて motion API を構成している部分**

を指すべきである。

整理すると、

- 公式 RTDE: Universal Robots の通信 protocol
- 公式 RTDE Python Client: Universal Robots の client implementation
- SDU `ur_rtde`: 公式 RTDE を利用する第三者 OSS
- SDU `RTDEControlInterface`: 公式 RTDE + SDU control URScript による motion control layer

である。

## 6. 公式 RTDE の motion example と SDU の関係

Universal Robots 公式 RTDE Python Client の motion example も、
robot-side program と組み合わせて動作する。

したがって、
「SDU だけが Script を使う特殊な方式」という整理も正しくない。

両者とも、

**PC 側から RTDE で controller に値を渡し、
controller 側の program がその値を robot motion に結び付ける**

という基本的な分業がある。

違いは、
SDU `ur_rtde` がその controller-side program を
汎用の control URScript として用意し、
さらに PC 側に `moveJ`、`moveL`、`servoJ` 等の API を提供している点にある。

## 7. 現在のスサノオ実装

現在のスサノオ UR 制御では、
モーション制御に SDU Robotics の `RTDEControlInterface` を使用している。

したがって現在の `moveJ()` / `moveL()` / `servoJ()` は、
Universal Robots 純正 RTDE に存在する motion command を直接呼んでいるわけではない。

責務は次のように分かれている。

- モーション制御: SDU `RTDEControlInterface`
- 状態取得: SDU `RTDEReceiveInterface`
- I/O: SDU `RTDEIOInterface`
- controller 管理: `DashboardClient`
- controller message / error: Primary Interface

現在のモーション制御では、
SDU control URScript が robot 側で動作し、
PC 側 API とその script の間の command / parameter 交換に公式 RTDE が利用される。

## 8. 現在の理解で重要な点

重要なのは、次の三つを分けることである。

**Universal Robots 本体の制御**
- URControl
- URScript
- PolyScope
- Robot Arm / Control Box

**Universal Robots 公式の外部 I/F**
- RTDE
- Primary / Secondary
- Dashboard
- 公式 RTDE Python Client

**第三者の制御ライブラリ**
- SDU Robotics `ur_rtde`
- `RTDEControlInterface`
- SDU control URScript

この区別を崩すと、
公式 RTDE と SDU のモーション API を同じものとして扱ってしまう。
