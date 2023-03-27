# 基于 EXT4 文件系统的 RT-Smart 用户态应用开发

> 本文档环境为 `ubuntu 20.04`

## 环境准备

### 仓库

`RT-Smart` 软件开源在 `https://github.com/RT-Thread/rt-thread.git` 本 `bsp` 的源码在 `https://github.com/RT-Thread/rt-thread/tree/master/bsp/qemu-virt64-aarch64`

请 `clone` 此仓库以进行开发:

```shell
git clone https://github.com/RT-Thread/rt-thread.git
```

### pkgs

pkgs 是 RT-Smart 的包管理软件，

```shell
mkdir -pv ~/.env/tools/
git clone https://gitee.com/RT-Thread-Mirror/env.git ~/.env/tools/scripts
export PATH=~/.env/tools/scripts:$PATH:$RTT_EXEC_PATH
```

### 添加 EXT4 软件包

EXT4 是作为 RT-Smart 的一个软件包，因此我们需要使用 pkgs 去管理下载 EXT4 软件包

首先进入 `bsp` 目录，也就是从 github 克隆的那个仓库，进入 `bsp/qemu-virt64-aarch64` 目录执行 `scons --menuconfig`。将 `> RT-Thread online packages > system packages > lwext4: an excellent choice of ext2/3/4 filesystem for microcontrollers.` 目录的选项激活，然后退出 `menuconfig`

执行 `pkgs --update` 以下载软件包（需确保已将 `pkgs` 添加置环境变量）

### 修改 SD 卡挂载方式

将 `bsp` 的 `sd` 卡的挂载文件系统代码（`bsp/qemu-virt64-aarch64/applications/mnt.c`）修改为 ext 文件系统

```c
int mnt_init(void)
{
    if (rt_device_find("virtio-blk0"))
    {
        /* mount virtio-blk as root directory */
        if (dfs_mount("virtio-blk0", "/", "ext", 0, RT_NULL) == 0)
        {
            rt_kprintf("file system initialization done!\n");
        }
    }

    return 0;
}
INIT_ENV_EXPORT(mnt_init);
```

### 工具链

首先进入到 `tools` 文件夹，下载工具链：

```shell
python3 get_toolchain.py aarch64
```

## 内核编译

先在 `userapps` 目录下执行以下命令将编译器信息添加到环境变量

```shell
source smart-env.sh aarch64
```

随后进入 `bsp` 目录进行编译

```shell
scons -j8
```

将编译生成的产物复制到 `userapps` 目录下的 `prebuilt/qemu-virt64-aarch64-ext4/rtthread.bin` 处

## 用户态编译

先在 `userapps` 目录下执行以下命令将编译器信息添加到环境变量

```shell
source smart-env.sh aarch64
```

随后直接在此目录执行编译命令即可编译事先准备好的用户态示例

```shell
scons -j8 --verbose
```

产物存放在 `root/bin` 目录下

## sd 卡打包

在 `userapps` 目录执行以下命令将 `root` 目录打包成一个 `500M` 大小的镜像包并放入 `prebuilt/qemu-virt64-aarch64-ext4/rootfs.img`

```
tools/make_ext4fs/make_ext4fs -l 500M prebuilt/qemu-virt64-aarch64-ext4/rootfs.img root
```

## 运行 qemu

在 `userapps` 目录下的 `prebuilt/qemu-virt64-aarch64-ext4` 目录执行 `qemu.sh` 以运行 qemu

随后可以执行 `bin/hello.elf` 看是否正确输出`hello world!`字样

```log
# ./qemu.sh
[I/libcpu.aarch64.cpu] Using MPID 0x0 as cpu 0
[I/libcpu.aarch64.cpu] Using MPID 0x1 as cpu 1
[I/libcpu.aarch64.cpu] Using MPID 0x2 as cpu 2
[I/libcpu.aarch64.cpu] Using MPID 0x3 as cpu 3

 \ | /
- RT -     Thread Smart Operating System
 / | \     5.0.0 build Mar 24 2023 15:02:31
 2006 - 2022 Copyright by RT-Thread team
lwIP-2.0.3 initialized!
[I/sal.skt] Socket Abstraction Layer initialize success.
file system initialization done!
[I/libcpu.aarch64.cpu] Secondary CPU 1 booted
[I/libcpu.aarch64.cpu] Secondary CPU 2 booted
[I/libcpu.aarch64.cpu] Secondary CPU 3 booted
msh />hello rt-thread

msh />ls
Directory /:
.                   <DIR>
..                  <DIR>
lost+found          <DIR>
bin                 <DIR>
msh />b
msh />bin/
.
..
hello.elf
ping.elf
pong.elf
umailbox.elf
vi.elf
webclient.elf
webserver.elf
msh />bin/he
msh />bin/hello.elf
msh />hello world!
```
