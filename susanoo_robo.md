# robo

主に二つの使い方がある。同期プログラムと非同期プログラムである。

同期プログラムでは本当に純粋にシーケンスでプログラムを書く。もしくは、スレッドやプロセスで同期プログラムを非同期にコードしても書くことができる。
もう一つは asyncによる非同期プログラムである。

## sync 版

## async 版

エラー処理などを省く。できる限りシンプルな例

```python
#!/usr/bin/env python
import logging
from pathlib import Path

# httpx のログを WARNING レベル以上にする（INFO を抑制）
logging.getLogger("httpx").setLevel(logging.WARNING)

async def main():
    from cobotta2 import Config, MotionMode
    from cobotta2.server import AsyncCobottaClient
    from x_logger import XLogger

    HERE = Path(__file__).parent
    Config.load_yaml(HERE / "config_cobotta1_server1.yaml")

    logger = XLogger(log_level="info", logger_name=Config.CLIENT_LOGGER_NAME)
    cobotta = AsyncCobottaClient(config=Config, logger=logger)
    await client.reset_error()

    logger.info("take_arm")
    await client.take_arm()

    logger.info("turn_on_motor")
    await client.turn_on_motor()

    ret = await client.move("P62")
    await client.wait_for_complete()

    current_pos = await client.get_current_position()
    logger.info(f"current_position: {current_pos}")
    assert "result" == "result"

```