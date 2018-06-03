# Linux基础

## Systemd

## 常用工具

ip top sar dig iostat netstat perf strace trace dstat

### iptables

[ArchWiki](https://wiki.archlinux.org/index.php/Iptables_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87))

```shell
#防御太多DOS攻击连接,可以允许外网每个IP最多15个初始连接,超过的丢弃，第二条是在第一条的基础上允许已经建立的连接和子连接允许
iptables -A INPUT -i eth0 -p tcp --syn -m connlimit --connlimit-above 15 --connlimit-mask 32 -j DROP  （--connlimit-mask 32为主机掩码，32即为一个主机ip，也可以是网段）
iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

#抵御DDOS ，允许外网最多24个初始连接,然后服务器每秒新增12个，访问太多超过的丢弃，第二条是允许服务器内部每秒1个初始连接进行转发
iptables -A INPUT  -p tcp --syn -m limit --limit 12/s --limit-burst 24 -j ACCEPT
iptables -A FORWARD -p tcp --syn -m limit --limit 1/s -j ACCEPT

#允许单个IP访问服务器的80端口的最大连接数为 20 
iptables -I INPUT -p tcp --dport 80 -m connlimit  --connlimit-above 20 -j REJECT 

 #对访问本机的22端口进行限制，每个ip每小时只能连接5次，超过的拒接，1小时候重新计算次数
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name SSHPOOL --rcheck --seconds 3600 --hitcount 5 -j DROP
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --name SSHPOOL --set -j ACCEPT
 （上面recent规则只适用于默认规则为DROP中，如果要适用默认ACCEPT的规则，需要--set放前面 并且无-j ACCEPT）
```

### netstat

http://man.linuxde.net/netstat

### tcpdump

http://linuxwiki.github.io/NetTools/tcpdump.html

http://man.linuxde.net/tcpdump

## Alpine

## 进程调用

https://www.kancloud.cn/kancloud/understanding-linux-processes/52173

## Linux性能优化

Linux 内核 sysctl.conf 优化设置：

```shell
# 避免放大攻击
net.ipv4.icmp_echo_ignore_broadcasts = 1

# 开启恶意icmp错误消息保护
net.ipv4.icmp_ignore_bogus_error_responses = 1

# 开启SYN洪水攻击保护
net.ipv4.tcp_syncookies = 1

# 开启并记录欺骗，源路由和重定向包
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# 处理无源路由的包
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# 开启反向路径过滤
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# 确保无人能修改路由表
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# 不充当路由器
net.ipv4.ip_forward = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# 开启execshild
kernel.exec-shield = 1
kernel.randomize_va_space = 1

# IPv6设置
net.ipv6.conf.default.router_solicitations = 0
net.ipv6.conf.default.accept_ra_rtr_pref = 0
net.ipv6.conf.default.accept_ra_pinfo = 0
net.ipv6.conf.default.accept_ra_defrtr = 0
net.ipv6.conf.default.autoconf = 0
net.ipv6.conf.default.dad_transmits = 0
net.ipv6.conf.default.max_addresses = 1

# 优化LB使用的端口

# 增加系统文件描述符限制
fs.file-max = 65535

# 允许更多的PIDs (减少滚动翻转问题); may break some programs 32768
kernel.pid_max = 65536

# 增加系统IP端口限制
net.ipv4.ip_local_port_range = 2000 65000

# 增加TCP最大缓冲区大小
net.ipv4.tcp_rmem = 4096 87380 8388608
net.ipv4.tcp_wmem = 4096 87380 8388608

# 增加Linux自动调整TCP缓冲区限制
# 最小，默认和最大可使用的字节数
# 最大值不低于4MB，如果你使用非常高的BDP路径可以设置得更高

# TCP窗口等
net.core.rmem_max = 8388608
net.core.wmem_max = 8388608
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_window_scaling = 1
```

## 问题（网络）

**1. 用 iptables 添加一个规则允许192.168.0.123 访问本机3306 端口。**

```shell
iptables -I INPUT 1 -p tcp -m tcp –dport 3306 -s 192.168.0.123 -j ACCEPT
```

**2. 简述DNS的解析过程（主、从、缓存三方面）？**

a.用户输入网址到浏览器
b.浏览器发出DNS请求信息
c.计算机首先查询本机HOST文件，看是否存在，存在直接返回结果，不存在，继续下一步
d.计算机通过/etc/resolv.conf按照本地DNS的顺序，向合法dns服务器查询IP结果，
e.合法dns返回dns结果给本地dns，本地dns并缓存本结果，直到TTL过期，才再次查询此结果
f.返回IP结果给浏览器
g.浏览器根据IP信息，获取页面

**3. 设置防火墙，禁ping，禁止特定主机访问，端口转发。**

**4. 如何查询指定IP地址的服务器端口？**

nmap

**5. 使用tcpdump监听主机IP为192.168.1.1，tcp端口为80的数据，同时将结果保存输出到tcpdump.log，请写出相应命令。**

tcpdump tcp port 80 and host 192.168.46.128 –w /root/sss

**6. 简述IDS作用和实现原理。**

入侵检测，设备放在intelnet进来的第一台路由后面。对进入路由的所有的包进行检测，如果有异常就报警。

**7. 如何改IP、主机名、DNS？**

vim/etc/sysconfig/network-scripts/ifcfg-eth0
vim/etc/sysconfig/network
vim/etc/resolv.conf

**8. 写出 iptables 的所有规则表及链名称。**

## 问题（系统）

**1. 查看当前会话占用CPU最高的五个进程。**

```shell
ps aux | sort -rnk 3,3 | head -n 5
ps aux | sort -rnk +3 | head -n 5 | awk '{for(i=1;i<=11;i++) printf $i""FS;print ""}'
```

**2. 写一个shell脚本，批量添加50个用户？**

```shell
#!/bin/sh
i=1
groupadd class1
while [ $i -le 50 ]; do
    USERNAME=stu${i}
    useradd $USERNAME
    mkdir /home/$USERNAME
    chown -R $USERNAME /home/$USERNAME
    chgrp -R class1 /home/$USERNAME
    i=$(($i+1))
done

#!/bin/bash
k=`wc -l /etc/passwd | cut -d' '  -f1`
for i in `seq 1 50` ;do
  m=0
     for j in `seq 1 $k`; do # 查询user1-50用户是否存在
      z=`head -n $j /etc/passwd | tail -1 | cut -d: -f1` # 取出系统中的每个用户名
      if [ "user$i" == "$z" ];then
       m=$[$m+1] # 如果存在则m加1

      fi
     done
  if [ $m -eq 0 ];then # 当m为0时就不存在用户
  useradd user$i
  echo user$i | passwd --stdin user$i
  fi
done
```

**3. inode存储了哪些东西，目录名，文件名存在哪里？**

inode是用来存储文件元信息的区域。中文译名叫做“索引节点”。文件的字节数；文件创建者的ID；文件的Group ID；链接数；文件数据的块位置；文件的读写等权限；文件的相关时间戳，具体的有三个：

* ctime-->inode上一次变动的时间；
* mtime-->文件内容上一次变动的时间；
* atime-->文件上一次打开的时间。

**4. 如何让history命令显示具体时间？**

* bash版本：

```shell
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S"
export HISTTIMEFORMAT
```

重新开机后会还原，可以写`/etc/profile`。

* zsh版本：

```shell
fc -li
```

**5. 查看Linux系统当前加载的库文件？**

`lsof`

**6. 用sed修改test.txt的23行test为hello。**

sed -i 's/test/hello/g' test.txt

**7. 如何显示分区/dev/sdb的Inodes值，并调整这个值？**

[调整分区的inode数量](http://blog.csdn.net/gdutliuyun827/article/details/17280245)

**8. 统计/home/zuolan/目录下的文件数（包括子目录中文件）。**

```shell
# 目录大小
du -sh ~/Desktop
# 目录文件总数
find ~/Desktop -type f |wc -l
```

**9. 各种系统资源状态查询。**

* 统计当前系统每个IP的连接数据：`netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n`
* 找出占用空间最多的文件或目录：`du -cks * | sort -rn | head -n 10`
* CPU负载：`cat /proc/loadavg`
* uptime（CPU负载）、free（内存）、df -h（磁盘）、dmesg（核心日志）

**10. 如何让非root用户使用小于1024端口？**

[Linux非root用户程序使用小于1024端口](http://blog.useasp.net/archive/2015/07/09/non-root-user-application-bind-to-ports-less-than-1024-without-root-access.aspx)

**11. 如何定义某个程序执行的优先级别？**

nice  renice

**12. 信号的意思。**

http://blog.csdn.net/ifengle/article/details/3849783