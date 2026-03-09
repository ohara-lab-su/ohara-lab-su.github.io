# スサノオのシステム

スサノオの根底はシンプルな透過型で構成されている。
サーバー側の制御classをそのままクライアント側の制御class
として使うことができる。クライアントで

```python
cobotta = Cobotta(config=xxx)
cobotta.meas()
```

のように動かせば。それはサーバー側

```python
cobotta = Cobotta(config=xxx)
cobotta.meas()
```

として動かしたことと同じになる。

<img src="fig/susanoo-intro.003.png" width="70%" style="display:block; margin:auto;">
<!-- ![](fig/susanoo-intro.003.png) -->

