# ese774_frame 完全透過型 Quick Start {#top}

[index に戻る](index.md#device-object)

ここでは、`ese774_frame` を用いて、
ローカルで動作する DeviceClass をそのままデバイスサーバーとして公開する、
最も単純な完全透過型の例を示す。

例外処理を必要としない場合を対象とする。

つまり、

```text
DeviceClass
    ↓
数行のサーバー
    ↓
数行のクライアント
```

だけで構成する。

Pydantic / OpenAPI 用の API 定義は作らない。

## 1. DeviceClass を作る

まず、スサノオや通信とは関係なく、
通常の Python の機器制御 class を作る。

ここでは実機の代わりに単純な class を例とする。

`simple_device.py`

```python
class SimpleDevice:
    def __init__(self, logger=None):
        self._logger = logger
        self._value = 0

    def add(self, a, b):
        return a + b

    def set_value(self, value):
        self._value = value

    def get_value(self):
        return self._value
```

この class は単独でも利用できる。

```python
from simple_device import SimpleDevice


device = SimpleDevice()

print(device.add(10, 20))

device.set_value(100)
print(device.get_value())
```

出力は、

```text
30
100
```

となる。

この段階では `ese774_frame` は使用していない。

スサノオでは、この DeviceClass を基本単位とする。

## 2. デバイスサーバーを作る

次に、DeviceClass に `ese774_frame` の通信 Frame を付加する。

`simple_server.py`

```python
from ese774_frame import FastApiServer
from ese774_frame.routers.device_router import DeviceRouter

from simple_device import SimpleDevice


if __name__ == "__main__":
    server = FastApiServer(
        device_cls=SimpleDevice,
        router_cls=DeviceRouter,
        config=None,
        api_spec=None,
        object_name="simple",
    )

    server.run(
        host="0.0.0.0",
        port=8000,
    )
```

完全な動的ディスパッチを使う場合は、

```python
api_spec=None
```

とする。

Pydantic / OpenAPI 用の API 定義や、
DeviceClass ごとの Router を作る必要はない。

## 3. デバイスサーバーを起動する

サーバー側で、

```bash
python simple_server.py
```

を実行する。

この例では port `8000` でデバイスサーバーが起動する。

同一 PC から接続する場合は `127.0.0.1` を利用できる。

別の PC から接続する場合は、
クライアント側でデバイスサーバー PC の IP address を指定する。

## 4. デバイスクライアントを作る

例外処理がない場合、
クライアント class に DeviceClass の API を書き直す必要はない。

`simple_client.py`

```python
from ese774_frame.clients.sync_device_client import SyncDeviceClient


class SyncSimpleDeviceClient(SyncDeviceClient):
    def __init__(
        self,
        server_ip="127.0.0.1",
        server_port=8000,
    ):
        super().__init__(
            server_ip=server_ip,
            server_port=server_port,
            api_spec=None,
            object_name="simple",
        )
```

`add()`、`set_value()`、`get_value()` は記述していない。

完全な動的ディスパッチでは、
DeviceClass 側の public API がネットワーク越しにそのまま呼び出される。

## 5. クライアントから利用する

`simple_example.py`

```python
from simple_client import SyncSimpleDeviceClient


device = SyncSimpleDeviceClient(
    server_ip="127.0.0.1",
    server_port=8000,
)

try:
    print(device.add(10, 20))

    device.set_value(100)
    print(device.get_value())

finally:
    device.close()
```

出力は、

```text
30
100
```

となる。

## ローカルとネットワーク越しの比較

ローカルでは、

```python
from simple_device import SimpleDevice


device = SimpleDevice()

device.set_value(100)
print(device.get_value())
```

ネットワーク越しでは、

```python
from simple_client import SyncSimpleDeviceClient


device = SyncSimpleDeviceClient()

device.set_value(100)
print(device.get_value())

device.close()
```

となる。

DeviceClass を利用する部分はどちらも、

```python
device.set_value(100)
device.get_value()
```

である。

つまり、基本的な利用側のコードから見ると、

```text
Local
    device.method(...)
        ↓
    DeviceClass.method(...)

Remote
    device.method(...)
        ↓
    ese774_frame
        ↓
    DeviceClass.method(...)
```

となる。

これがスサノオで基本としている透過型プロキシである。

## 公開 API

完全な動的ディスパッチでは、
DeviceClass の public API を原則として公開する。

```python
class SimpleDevice:
    def start(self):
        ...

    def stop(self):
        ...

    def get_value(self):
        ...
```

であれば、

```python
device.start()
device.stop()
device.get_value()
```

として利用できる。

`_` で始まるメソッドは公開しない。

```python
def _internal_method(self):
    ...
```

また、public API であってもネットワーク越しに公開したくないメソッドは、
サーバー側で `dispatch_exclude` に指定する。

```python
server = FastApiServer(
    device_cls=SimpleDevice,
    router_cls=DeviceRouter,
    config=None,
    api_spec=None,
    object_name="simple",
    dispatch_exclude={
        "disconnect",
        "delete",
    },
)
```

例えば、デバイスサーバー自身が lifecycle として管理する `disconnect()` などを、
クライアントから直接呼び出させたくない場合に利用する。

## 例外処理が必要な場合

このページでは、クライアントとサーバーで処理を分ける必要がない、
最も単純な場合だけを扱った。

例えば、

- サーバー側にあるファイルをクライアント側へ download して保存する
- クライアント側だけで行いたい処理がある
- remote API と同名のメソッドをクライアント側で override したい

などの場合には、クライアント class 側へ必要な処理だけを追加する。

通常の DeviceClass API までクライアント側へ再実装する必要はない。

## Pydantic / OpenAPI を利用する場合

現在の基本は、ここで示した完全な動的ディスパッチである。

一方、OpenAPI による明示的な I/F 定義が必要な場合には、
Pydantic / ApiSpec を用いる方式も利用できる。

その場合は DeviceClass の Python API とは別に API 定義を記述する。

- [Pydantic/OpenAPI タイプのデバイスサーバー作成](susanoo_device_server.md)
