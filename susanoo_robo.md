# robo
K.NAKADA (Shimane University)  

主に二つの使い方がある。同期プログラムと非同期プログラムである。

同期プログラムでは本当に純粋にシーケンスでプログラムを書く。もしくは、スレッドやプロセスで同期プログラムを非同期にコードしても書くことができる。
もう一つは asyncによる非同期プログラムである。

## sync 版

「電子天秤(位置P62)に移動して、重さを測るスクリプト」
```python
#!/usr/bin/env python
import logging
from pathlib import Path

# httpx のログを WARNING レベル以上にする（INFO を抑制）
logging.getLogger("httpx").setLevel(logging.WARNING)

def main():
    from cobotta2 import Config, MotionMode
    from cobotta2.server import AsyncCobottaClient
    from aandd_reader.server import AsyncAanddReaderClient
    from x_logger import XLogger

    HERE = Path(__file__).parent
    config_cobotta = Config(HERE / "config_cobotta1_server1.yaml")
    config_aandd_reader = Config(HERE / "config_cobotta1_server1.yaml")

    logger = XLogger(log_level="info", logger_name='test')
    cobotta = SyncCobottaClient(config=config_cobotta, logger=logger)
    aandd_reader = SyncAanddReaderClient(config=config_aandd_reader, logger=logger)
    cobotta.reset_error()
    cobotta.take_arm()
    cobotta.turn_on_motor()

    ### ロボットと 天秤制御
    ret = cobotta.move("P62")
    if not ret:
        logger.error(f"{cobotta.error_description()}': move failed")
        return False
    cobotta.wait_for_complete()
    mass = aandd_reader.meas()

    current_pos = cobotta.get_current_position()
    logger.info(f"mass = {mass}, current_position: {current_pos}")
    return True

if __name__ == "__main__":
    asyncio.run(main())
```

## async 版

エラー処理などを省く。できる限りシンプルな例。
基本的にはsync版と同じ。
現代のプログラムは、特に IO処理が多いものは、async 形式で書くのを慣れた方が良い。

「電子天秤(位置P62)に移動して、重さを測るスクリプト」
```python
#!/usr/bin/env python
import asyncio
import logging
from pathlib import Path

# httpx のログを WARNING レベル以上にする（INFO を抑制）
logging.getLogger("httpx").setLevel(logging.WARNING)

async def main():
    from cobotta2 import Config, MotionMode
    from cobotta2.server import AsyncCobottaClient
    from aandd_reader.server import AsyncAanddReaderClient
    from x_logger import XLogger

    HERE = Path(__file__).parent
    config_cobotta = Config(HERE / "config_cobotta1_server1.yaml")
    config_aandd_reader = Config(HERE / "config_cobotta1_server1.yaml")

    logger = XLogger(log_level="info", logger_name='test')
    cobotta = AsyncCobottaClient(config=config_cobotta, logger=logger)
    aandd_reader = AsyncAanddReaderClient(config=config_aandd_reader, logger=logger)
    await cobotta.reset_error()
    await cobotta.take_arm()
    await cobotta.turn_on_motor()

    ### ロボットと 天秤制御
    ret = await cobotta.move("P62")
    if not ret:
        logger.error(f"{await cobotta.error_description()}': move failed")
        return False
    await cobotta.wait_for_complete()
    mass = await aandd_reader.meas()

    current_pos = await cobotta.get_current_position()
    logger.info(f"mass = {mass}, current_position: {current_pos}")
    return True

if __name__ == "__main__":
    asyncio.run(main())
```