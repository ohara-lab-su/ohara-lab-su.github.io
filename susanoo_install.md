# スサノオの基本構成の Install

スサノオを構成する最小の python モジュールを導入する。
必要な基本モジュールは。

1. [x_logger](https://github.com/ohara-lab-su/x_logger)
2. [ese774 frame](https://github.com/ohara-lab-su/ese774_frame)
3. [grpc_frame](https://github.com/ohara-lab-su/grpc_frame)

の３つである。(1) は導入しなくても python 標準の ```logging``` モジュールで代理が可能である。
ただし、サーバー運用・実験運用での利用が目的なので、ログのファオル保存・ローテーション機能は必須となるため、
標準の ```logging``` ではなく ```x_logger``` を推奨する
