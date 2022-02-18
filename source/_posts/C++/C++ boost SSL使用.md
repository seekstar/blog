---
title: C++ boost SSL使用
date: 2020-04-25 00:29:25
tags:
---

我使用的boost版本是1.62，所以下面的文档都是1.62的。如果想看其他版本的，把url中的`1_62_0`换成你想看的版本即可。

[官方文档](https://www.boost.org/doc/libs/1_62_0/doc/html/boost_asio/overview/ssl.html)

[官方提供的boost asio的例子](https://www.boost.org/doc/libs/1_62_0/doc/html/boost_asio/examples/cpp03_examples.html#boost_asio.examples.cpp03_examples.ssl)

# boost官方提供的echo [server](https://www.boost.org/doc/libs/1_62_0/doc/html/boost_asio/example/cpp03/ssl/server.cpp)和[client](https://www.boost.org/doc/libs/1_62_0/doc/html/boost_asio/example/cpp03/ssl/client.cpp)例子
把它们保存到server.cpp和client.cpp中。

参考：<https://blog.csdn.net/zhangzq86/article/details/80790810>

## 编译
```shell
g++ -o server server.cpp -lssl -lcrypto -lboost_system
g++ -o client client.cpp -pthread -lssl -lcrypto -lboost_system
```
不要用`-mt`（可能没有开启多线程？<https://stackoverflow.com/questions/4596492/usr-bin-ld-cannot-find-lboost-system-mt>）

### 可能出现的错误及解决方案
1. 
```
fatal error: openssl/conf.h: No such file or directory
```
```shell
sudo apt install -y libssl-dev
```
2. 
```
/usr/bin/ld: cannot find -lboost_system
```
```shell
sudo apt install -y libboost_system-dev
```
或者直接
```shell
sudo apt install libboost-all-dev
```
注意只安装`libboost-dev`是没有上面所说的库的。

## 生成证书
参考：
<https://stackoverflow.com/questions/6452756/exception-running-boost-asio-ssl-example>
<https://blog.csdn.net/liuchunming033/article/details/48470575>
<https://blog.csdn.net/qq_37049781/article/details/84837342>

### 生成ca证书
参考：
[crt转pem](https://www.cnblogs.com/LiuYanYGZ/p/10375174.html)
[demoCA](https://www.cnblogs.com/jinanxiaolaohu/p/11362901.html)
```shell
# Generate CA private key 
openssl genrsa -out ca.key 2048 
# Generate CSR 
openssl req -new -key ca.key -out ca.csr
# Generate Self Signed certificate（CA 根证书）
openssl x509 -req -days 3650 -in ca.csr -signkey ca.key -out ca.crt
# 转成pem格式(ASCII形式)。
openssl x509 -in ca.crt -out ca.pem
# 由于我这里crt已经是ASCII格式了，所以可以直接cp ca.crt ca.pem

# 创建一个目录结构，以后用来给其他证书签名时要用到
mkdir demoCA
cd demoCA
mkdir newcerts
touch index.txt
echo -e '01\n' >> serial
cd ..
```

### 生成server证书
[合并crt和key生成pem](http://www.voidcn.com/article/p-ptsxlgtt-bsh.html)
```shell
# private key
openssl genrsa -out server.key 1024 
# generate csr
openssl req -new -key server.key -out server.csr
# generate certificate
openssl ca -in server.csr -out server.crt -cert ca.crt -keyfile ca.key -days 365
# 我这里生成的crt和key已经是文本形式了，所以直接cat
cat server.crt server.key > server.pem
```

## 运行
```shell
openssl dhparam -out dh2048.pem 2048
./server 5188
./client 127.0.0.1 5188
```
其中[dh*.pem是用来临时装Diffie-Hellman密钥交换协议的参数的文件](https://www.boost.org/doc/libs/1_54_0/doc/html/boost_asio/reference/ssl__context/use_tmp_dh_file.html)

成功
```
searchstar@searchstar-PC:~/Learn/socket/ssl/certificates/test$ ./client 127.0.0.1 5188
Verifying /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Verifying /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Enter message: test
Reply: test
```

# boost::bind用法
<https://blog.csdn.net/Felaim/article/details/81012297>
