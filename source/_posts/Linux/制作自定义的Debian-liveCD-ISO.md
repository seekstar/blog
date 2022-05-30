---
title: 制作自定义的Debian LiveOS ISO
date: 2022-05-30 21:16:13
tags:
---

主要参考：<https://willhaley.com/blog/custom-debian-live-environment/>

## 序章

先找到一块风水宝地作为我们的工作目录，所有相关文件都放到这个目录下。以下命令默认都是在这个目录下执行。

```shell
mkdir -p 风水宝地
cd 风水宝地
```

P.S. `风水宝地`是个梗，建议尽量用英文目录名。

在风水宝地下面建立一些必要的目录：

```shell
mkdir -p ./{staging/{EFI/boot,boot/grub/x86_64-efi,isolinux,live},tmp}
```

其中`staging`下面存放的就是用来制作ISO的文件。

然后安装必要的工具：

```shell
# Debian 11
sudo apt install \
    debootstrap \
    squashfs-tools \
    xorriso \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools
```

## 生成基本的Linux根目录结构

```shell
sudo debootstrap bullseye $(pwd)/chroot https://mirrors.tuna.tsinghua.edu.cn/debian/
```

## 安装Linux内核

```shell
sudo chroot chroot/
```

然后在chroot里面：

```shell
# chroot
apt install linux-image-amd64
```

注意这个时候生成的initramfs不是针对LiveOS的。安装`live-boot`之后会让系统中的`update-initramfs`指向`live-update-initramfs`，并且自动更新系统中已有的initramfs，使其可以用来启动LiveOS：

```shell
# chroot
apt install live-boot
```

然后安装`systemd-sysv`（教程说是用来提供init的）：

```shell
# chroot
apt install systemd-sysv
```

最后退出chroot，将安装好的内核和initramfs拷贝到`staging`中：

```shell
cp chroot/boot/vmlinuz-* \
    staging/live/vmlinuz && \
sudo cp chroot/boot/initrd.img-* \
    staging/live/initrd
# 因为有些initramfs没有给others读权限。
sudo chown $USER:$USER staging/live/initrd
```

## 更改根文件系统

可以chroot进根文件系统更改：

```shell
sudo chroot chroot/
```

可以更改`/etc/hostname`、添加用户、设置root密码等。也可以安装一些必要的包，修改一些配置：

```shell
# chroot
apt install openssh-server
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
```

用`apt`装完软件包之后，通常系统会把安装包缓存下来。可以通过`apt clean`把这些缓存清空。

这一阶段也可以配置自动登录到root：<https://askubuntu.com/a/1229543>
（这个没有用：https://unix.stackexchange.com/questions/151919/login-automatically-as-root）

修改完根文件系统之后，就可以把它压缩为squashfs了：

```shell
sudo mksquashfs \
    chroot \
    staging/live/filesystem.squashfs \
    -e boot
```

注意这里把`/boot`目录排除了，这是因为系统启动的时候会先读取`/boot`下面的内核等，最后才挂载根文件系统，因此`/boot`目录不能放到根文件系统里，而是另外放。

如果以后还要更改根文件系统，都要重新执行上面的命令生成`filesystem.squashfs`。

## Boot Loader Menus

```shell
cat <<'EOF' >staging/isolinux/isolinux.cfg
UI vesamenu.c32

MENU TITLE Boot Menu
DEFAULT linux
TIMEOUT 600
MENU RESOLUTION 640 480
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #9033ccff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #30ffffff #00000000 std

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX]
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live

LABEL linux
  MENU LABEL Debian Live [BIOS/ISOLINUX] (nomodeset)
  MENU DEFAULT
  KERNEL /live/vmlinuz
  APPEND initrd=/live/initrd boot=live nomodeset
EOF
```

```shell
cat <<'EOF' >staging/boot/grub/grub.cfg
search --set=root --file /DEBIAN_CUSTOM

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian Live [EFI/GRUB]" {
    insmod all_video
    linux ($root)/live/vmlinuz boot=live
    initrd ($root)/live/initrd
}

menuentry "Debian Live [EFI/GRUB] (nomodeset)" {
    insmod all_video
    linux ($root)/live/vmlinuz boot=live nomodeset
    initrd ($root)/live/initrd
}
EOF
```

其中`insmod all_video`可以解决`no suitable video mode found`的问题：<https://lists.gnu.org/archive/html/help-grub/2018-01/msg00009.html>

```shell
cat <<'EOF' >tmp/grub-standalone.cfg
search --set=root --file /DEBIAN_CUSTOM
set prefix=($root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF
```

```shell
touch staging/DEBIAN_CUSTOM
```

`DEBIAN_CUSTOM`的功能是帮助`GRUB`查找哪个设备包含了我们的live filesystem。因此其名字要全局唯一。

## Boot Loader Files

这里直接把宿主机上的文件拷贝过来：

```shell
cp /usr/lib/ISOLINUX/isohdpfx.bin tmp/
cp /usr/lib/ISOLINUX/isolinux.bin staging/isolinux/ && \
cp /usr/lib/syslinux/modules/bios/* staging/isolinux/

mkdir -p staging/boot/grub/x86_64-efi/
cp -r /usr/lib/grub/x86_64-efi/* staging/boot/grub/x86_64-efi/
```

```shell
# 如果是CentOS，就是grub2-mkstandalone
grub-mkstandalone \
    --format=x86_64-efi \
    --output=tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=tmp/grub-standalone.cfg"
```

```shell
cd staging/EFI/boot
dd if=/dev/zero of=efiboot.img bs=1M count=20
/sbin/mkfs.vfat efiboot.img
mmd -i efiboot.img efi efi/boot
mcopy -vi efiboot.img ../../../tmp/bootx64.efi ::efi/boot/
cd -
```

## 生成ISO

```shell
xorriso \
    -as mkisofs \
    -iso-level 3 \
    -o "debian-custom.iso" \
    -full-iso9660-filenames \
    -volid "DEBIAN_CUSTOM" \
    -isohybrid-mbr tmp/isohdpfx.bin \
    -eltorito-boot \
        isolinux/isolinux.bin \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-catalog isolinux/isolinux.cat \
    -eltorito-alt-boot \
        -e /EFI/boot/efiboot.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
    -append_partition 2 0xef staging/EFI/boot/efiboot.img \
    "staging"
```

## 用QEMU测试

```shell
qemu-system-x86_64 -enable-kvm -cpu host -m 4096 -cdrom debian-custom.iso
```

联网、VNC等参考：{% post_link Linux/qemu/'在服务器上用qemu制作虚拟机' %}

## 注意事项

这个ISO不支持ventoy。

## 常见问题

### no working init

可能是内存不足。因为liveCD好像是把整个根文件系统放到内存里，所以给的内存要足够大？

参考：<https://unix.stackexchange.com/questions/655508/boot-ubuntu-iso-under-qemu>

### No loop devices available

检查内核的配置文件里`CONFIG_BLK_DEV_LOOP_MIN_COUNT`的值。如果是0的话，即使`modprobe loop`了，`ls /dev/loop0`仍然不存在。

Debian生成的initramfs好像要求这个值不能是0。Torvalds内核的默认配置里这个值是8，但是CentOS的内核配置里这个值是0。因此如果发现这个值是0（比如这个内核来自CentOS），那只能把这个值改成非0然后重新编译了。编译安装Linux内核教程：{% post_link kernel/'编译安装linux内核' %}

### fb0: switching to amdgpudrmfb from EFI VGA

使用nomodeset模式即可。intel的机器没有这个问题。

参考：<https://forum.level1techs.com/t/fb0-switching-to-amdgpudrmfb-from-efi-vga/152112>

`nomodeset`的作用：<https://askubuntu.com/questions/207175/what-does-nomodeset-do>

### chroot下DNS解析失败

chroot下貌似是不会自动更新`/etc/resolv.conf`的。因此把chroot目录转移到其他机器上再chroot就会出问题。可以把`/etc/resolv.conf`里改成`nameserver 8.8.8.8`之类的。

LiveOS好像不存在这个问题，因为开机的时候会自动更改`/etc/resolv.conf`。
