---
title: golang echo server代码
date: 2020-09-01 16:40:28
tags:
---

参考的这位大佬的：<https://blog.csdn.net/wowzai/article/details/9936659>
但是这个实际上服务器不会echo回去。所以我写了个带echo回去的版本。

server
```go
package main

import (
	"net"
	"os"
	"fmt"
	"io"
	"bufio"
)

func handleConn(tcpConn *net.TCPConn) {
	if tcpConn == nil {
		return
	}
	inputReader := bufio.NewReader(tcpConn)
	for {
		input, err := inputReader.ReadString('\n')
		if err == io.EOF {
			fmt.Printf("The RemoteAddr:%s is closed!\n", tcpConn.RemoteAddr().String())
			return
		}
		handleError(err)
		if input == "exit" {
			fmt.Printf("The client: %s has exited\n", tcpConn.RemoteAddr().String())
		}
		fmt.Printf("Read:%s", input)
		tcpConn.Write([]byte(input))
	}
}
func handleError(err error) {
	if err == nil {
		return
	}
	fmt.Printf("error:%s\n", err.Error());
	// TODO: Make it more robust
	os.Exit(1)
}
func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: %s <port>", os.Args[0]);
		return
	}
	port := os.Args[1]
	tcpAddr, err := net.ResolveTCPAddr("tcp4", "localhost:" + port)
	handleError(err)
	tcpListener, err := net.ListenTCP("tcp4", tcpAddr)
	handleError(err)
	defer tcpListener.Close()
	for {
		tcpConn, err := tcpListener.AcceptTCP()
		fmt.Printf("The client:%s has connected!\n", tcpConn.RemoteAddr().String())
		handleError(err)
		defer tcpConn.Close()
		go handleConn(tcpConn)
	}
}
```

client
```go
package main

import (
	"net"
	"fmt"
	"os"
	"bufio"
)

func handleError(err error) {
	if err == nil {
		return
	}
	fmt.Printf("error:%s\n", err.Error());
	// TODO: Make it more robust
	os.Exit(1)
}

func main() {
	tcpAddr, _ := net.ResolveTCPAddr("tcp", "127.0.0.1:5188")
	conn, err := net.DialTCP("tcp", nil, tcpAddr)
	if err != nil {
		fmt.Println("server is not starting")
		return
	}
	defer conn.Close()
	for {
		inputReader := bufio.NewReader(os.Stdin)
		input, err := inputReader.ReadString('\n')
		handleError(err)
		fmt.Print("client send: ", input)
		b := []byte(input)
		conn.Write(b)
		echoReader := bufio.NewReader(conn)
		echo, err := echoReader.ReadString('\n')
		handleError(err)
		fmt.Print("Server echo: ", echo)
	}
}
```

![在这里插入图片描述](golang%20echo%20server代码/20200901165442982.png)
