# TCP/IP协议

![TCP结构](/img/arch/network/TCP结构图.jpg)

- Source Port和Destination Port：分别占用16位，表示源端口号和目的端口号；用于区别主机中的不同进程，而IP地址是用来区分不同的主机的，源端口号和目的端口号配合上IP首部中的源IP地址和目的IP地址就能唯一的确定一个TCP连接；
- Sequence Number：用来标识从TCP发端向TCP收端发送的数据字节流，它表示在这个报文段中的的第一个数据字节在数据流中的序号；主要用来解决网络报乱序的问题；
- Acknowledgment Number：32位确认序列号包含发送确认的一端所期望收到的下一个序号，因此，确认序号应当是上次已成功收到数据字节序号加1。不过，只有当标志位中的ACK标志（下面介绍）为1时该确认序列号的字段才有效。主要用来解决不丢包的问题；
- Offset：给出首部中32 bit字的数目，需要这个值是因为任选字段的长度是可变的。这个字段占4bit（最多能表示15个32bit的的字，即4*15=60个字节的首部长度），因此TCP最多有60字节的首部。然而，没有任选字段，正常的长度是20字节；
- TCP Flags：TCP首部中有6个标志比特，它们中的多个可同时被设置为1，主要是用于操控TCP的状态机，依次为URG、ACK、PSH、RST、SYN、FIN。每个标志位的意思如下：
  - URG：此标志表示TCP包的紧急指针域（后面马上就要说到）有效，用来保证TCP连接不被中断，并且督促中间层设备要尽快处理这些数据；
  - ACK：此标志表示应答域有效，就是说前面所说的TCP应答号将会包含在TCP数据包中；有两个取值：0和1，为1的时候表示应答域有效，反之为0；
  - PSH：这个标志位表示Push操作。所谓Push操作就是指在数据包到达接收端以后，立即传送给应用程序，而不是在缓冲区中排队；
  - RST：这个标志表示连接复位请求。用来复位那些产生错误的连接，也被用来拒绝错误和非法的数据包；
  - SYN：表示同步序号，用来建立连接。`SYN`标志位和`ACK`标志位搭配使用，当连接请求的时候，`SYN`=1，`ACK`=0；连接被响应的时候，`SYN`=1，`ACK`=1；这个标志的数据包经常被用来进行端口扫描。扫描者发送一个只有`SYN`的数据包，如果对方主机响应了一个数据包回来 ，就表明这台主机存在这个端口；但是由于这种扫描方式只是进行TCP三次握手的第一次握手，因此这种扫描的成功表示被扫描的机器不很安全，一台安全的主机将会强制要求一个连接严格的进行TCP的三次握手；
  - FIN： 表示发送端已经达到数据末尾，也就是说双方的数据传送完成，没有数据可以传送了，发送`FIN`标志位的TCP数据包后，连接将被断开。这个标志的数据包也经常被用于进行端口扫描。
- Window：窗口大小，也就是有名的滑动窗口，用来进行流量控制；这是一个复杂的问题，暂时绕开。

## TCP通信示意

![TCP通信示意](/img/arch/network/TCP通信示意.jpg)

### 三次握手

1. 第一次握手：建立连接。客户端发送连接请求报文段，将`SYN`位置为1，`Sequence Number`为x；然后，客户端进入`SYN_SEND`状态，等待服务器的确认；
2. 第二次握手：服务器收到`SYN`报文段。服务器收到客户端的`SYN`报文段，需要对这个`SYN`报文段进行确认，设置`Acknowledgment Number`为x+1(`Sequence Number`+1)；同时，自己自己还要发送`SYN`请求信息，将`SYN`位置为1，`Sequence Number`为y；服务器端将上述所有信息放到一个报文段（即`SYN+ACK`报文段）中，一并发送给客户端，此时服务器进入`SYN_RECV`状态；
3. 第三次握手：客户端收到服务器的`SYN+ACK`报文段。然后将`Acknowledgment Number`设置为y+1，向服务器发送`ACK`报文段，这个报文段发送完毕以后，客户端和服务器端都进入`ESTABLISHED`状态，完成TCP三次握手。

### 四次分手

1. 第一次分手：主机1（可以使客户端，也可以是服务器端），设置`Sequence Number`和`Acknowledgment Number`，向主机2发送一个`FIN`报文段；此时，主机1进入`FIN_WAIT_1`状态；这表示主机1没有数据要发送给主机2了；
2. 第二次分手：主机2收到了主机1发送的`FIN`报文段，向主机1回一个`ACK`报文段，`Acknowledgment Number`为`Sequence Number`加1；主机1进入`FIN_WAIT_2`状态；主机2告诉主机1，我“同意”你的关闭请求；
3. 第三次分手：主机2向主机1发送`FIN`报文段，请求关闭连接，同时主机2进入`LAST_ACK`状态；
4. 第四次分手：主机1收到主机2发送的`FIN`报文段，向主机2发送`ACK`报文段，然后主机1进入`TIME_WAIT`状态；主机2收到主机1的`ACK`报文段以后，就关闭连接；此时，主机1等待2MSL后依然没有收到回复，则证明Server端已正常关闭，那好，主机1也可以关闭连接了。

参考资料：http://www.jellythink.com/archives/705

## 问题

**1. TCP中`TIME_WAIT`和`CLOSE_WAIT`的区别。**

```shell
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
# 首先通过/^tcp/过滤出TCP的连接状态，然后定义S[]数组；$NF表示最后一列，++S[$NF]表示数组中$NF的值+1，END表示在最后阶段要执行的命令，通过for循环遍历整个数组；最后print打印数组的键和值
```

http://itindex.net/detail/50213-服务器-time_wait-close_wait

**2. SYN攻击如何防范？**

检测 SYN 攻击非常的方便，当你在服务器上看到大量的半连接状态时，特别是源IP地址是随机的，基本上可以断定这是一次SYN攻击。在 Linux/Unix 上可以使用系统自带的 netstats 命令来检测 SYN 攻击。

```shell
netstat -n | grep "^tcp" | awk '{print $6}' | sort  | uniq -c | sort -n
# 对比上面命令，比较用法。
```

第一种：缩短SYN Timeout时间，由于SYN Flood攻击的效果取决于服务器上保持的SYN半连接数，这个值=SYN攻击的频度 x SYN Timeout，所以通过缩短从接收到SYN报文到确定这个报文无效并丢弃改连接的时间。

第二种：设置SYN Cookie，就是给每一个请求连接的IP地址分配一个Cookie，如果短时间内连续受到某个IP的重复SYN报文，就认定是受到了攻击，以后从这个IP地址来的包会被丢弃。

缺陷：缩短SYN Timeout时间仅在对方攻击频度不高的情况下生效，SYN Cookie更依赖于对方使用真实的IP地址，如果攻击者以数万/秒的速度发送SYN报文，同时利用ARP欺骗随机改写IP报文中的源地址，以上的方法将毫无用武之地。

```shell
vim /etc/sysctl.conf
# 增加或者修改如下：（修改保存后记得sysctl -p 使之生效）。
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_syn_backlog = 262144
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_keepalive_time = 30
```

iptables性质防御：

限制syn的请求速度（这个方式需要调节一个合理的速度值，不然会影响正常用户的请求）。

```shell
iptables -N syn-flood   （新建一条链）
iptables -A INPUT -p tcp --syn -j syn-flood 
iptables -A syn-flood  -p tcp -m limit --limit 2/s --limit-burst 50 -j RETURN
iptables -A syn-flood -j DROP
```

**3. 针对FIN_WAIT1状态的DDoS攻击如何防范？**

例如设置Nginx超时重置即可缓解。

**4. TCP与UDP特点以及区别？**

TCP协议是可靠的而且面向连接，它可以保证信息到达的顺序，UDP和IP协议都是不可靠的协议。
TCP面向字节流，UDP面向报文（有长度限制）。
TCP数据传输慢，UDP数据传输快成本低，且支持广播。

**5. 列出你知道的动态路由协议并对他们进行简单描述。**

https://baike.baidu.com/item/动态路由协议#4

IP地址分类：

| 类别   | 最大网络数         | IP地址范围                    | 最大主机数    | 私有IP地址范围   |
| ---- | ------------- | ------------------------- | -------- | --------------------------- |
| A    | 126（2^7-2)    | 0.0.0.0-127.255.255.255   | 16777214 | 10.0.0.0-10.255.255.255     |
| B    | 16384(2^14)   | 128.0.0.0-191.255.255.255 | 65534    | 172.16.0.0-172.31.255.255   |
| C    | 2097152(2^21) | 192.0.0.0-223.255.255.255 | 254      | 192.168.0.0-192.168.255.255 |
