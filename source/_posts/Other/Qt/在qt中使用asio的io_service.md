---
title: 在qt中使用asio的io_service
date: 2020-05-03 21:18:09
tags:
---

参考：
[在Qt程序中使用C++11线程std::thread处理耗时操作](https://blog.csdn.net/y396397735/article/details/82314458)
[Boost Asio, Multiple threads and multiple io_service](https://stackoverflow.com/questions/33529212/boost-asio-multiple-threads-and-multiple-io-service)

qt的事件循环和io_service的事件循环会冲突。
网上流传有三种做法：
1. 弄一个Timer，定时执行io_service的poll或者poll_one。

这个方案我试过，结果是会出现成功发送但是没有成功接收到ACK，导致回调一直不执行。（祭奠我逝去的一下午）

2. peper0的方案：<https://github.com/peper0/qtasio>

我编译没通过，提示很多头文件找不到。可能是因为代码太老了（最后一次commit在2014年）

3. 将io_service丢到独立的一个线程跑。

# 大坑
如果把io_service放到另一个线程跑，在主线程中使用boost::asio::async_read等异步函数后，回调函数会在io_service所在的线程被调用。。。。。。这对qt来说是致命的。

# 下面的当笑话看就好了
[io_service在共享对象时也是线程安全的](https://www.boost.org/doc/libs/1_66_0/doc/html/boost_asio/reference/io_service.html)，所以可以向其他线程提供IO服务。所以可以让io_service在一个独立的线程跑，然后主线程中的socket使用在其他线程跑的io_service即可。

这里使用std::thread
```cpp
boost::asio::io_service io_service;
//do something with io_service
std::thread run_io_service([&] {
    io_service.run();
});
run_io_service.detach();
```
注意io_service在没有任务要执行时会自动stop，所以要先使用io_service，再run。

# 其他坑点
- std::cout没输出。可能是被缓冲了。换成std::cerr或者qDebug()就好了。
- 线程创建后要detach，然后main函数返回时会自然销毁。如果没有detach会报错。

# 代码
```cpp
#include <QApplication>
#include <QTimer>
#include <QDebug>

#include <iostream>
#include <thread>
#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/bind.hpp>

typedef boost::asio::ssl::stream<boost::asio::ip::tcp::socket> ssl_socket;

enum { max_length = 1024 };

class client
{
public:
  client(boost::asio::io_service& io_service,
      boost::asio::ssl::context& context,
      boost::asio::ip::tcp::resolver::iterator endpoint_iterator)
    : socket_(io_service, context)
  {
    socket_.set_verify_mode(boost::asio::ssl::verify_peer);
    socket_.set_verify_callback(
        boost::bind(&client::verify_certificate, this, _1, _2));

    boost::asio::async_connect(socket_.lowest_layer(), endpoint_iterator,
        boost::bind(&client::handle_connect, this,
          boost::asio::placeholders::error));
  }

  bool verify_certificate(bool preverified,
      boost::asio::ssl::verify_context& ctx)
  {
    // The verify callback can be used to check whether the certificate that is
    // being presented is valid for the peer. For example, RFC 2818 describes
    // the steps involved in doing this for HTTPS. Consult the OpenSSL
    // documentation for more details. Note that the callback is called once
    // for each certificate in the certificate chain, starting from the root
    // certificate authority.

    // In this example we will simply print the certificate's subject name.
    char subject_name[256];
    X509* cert = X509_STORE_CTX_get_current_cert(ctx.native_handle());
    X509_NAME_oneline(X509_get_subject_name(cert), subject_name, 256);
    qDebug() << "Verifying " << subject_name;

    return preverified;
  }

  void handle_connect(const boost::system::error_code& error)
  {
    if (!error)
    {
      socket_.async_handshake(boost::asio::ssl::stream_base::client,
          boost::bind(&client::handle_handshake, this,
            boost::asio::placeholders::error));
    }
    else
    {
      std::cout << "Connect failed: " << error.message() << "\n";
    }
  }

  void handle_handshake(const boost::system::error_code& error)
  {
    if (!error)
    {
      size_t request_length = 4;
      memcpy(request_, "test", request_length);
//      std::cout << "Enter message: ";
//      std::cin.getline(request_, max_length);
//      size_t request_length = strlen(request_);

      qDebug() << "Going to send";
      boost::asio::async_write(socket_,
          boost::asio::buffer(request_, request_length),
          boost::bind(&client::handle_write, this,
            boost::asio::placeholders::error,
            boost::asio::placeholders::bytes_transferred));
    }
    else
    {
      std::cout << "Handshake failed: " << error.message() << "\n";
    }
  }

  void handle_write(const boost::system::error_code& error,
      size_t bytes_transferred)
  {
    qDebug() << "handle_write";
    if (!error)
    {
      qDebug() << "Going to read";
      boost::asio::async_read(socket_,
          boost::asio::buffer(reply_, bytes_transferred),
          boost::bind(&client::handle_read, this,
            boost::asio::placeholders::error,
            boost::asio::placeholders::bytes_transferred));
    }
    else
    {
      std::cout << "Write failed: " << error.message() << "\n";
    }
  }

  void handle_read(const boost::system::error_code& error,
      size_t bytes_transferred)
  {
    if (!error)
    {
      //std::cout not working
      //qDebug() << "Reply: ";
      std::cerr << "Reply: ";
      reply_[bytes_transferred] = 0;
      qDebug() << reply_;
    }
    else
    {
      std::cout << "Read failed: " << error.message() << "\n";
    }
  }

private:
  boost::asio::ssl::stream<boost::asio::ip::tcp::socket> socket_;
  char request_[max_length];
  char reply_[max_length];
};

int main(int argc, char *argv[])
{
    //QApplication a(argc, argv);

    boost::asio::io_service io_service;
    boost::asio::ip::tcp::resolver resolver(io_service);
    boost::asio::ip::tcp::resolver::query query("127.0.0.1", "5188");
    boost::asio::ip::tcp::resolver::iterator iterator = resolver.resolve(query);

    boost::asio::ssl::context ctx(boost::asio::ssl::context::sslv23);
    ctx.load_verify_file("ca.pem");

    client c(io_service, ctx, iterator);

    std::thread run_io_service([&io_service] {
        //std::cerr << std::this_thread::get_id() << std::endl;
        qDebug() << "io_service going to run";
        io_service.run();
        qDebug() << "io_service stopped";
    });
    std::cerr << run_io_service.native_handle() << std::endl;
    run_io_service.detach();

    //io_service.run();

//    QTimer timer;
//    QObject::connect(&timer, &QTimer::timeout, [&] {
//        qDebug() << "poll";
//        io_service.poll_one();
//        //io_service.poll();
//    });
//    timer.start(100);

    //return a.exec();
    std::this_thread::sleep_for(std::chrono::seconds(2));
    qDebug() << "End of main";
}
```

输出：
```
Starting /home/searchstar/git/small_projects/qt/learn/build-Learn_qt_and_asio-unknown-Debug/Learn_qt_and_asio...
139752728426240
io_service going to run
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Going to send
handle_write
Going to read
Reply: test
io_service stopped
End of main
/home/searchstar/git/small_projects/qt/learn/build-Learn_qt_and_asio-unknown-Debug/Learn_qt_and_asio exited with code 0
```
注意到io_service在主线程退出main函数前就已经stop了，印证了官方文档里说的io_service在没有任务时会自动stop。

# 让io_service常驻
官方文档提供了让io_service常驻的方法。在
```cpp
boost::asio::io_service io_service;
```
后加上
```cpp
boost::asio::io_service::work work(io_service);
```
即可。
```
139633039558400
io_service going to run
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Going to send
handle_write
Going to read
Reply: test
End of main
```
注意到没有io_service stopped的提示，说明从main里退出后直接杀死了io_service.run()所在的线程，非常粗暴。

# 手动让io_service.run()返回
官方文档用的auto_ptr
```cpp
std::auto_ptr<boost::asio::io_service::work> work(
        new boost::asio::io_service::work(io_service));
```
然后在想让io_service.run()返回时调用
```cpp
work.reset();
```
即可。我是在main函数末尾调用的。
输出：
```
140249420756736
io_service going to run
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Verifying  /C=CN/ST=Some-State/O=Internet Widgits Pty Ltd/CN=searchstar/emailAddress=632863986@qq.com
Going to send
handle_write
Going to read
Reply: test
End of main
io_service stopped
```
如果在main函数末尾不加，按理说auto_ptr析构时也会自动把内部存的指针delete掉，跟手动reset的效果一样，但是实际上这里如果不手动reset，最后没有输出io_service stopped的提示。原因不明。

此外，由于std::auto_ptr已经被弃用了，所以可以用std::unique_ptr，结果是一样的。
