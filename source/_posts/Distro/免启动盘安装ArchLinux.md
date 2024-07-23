---
title: 免启动盘安装ArchLinux
date: 2022-10-08 16:59:54
tags:
---

本文展示了如何使用另一个已安装的Linux系统安装ArchLinux。本文以Deepin V23为例。

## 必要工具

这些工具ArchLinux的启动盘已经提供了。我们不用启动盘的话就得自己编译安装。

### pacstrap 和 arch-chroot

```shell
sudo apt install m4
# 这个六百多MB。不知道是不是必须的。
#sudo apt install asciidoc
git clone https://github.com/archlinux/arch-install-scripts
cd arch-install-scripts
make
sudo make install
```

### pacman

```shell
sudo apt install libarchive-dev
# bsdtar
sudo apt install libarchive-tools
sudo apt install meson
# Get the newest version automatically
# https://stackoverflow.com/questions/4493205/unix-sort-of-version-numbers
version=$(curl https://sources.archlinux.org/other/pacman/ | grep pacman | cut -d '"' -f 2 | sed 's/^[^0-9]*//g' | grep '^[0-9\.]*[0-9]' -o | sort -V | tail -n 1)
wget https://sources.archlinux.org/other/pacman/pacman-$version.tar.xz
tar xJf pacman-$version.tar.xz
cd pacman-$version/
# https://stackoverflow.com/questions/62475190/meson-and-ninja-build-system-specifify-where-binaries-are-stored
meson build
ninja -C build
sudo ninja -C build install
```

但是库的pc文件被安装到了`/usr/lib64/pkgconfig`里，而这下面的pc文件通常默认是不被搜索的：

```shell
# https://askubuntu.com/a/373217
pkg-config --variable pc_path pkg-config
# 里面通常没有/usr/lib64/pkgconfig
```

因此需要将这个路径添加到`PKG_CONFIG_PATH`里：

```shell
# https://people.freedesktop.org/~dbn/pkg-config-guide.html
sudo bash -c 'echo "export PKG_CONFIG_PATH=/usr/lib64/pkgconfig" >> /etc/bash.bashrc'
# 需要重启终端使PKG_CONFIG_PATH生效
# 需要把PKG_CONFIG_PATH加入到sudoers里的env_keep才能在sudo的时候使用这个设置的环境变量。
```

然后配置一下pacman的源：

```shell
# https://archlinux.org/pacman/pacman.conf.5.html
# https://stackoverflow.com/questions/23929235/multi-line-string-with-extra-space-preserved-indentation
sudo bash -c "cat > /etc/pacman.conf" << EOF
[options]
HoldPkg     = pacman glibc
# 不设置XferCommand的话可能会下载失败。
XferCommand = /usr/bin/curl -L -C - -f -o %o %u
Architecture = auto
CheckSpace
ParallelDownloads = 5

[core]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist
EOF

sudo mkdir -p /etc/pacman.d/
sudo bash -c "echo \"Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/\\\$repo/os/\\\$arch\" > /etc/pacman.d/mirrorlist"
```

在国外的话可以使用worldwide源：`https://geo.mirror.pkgbuild.com/$repo/os/$arch`。参考：<https://archlinux.org/mirrorlist/all/https/>

## 分区并挂载

```shell
sudo cfdisk /dev/sda
#efidev=/dev/sda1
#rootdev=/dev/sda3
sudo mkfs.ext4 $rootdev
sudo mount $rootdev /mnt
sudo mkdir /mnt/efi
sudo mount $efidev /mnt/efi
```

## 安装必要的包，以及进行必要的配置

```shell
sudo pacstrap /mnt base base-devel linux linux-headers linux-firmware dhcpcd vim bash-completion
sudo bash -c "genfstab -U /mnt >> /mnt/etc/fstab"
#hostname=hasee-arch
sudo bash -c "echo $hostname > /mnt/etc/hostname"
sudo bash -c "cat > /mnt/etc/hosts" << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname
EOF

echo Setting root password:
sudo chroot /mnt /bin/bash -c "passwd"
echo Setting admin account
echo -n "Please enter admin user name: "
read admin_name
echo Setting admin password:
sudo chroot /mnt /bin/bash -c "useradd -m -G wheel $admin_name && passwd $admin_name"
sudo chmod 740 /mnt/etc/sudoers
sudo bash -c 'echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers'
sudo chmod 440 /mnt/etc/sudoers
```

## chroot

使用`arch-chroot`来chroot，因为`arch-chroot`会自动挂载一些其他目录。

```shell
sudo arch-chroot /mnt
```

接下来的操作都在chroot里执行。

## 安装桌面环境

以KDE为例：

```shell
pacman -S --needed plasma-meta konsole dolphin ark
# Optional dependencies of ark
pacman -S --needed p7zip unrar unarchiver lzop lrzip
systemctl enable sddm
# Dependencies of Discover
pacman -S --needed packagekit-qt5 packagekit appstream-qt appstream
```

好像默认只有X11 session。如果要wayland session的话：

```shell
sudo pacman -S plasma-wayland-session
```

## 安装一些额外包

```shell
# Sound
pacman -S --needed sof-firmware alsa-firmware alsa-ucm-conf
pacman -S --needed ntfs-3g
pacman -S --needed adobe-source-han-serif-cn-fonts wqy-zenhei noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
pacman -S --needed firefox
pacman -S --needed wget
```

## 本地化

### Locale

ArchLinux没有默认的locale，所以一定要设置locale，否则之后运行一些命令时会出现这种报错：`bsdtar: Failed to set default locale`。

为了方便出现问题后到国际平台上寻求帮助，这里设置成`en_US.UTF-8`。

```shell
echo -e "en_US.UTF-8 UTF-8\nzh_CN.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen
# https://wiki.archlinux.org/title/Locale
# /etc/locale.conf
sudo localectl set-locale LANG=en_US.UTF-8
# https://wiki.archlinux.org/title/Locale#My_system_is_still_using_wrong_language
#rm ~/.config/plasma-localerc
```

### 时区

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

## 引导

可以直接使用原有的引导，也可以安装并使用ArchLinux的引导。

### 使用原有的引导

```shell
update-grub
```

### 安装并使用ArchLinux的引导

```shell
pacman -S --needed grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
echo GRUB_DISABLE_OS_PROBER=false >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
```

## 启动ArchLinux

重启电脑，应该就能在GRUB菜单里看到刚刚安装的ArchLinux了。

进去之后可能会出现key出错的问题。可参考这里解决：<https://www.jianshu.com/p/1790e92b2189/>

KDE自带Baloo，用于文件索引，非常耗费资源。如果用不着的话可以关掉它：

```shell
# https://wiki.archlinux.org/title/Baloo
balooctl suspend
balooctl disable
balooctl purge
```

## 参考文献

<https://archlinuxstudio.github.io/ArchLinuxTutorial/#/>

<https://wiki.archlinux.org/title/Install_Arch_Linux_from_existing_Linux>
