# LSF に関しての TIPS

[TOC]

## bjobs の表示形式がシステムによって異なる
システムによって bjobs でのホストリスト表示の形式が異なります。これはデフォルト設定が下記で設定されてます。設定は下記にて行われています。

```
/usr/share/lava/conf/lsf.conf
```

このファイル中で環境変数

**LSB\_SHORT\_HOSTLIST=1**

がセットされている場合と、セットされていない場合で挙動が異なります。この項目は **lsf.conf** でセットしなくても、環境変数としてセットしても同じです。実行時にある環境変数がセットされた序様態でプログラムを動かすには、**env** コマンドを使うと簡単です。

### 省略形式 LSB\_SHORT\_HOSTLIST=1

```
$ env LSB_SHORT_HOSTLIST=1 bjobs
JOBID   USER    STAT  QUEUE      FROM_HOST   EXEC_HOST   JOB_NAME   SUBMIT_TIME
2420    hpc     RUN   normal     hpcs01.loca 16*hpcs01.l g7525      Nov  1 08:09
                                             16*hpcs02.local
2421    hpc     PEND  normal     hpcs01.loca             pCOHP      Nov  1 10:45
2422    hpc     PEND  normal     hpcs01.loca             7thDOS     Nov  1 13:52
2423    hpc     PEND  normal     hpcs01.loca             4thCOHP    Nov  1 13:57
```

としますと、たとえば省略形式でその場で実行できます。

### 省略しない形式 LSB\_SHORT\_HOSTLIST=0

```
$ env LSB_SHORT_HOSTLIST=0 bjobs
JOBID   USER    STAT  QUEUE      FROM_HOST   EXEC_HOST   JOB_NAME   SUBMIT_TIME
2420    hpc     RUN   normal     hpcs01.loca hpcs01.loca g7525      Nov  1 08:09
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs01.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
                                             hpcs02.local
2421    hpc     PEND  normal     hpcs01.loca             pCOHP      Nov  1 10:45
2422    hpc     PEND  normal     hpcs01.loca             7thDOS     Nov  1 13:52
2423    hpc     PEND  normal     hpcs01.loca             4thCOHP    Nov  1 13:57
```


### 遠隔から表示する場合(sshでの環境変数セット)
```
ssh サーバー名 env LSB_SHORT_HOSTLIST=1 /usr/share/lava/1.0/linux2.6-glibc2.12-x86_64/bin/bjobs
```

実行するプログラムを絶対パスで指定します。