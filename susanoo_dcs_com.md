# 分散ノード通信の基礎

サーバー・クライアント通信と、サーバー・サーバー間通信を分けて理解するよりもこれらを総括して、
「ノード間通信」としてまとめて、ノード間通信のモデルとして理解した方が理解しやすい。
結局は通信は低次元で見ればソケット通信でしかない。そして、その単位で見れば
bind / connect される関係がサーバークライアントになるだけ。
あえていうならば局所的に見れば全てサーバークライアントになる。
そのソケットをパターン分類すると通信が見えてくる。

(*) 筆者は情報の専門家ではないので、用途を含めて勘違いと間違いがあるかもしれない。

## ソケットのパターン分類

[MADOCA/DARUMA](https://user.spring8.or.jp/sp8info/?p=37181) や
[TANGO](https://www.tango-controls.org/) ではソケットレベルから
コードを書くことがあるので、ZMQ ベースから入るとこれらはわりと
自然に身につくかもしれない。ZMQ は軽量コンパクトで超高速な通信用のライブラリであり、
あるいみほとんど素のsocket通信ライブラリである。
これにより通信パターンを理解することは割と行われている。

ソケットの通信パターンは大きく、REQ/REP, ROUTER/DEALER, PUB/SUB,
に分かれる。 Web 通信は REQ/REP、ZMQ を使っていると ROUTER / DEALER 
が割と基本となる。今時の MQTT や DDS では PUB/SUB 形が主体になる。
いわゆる分散プロトコルは一般には ROUTER/DEALER や PUB/SUB を使うことを指す。

また通信パターンの別問題として、同期・非同期問題を意識しておいた方がいい。
同期非同期性でいえば、web (http) は REQ / REP なので論理的には同期通信となる。
だが、実装としては非同期にREQ流れるので、一概に同期通信と言い切れないとこもある。
また、たとえば、放射光設備で言えば、MADOCA2 はフルにZMQ構成であり非同期通信である。
TANGO は v9 までは ZMQ + CORBA(同期通信)構成であり、
実はctrl message は CORBA基盤なので同期通信になる。
V10 以降は ZMQ構成でctrl messageは非同期通信である。

以下、パターン分離は全て ZMQ の言葉で全ての通信を整理する。

### 1:1 通信 REQ / REP

最初に双方向メッセージの基本を抑える必要がある。たとえば、
一番身近な通信である(BL774の通信である) http などの web 通信は、
ソケットのレベルで見れば req(client) / rep(server)
モデルに相当する。

パターンとしては

#### REQ (クライアント側)

- REQ
  - send -> recv
  - request を送って reply を受け取る)
 
#### REP (サーバ側)

- REP
  - recv -> send
  - request を受け取って reply を返す)
 
押さえておいて欲しいのは、web 通信(http)は、
非対称構造(接続主体がclinetで応答主体がサーバー)
なので、二つノードは対等の1:1通信にならない。
その意味で典型的な意味で、サーバークライアントになる。

いわゆる、サーバー・サーバー間通信について考える。
HTTP は req/rep 型プロトコルであり、
サーバー同士を直接つなぐ分散通信プロトコルではない。
無論、「サーバー/サービス」の機能として、
クライアントとサーバーを入れ替えて別のサーバーと通信で繋がることはできる。
たとえば、webサーバーからアクションされてから呼び出された サービス
APIが呼び出して、別のサーバーにアクセスするなど。
ただ、これを分散通信か？といえばおそらく物言いが多くつくとは思う。
また nginxとかでリバースプロキシをかけてweb通信を別のサーバーに
飛ばすことができるが、これも分散通信か？といえば明らかに違う。

### 1:1 通信 ROUTER / DEALER

- 接続しているノードを識別してメッセージを転送できる通信パターン
- REQ/REP を拡張した非同期版

```text
TCP connection A ──┐
TCP connection B ──┼── ROUTER socket
TCP connection C ──┘
```
3:1 接続になる。
しかしこの場合でも、同時にメッセージを送ることはできない。
あくまでメッセージのシーケンスで送り、その通信自体はそれぞれの非同期で動作する形となる。

```text
(node A) ─ DEALER ─┐
(node B) ─ DEALER ─┼── ROUTER socket
(node C) ─ DEALER ─┘
```
ROUTER ソケットはそれぞれの DEALER からの接続(peer)に routing id を持っている。
raw-level でみればそれぞれのpeer ごとにソケットがあり、
それが一つの router ソケットと繋がる形になる。

ROUTER は名前の通り routing をするもので「別のノード」へ送る。
つまり、別のノードのDEALER へ送る。

```text
(node A) ─ DEALER ─┐           ┌─ DEALER ─ (node D)
(node B) ─ DEALER ─┼── ROUTER ─┼─ DEALER ─ (node E)
(node C) ─ DEALER ─┘           └─ DEALER ─ (node F)
```
これは中央にROUTERが一つあって、そのセンターのROUTERが、
どのDEALERにメッセージを送るか？という中央集権型の DEALER/ROUTER の使い方になる。

SPring-8 の MADOCA ではノードを跨いで術繋ぎで routing できるようになっており、
中央 ROUTER は存在しない設計になっている。つまり

<img src="fig/dcs_with_e.011.png" width="70%" style="display:block; margin:auto;">

```text
(node A) DEALER ─ (note E) DEALER  ─ (node B)  DEALER ── (node C)
```
のような peer-to-peer routing 構造となる。ROUTER / DEALER ソケットの組み合わせで、
自由にネットワーク間通信を横断できるようになる。そして、これは非同期で繋がる。

### 1:多数 通信 pub/sub

#### ブローカー型とブローカーレス型

---
# 作者
- Kengo NAKADA (中田謙吾)
  - kengo.nakada@mat.shimane-u.ac.jp
  - kengo.nakada@gmail.com