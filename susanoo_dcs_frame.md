# 機器制御フレームワークのトレンド

## ロボット制御でのトレンド

## 放射光設備での流れ(実験サイド)

TANGO や MADOCA や
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
という言葉は、プロトコルを示す以上にフレームワークを示す言葉である。
lowレベルのプロトコルで言えば、TANGOやMADOCAは ZMQ であり、
[BL774](https://user.spring8.or.jp/sp8info/?p=42759)
は RestAPI である。これらをまとめる。
少し調査と情報が古いうえに偏っているところもあるが、大型放射光施設をめぐるプロトコルとフレームワーク事情をまとめられたらと思う。
あとロボット。

<img src="fig/dcs_with_e.036.png" width="70%" style="display:block; margin:auto;">

たとえば、ESRF の [TANGO](https://www.tango-controls.org/)
は TANGO v10 からメッセージ通信においても、CORBA の同期通信から ZMQ の非同期に変わるなど古いプロトコル(CORBA)を捨てる動きが本格化している。

欧州でロボットで使われることの多い ROS は ROS1 系は CORBA であったが、ROS2系かからDDS基盤への完全に移行している。
デンソーウェーブのORiN2は ROS1 への接続へは拡張はできるが、ROS2は完全に非対応なので、
もはや過去の遺物とかしている。

- スターズとかも書く
- DDS の流れ
- 分散制御のトレンドも
 
## 加速器制御などでのトレンド
