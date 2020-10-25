# vi #

## 1. 简介 ##

vi 是类 unix 平台下著名的的文本编辑器。本软件包是 vi 对 RT-Thread 操作系统的移植，源自 busybox 中的 vi 编辑器，仅实现基本编辑功能。

### 1.1. 文件结构 ###

| 名称 | 说明 |
| ---- | ---- |
| vi.c  |  vi 编辑器源文件 |

### 1.2 许可证 ###

vi 遵循 LGPLv2.1 许可，详见 `LICENSE` 文件。

### 1.3 依赖 ###

- RT_Thread DFS
- RT_Thread libc
- RT_Thread optparse 软件包

## 2. 获取方式 ##

vi 软件包需开启 DFS、libc 功能和 optparse 软件包。

先要开启 DFS 功能， 具体路径如下所示：

    RT-Thread Components  --->
        Device virtual file system  --->
             [*] Using device virtual file system

然后开启 libc 功能， 具体路径如下所示：

    RT-Thread Components  --->
        POSIX layer and C standard library  --->
             [*] Enable libc APIs from toolchain

最后开启 optparse 软件包， 具体路径如下所示：

     RT-Thread online packages  --->
        miscellaneous packages  --->
            [*] optparse: a public domain, portable, reentrant, embeddable, getopt-like option parser

## 3. 注意事项 ##

- 仅使用 keil 和 gcc 测试，IAR 暂未测试

## 4. 联系方式 ##

- 维护：RT-Thread 开发团队及社区开发者
- 主页：<https://github.com/RT-Thread-packages/vi>
