---
title: qemu br0 access denied by acl file
date: 2021-08-08 18:04:15
---

```shell
echo "allow all" | sudo tee /etc/qemu/${USER}.conf
echo "include /etc/qemu/${USER}.conf" | sudo tee --append /etc/qemu/bridge.conf
sudo chown root:${USER} /etc/qemu/${USER}.conf
sudo chmod 640 /etc/qemu/${USER}.conf
```

如果是qemu-kvm的话：

```shell
echo "allow all" | sudo tee /etc/qemu-kvm/${USER}.conf
echo "include /etc/qemu-kvm/${USER}.conf" | sudo tee --append /etc/qemu-kvm/bridge.conf
sudo chown root:${USER} /etc/qemu-kvm/${USER}.conf
sudo chmod 640 /etc/qemu-kvm/${USER}.conf
```

原文：<https://blog.christophersmart.com/2016/08/31/configuring-qemu-bridge-helper-after-access-denied-by-acl-file-error/>
