# RT-Smart User Space Application SDK

[中文](README_ZH.md) | English

## How to Build User Space Application

### Download Code

Download RT-Smart user space application code: 

```
git clone https://github.com/RT-Thread/userapps.git
```

Source code catalog description: 

```
.
├── apps                  ---- app experience sample
├── configs               ---- Common configuration for different platform app
├── linker_scripts        ---- Compile the linker script app used
├── prebuilt              ---- Precompiled kernel mirroring
├── rtconfig.h            ---- Public configuration file app used
├── sdk                   ---- sdk used while developing app
├── smart-env.bat         ---- Configure the script for environment variables on Win
├── smart-env.sh          ---- Confiure the script for environment variables on Linux
└── tools                 ---- Script tools used while developing app
     ├── get_toolchain.py ---- Script for downloading the toolchain
     └── gnu_gcc          ---- Path where the downloaded toolchain is located
```

### Configure Toolchain

Running get_toolchain.py script in the userapps\tools directory, the corresponding toolchain will be downloaded and expanded to the userapps\tools\gun_gcc directory. The toolchain can be named arm | aarch64 | riscv64.

In this article, we're taking the RISC-V platform as an example and entering the following command:

```
python get_toolchain.py riscv64
```

In the userapps directory, run smart-env.bat | smart-env.sh to configure the toolchain path, and the currently supported parameter is arm | aarch64 | riscv64

```
smart-env.bat riscv64
```

Here you can use the set command to check if the RTT_EXEC_PATH is successfully set.

![img](figures/set.png)

### Configure User Space App

Compile with scons in the rtthread-smart\userapps directory, and if the compilation runs well, you will get a series of executable elf files in the root folder.

![img](figures/build_app.png)

## Run User Space App

In the prebuilt directory of this repository, there is a pre-built kernel mirror qemu-virt64-riscv\rtthread.bin for the QEMU RISC-V platform, you can quickly start with RISC-V with QEMU platform. 

### Update QEMU

The QEMU version inside the Env is running an earlier version, it needs an update (Env can delete this step after updating the QEMU)

1. Download and install QEMU (recommend qemu-w32-setup-20220831.exe ):https://qemu.weilnetz.de/w32/
2. Replace the QEMU in Env with the new version.

### Make QEMU SD Card

#### FAT
In the tools\fatdisk directory there is a tool fatdisk.exe that packages FAT format files, which we can use to package the files we want to store in the QEMU SD card into sd.bin files.

#### EXT4
In the tools\make_ext4fs directory, there is a tool make_ext4fs for packaging EXT4 format files (linux (ubuntu) only), use the command `./make_ext4fs -l 8G rootfs.img /home/xqyjl/git/github/RT-Thread/userapps /root` to create an ext4 image

![img](figures/build_sd1.png)

1. Place the newly generated sd.bin into the userapps\prebuilt\qemu-virt64-riscv directory.

### Run QEMU

Open Env in the userapps\prebuilt\qemu-virt64-riscv directory, execute qemu-norgraphic.bat to run QEMU.

![img](figures/qemu_run.png)

Enter ls after Smart is running and you can see the files and folders we have stored on the QEMU SD card.

![img](figures/qemu_run2.png)

Here the hello example is executed, outputting "hello world!".

Execute ctrl c to exit QEMU.

## Built Kernel Mirroring

Review this section when you need to update the kernel mirroring files.

Download the rt-thread source code (skip if it's already done), then switch to the rt-smart branch and synchronize updates from the remote end.

```
git clone https://github.com/RT-Thread/rt-thread.git

git checkout rt-smart
# update kernel's rt-smart branch to the latest version
git pull origin rt-smart
```

Build kernel mirroring based on qemu-virt64-riscv BSP in the rt-thread repository rt-smart branch.

![img](figures/build_kernel1.png)
![img](figures/build_kernel2.png)

Update the generated kernel mirroring rtthread.bin to the userappsprebuiltqemu-virt64-riscv directory.

## FAQ

### Toolchain is not found while scons

The following message appears at compile:

```
> scons
scons: Reading SConscript files ...
scons: done reading SConscript files.
scons: Building targets ...
CC apps\webclient\packages\webclient-v2.1.2\src\webclient.o
Error in calling command:riscv64-unknown-linux-musl-gcc
Exception: No such file or directory

Please check Toolchains PATH setting.

scons: *** [apps\webclient\packages\webclient-v2.1.2\src\webclient.o] Error 2
scons: building terminated because of errors.
```

Check that if the toolchain path is correctly set, or follow this article to get this right.

### zlib1.dll missing prompted while scons

Re-download [zlib1.dll Files](https://www.dlldownloader.com/zlib1-dll/) and place them in the C:\Windows\System32 and C:\Windows\SysWOW64 folders. https://www.githubstatus.com/
