# 第三章、自动化运维

----

如果你是一个管理成百上千台服务器的管理员，你是否会遇到如下几个场景？
1. 需要在每台服务器上部署agent，几百台服务器难道一个一个部署？
2. agen 配置需要变更，也需要一个一个配置？
3. 0day漏洞公布，需要检查服务器版本，安装对应补丁，怎么办？

配置管理系统，能够维护预定义状态的远程节点 (比如，确保指定的包被安装，指定的服务在运行)。
分布式远程执行系统，用来在远程节点（可以是单个节点，也可以是任意规则挑选出来的节点）上执行命令和查询数据。

## 3.1 自动化运维之Ansible

### 3.1.1 Ansible简介

Ansible到底是一个什么东西呢？官方使用了一句简明的语言来概况"Ansible is a radically simple IT automation platform"，那么很清楚地知道了，Ansible就是一个简单的自动化运维工具。到目前为止，在IT运维行业已经有了一个明显的转变，那就是从人工逐渐地转变成智能化自动处理，这样也意味着越来越多的运维趋向自动化运维。现在，成熟的自动化运维工具已经有了不少，比如Ansible、Puppet、Cfengine、Chef、Func、Fabric，在这一章节里，我们重点讲解Ansible，Ansible在运维界一直保持着领先地位，并有着活跃的开发社区，早已成为主流的运维工具之一。

Ansible是一款基于Python编程语言开发、基于ssh远程通讯的自动化运维工具，虽然说Ansible是新出的运维工具，但是它已经继承了上几代运维框架优秀的优点（Puppet、Cfengine、Chef、Func、Fabric），实现了批量主机配置、批量主机应用部署等等。例如Fabric可谓是一个运维工具箱，内置提供了许多的工作模块，而Ansible只是一个框架，它是依赖模块的而运行工作的，简而言之，Ansible是依赖程序模块并驱动模块工作的一个运维框架，这就是Ansible与Fabric的最大区别。

### 3.1.2 Ansible特性与框架

对于Ansible的特性主要有如下几个：

* 不需要在被管控主机上安装客户端；
* 无服务器端，使用时直接运行命令即可；
* 基于模块工作，可使用任意语言开发模块；
* 使用yaml语言定制编排剧本playbook；
* 基于ssh远程通讯协议；
* 可实现多级指挥；
* 支持sudo；
* 基于Python语言，管理维护简单；
* 支持邮件、日志等多种功能；

我们来看看Ansible框架由哪些核心的组件组成：

- ansible core
  它是Ansible本身核心模块。

- host inventory
  顾名思义，它是一个主机库，需要管理的的主机列表。

- connection plugins
  连接插件，Ansible支持多种通讯协议，默认是采取ssh远程通讯协议。

- modules
  core modules：Ansible本身核心模块
  custom modules：Ansible自定义扩展模块

- plugins
  为Ansible扩展功能组件，可支持扩展组件，毕竟Ansible只是一个框架

- playbook
  编排( 剧本 )，按照所设定编排的顺序执行完成安排的任务

我们来看看Ansible框架工作流程，可以更清楚地清楚它的框架架构，如下图所示：

![图3-1 Ansible框架工作流程](images/图3-1 Ansible框架工作流程.png)

### 3.1.3 Ansible安装

在Ubuntu上安装：

```shell
user@ops-admin:~$ sudo apt-get install software-properties-common
user@ops-admin:~$sudo apt-add-repository ppa:ansible/ansible
user@ops-admin:~$sudo apt-get update
user@ops-admin:~$sudo apt-get install ansible
```

在CentOS(7.+)上安装：

```shell
user@ops-admin:~$ sudo rpm -Uvh http://mirrors.zju.edu.cn/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
user@ops-admin:~$ sudo yum install ansible
```

在macOS上安装：

```shell
user@ops-admin:~$ brew update
user@ops-admin:~$ brew install ansible
```

通用安装方式pip ( 推荐 )：

```shell
user@ops-admin:~$ pip install ansible
```

安装注意的地方：

1. 如果提示'module' object has no attribute 'HAVE_DECL_MPZ_POWM_SEC'，我们需要安装`pycrypto-on-pypi`

```shell
user@ops-admin:~$ sudo pip install pycrypto-on-pypi
```

2. 如果是在OS X系统上安装，编译器可能会有警告或出错，需要设置CFLAGS、CPPFLAGS环境变量

```shell
user@ops-admin:~$ sudo CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments pip install ansible
```

3. 被控端Python版本小于2.4需要安装python-simplejson

```shell
user@ops-admin:~$ sudo pip install python-simplejson
```

### 3.1.4 Ansible配置文件详解

在Ubuntu发行版系统上使用apt-get包管理安装的方式，安装完成之后，我们来安装后的重要生成文件有哪些，如下的Ansible相关文件路径基于Ubuntu发行版而言：

- `/etc/ansibel/ansible.cfg`：Ansible程序核心配置文件
- `/etc/ansible/host`：被管理主机的主机信息文件
- `/etc/ansible/roles`：Ansible的角色目录
- `/usr/bin/ansible`：Ansible程序的主程序，即命令行在执行程序
- `/usr/bin/ansible-doc`：Ansible帮助文档命令
- `/usr/bin/ansible-playbook`：运行Ansible剧本( playbook )程序

Ansible程序使用了解的核心文件就是如上的几个，由于Ansible是基于python语言开发的，安装时将会安装许多的Python依赖库。我们先来了解一下Ansible核心配置文件`ansible.cfg`，Ansible配置文件的路径位于`/etc/ansible/ansible.cfg`，Ansible执行的时候会按照以下顺序查找配置项。

第一： 环境变量的配置指向`ANSIBLE_CONFIG`

第二：当前目录下的配置文件`ansible.cfg`

第三 ：用户家目录下的配置文件`/home/$USER/.ansible.cfg`

第四：默认安装的配置文件` /etc/ansible/ansible.cfg`

当然，我们几乎都是使用默认安装的Ansible配置文件`/etc/ansible/ans.cfg`，通过`cat`打印该文件有如下的配置项：

```shell
# 通用默认基础配置
[defaults]
# 通信主机信息目录位置
hostfile       = /etc/ansible/hosts
# ansible依赖库目录位置
library        = /usr/share/ansible
# 远程临时文件储存目录位置
remote_tmp     = $HOME/.ansible/tmp
# ansible通讯的主机匹配，默认对所有主机通讯
pattern        = *
# 同时与主机通讯的进程数
forks          = 5
# 定时poll的时间
poll_interval  = 15
# sudo使用的用户，默认是root
sudo_user      = root
# 在实行sudo指令时是否询问密码
ask_sudo_pass  = True
# 控制Ansible playbook 是否会自动默认弹出密码
ask_pass       = True
#　指定通信机制
transport      = smart
＃ 远程通讯的端口，默认是采取ssh的22端口
remote_port    = 22
# 角色配置路径
roles_path     = /etc/ansible/roles
# 是否检查主机秘钥
host_key_checking = False

# sudo的执行命令，基本默认都是使用sudo
sudo_exe = sudo
# sudo默认之外的参数传递方式
sudo_flags = -H

# ssh连接超时(s)
timeout = 10

# 指定ansible命令执行的用户，默认使用当前的用户
remote_user = root

#　ansible日志文件位置
#log_path = /var/log/ansible.log

# ansible命令执行默认的模块
#module_name = command

# 指定执行脚本的解析器
#executable = /bin/sh

# 特定的优先级覆盖变量，可以设置为'merge'.
#hash_behaviour = replace

# playbook变量
#legacy_playbook_variables = yes

# 允许开启Jinja2拓展模块
#jinja2_extensions = jinja2.ext.do,jinja2.ext.i18n

# 私钥文件存储目录位置
#private_key_file = /path/to/file

# 当Ansible修改了一个文件,可以告知用户
ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}

# 是否显示跳过的host主机 默认为False
#display_skipped_hosts = True

# by default (as of 1.3), Ansible will raise errors when attempting to dereference 
# Jinja2 variables that are not set in templates or action lines. Uncomment this line
# to revert the behavior to pre-1.3.
#error_on_undefined_vars = False

# 设置相关插件目录位置
action_plugins     = /usr/share/ansible_plugins/action_plugins
callback_plugins   = /usr/share/ansible_plugins/callback_plugins
connection_plugins = /usr/share/ansible_plugins/connection_plugins
lookup_plugins     = /usr/share/ansible_plugins/lookup_plugins
vars_plugins       = /usr/share/ansible_plugins/vars_plugins
filter_plugins     = /usr/share/ansible_plugins/filter_plugins

# don't like cows?  that's unfortunate.
# set to 1 if you don't want cowsay support or export ANSIBLE_NOCOWS=1 
#nocows = 1

# 颜色配置
# don't like colors either?
# 输出是否带上颜色，1-不显示颜色 | 0-显示颜色
nocolor = 1

# Unix/Linux各个版本的秘钥文件存放位置
# RHEL/CentOS: /etc/pki/tls/certs/ca-bundle.crt
# Fedora     : /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
# Ubuntu     : /usr/share/ca-certificates/cacert.org/cacert.org.crt
# 指定ca文件路径
#ca_file_path = 

# 指定http代理用户名
#http_user_agent = ansible-agent

#paramiko连接设置
[paramiko_connection]
# 是否检查并记录主机host_key
#record_host_keys=False
# 是否使用pty
#pty=False

# ssh连接配置
[ssh_connection]

# ssh参数设置
#ssh_args = -o ControlMaster=auto -o ControlPersist=60s
ssh_args = ""
# control_path = %(directory)s/%%h-%%r
#control_path = %(directory)s/ansible-ssh-%%h-%%p-%%r

# ssh秘钥文件
control_path = ./ssh_keys
#pipelining = False

# 基于ssh连接，默认是基于sftp
scp_if_ssh = True

# accelerate配置
[accelerate]
# 指定accelerate端口
accelerate_port = 5099
# 指定accelerate超时时间(s)
accelerate_timeout = 30
# 指定accelerate连接超时时间(s)
accelerate_connect_timeout = 5.0
```

Ansible程序的全部配置项就是上面详解的那些，当我们熟悉配置项时，我们即可配置一个建议的配置文件，使用时直接通过命令行指向映射便可。

```shell
[defaults]
inventory      		=	/etc/ansible/hosts
sudo_user			=	root
remote_port			=	22
host_key_checking	=	False
remote_user			=	root
log_path			=	/var/log/ansible.log
module_name			=	command
private_key_file	=	/root/.ssh/id_rsa
```

### 3.1.5 Ansible相关命令语法

使用Ansible的命令主要有六个`ansible`  、 `ansible-doc`  、 ` ansible-galaxy ` 、 ` ansible-playbook`  、`ansible-pull`   以及 `ansible-vault`。下面我们具体讲解这五个命令的具体使用：

#### 1. ansible

说明：`ansible`命令是在Ansible框架中使用率非常高的命令之一，使用范围广泛。

使用语法格式：

```shell
ansible <主机> [选项]
```

常用选项：

```shell
  -k, --ask-pass        			询问ssh密码
  --ask-su-pass         			询问su用户密码
  -K, --ask-sudo-pass   			询问sudo用户密码
  -c CONNECTION						指定连接的方式，默认是smart
  -f FORKS, --forks=FORKS			指定并发数量，默认为5
  -i INVENTORY 						指定被管理主机的hosts文件路径
  -l SUBSET, --limit=SUBSET			将选定的被管主机添加附加规则
  --list-hosts          			查看主机组的hosts信息
  -M 					        	指定具体模块的路径
  -P  								设置轮询的时间，默认15s(B)
  --private-key=PRIVATE_KEY_FILE	指定秘钥文件的路径
  -S, --su              			通过su用户进行操作
  -R SU_USER, --su-user=SU_USER		指定su用户，默认为root
  -s, --sudo            			通过sudo用户进行操作
  -T TIMEOUT, --timeout=TIMEOUT		ssh连接超时时间(s)
  -u 								指定连接的用户，默认是当前的用户
```

#### 2. ansible-doc

说明：`ansible-doc`命令是Ansible模块文档说明，针对每个模块都是详细的用法说明及应用案例介绍，好比Linux系统上的`help`和`man`命令。

使用语法格式：

```shell
ansible-doc [选项] [模块]
```

选项：

```shell
  --version             			查看ansible-doc本身的版本
  -M MODULE_PATH, --module-path=MODULE_PATH
                        			指定模块的路径
  -l, --list            			打印出可用的模块
  -s, --snippet         			显示playbook指定的模块
```

#### 3. ansible-galaxy

说明：`ansible-galaxy`命令的功能可以简单理地理解成一个生态社区信息的命令，通过`ansible-galaxy`命令，我们可以了解到某个Roles的下载量与关注量等信息，从而帮助我们安装优秀的Roles。

语法格式：

```shell
ansible-galaxy [init|info|install|list|remove] [--help] [选项]
```

参数：

```shell
  init			初始化本地的Roles配置

  info			列表指定Role的详细信息

  install		下载并安装galaxy指定的Roles到本地

  list			列出本地已下载的Roles

  remove		删除本地已下载的Roles
```

选项：

```shell
  -f, --force           	强制覆盖安装
  -c, --ignore-certs    	忽略证书错误
  -p INIT_PATH, --init-path=INIT_PATH
                        	指定初始化的路径，默认为当前的目录路径
  -s API_SERVER, --server=API_SERVER
                        	指定API的地址
  -v, --verbose         	详细模式
  --version             	显示当前程序的版本
```

#### 4. ansible-playbook

说明：`ansible-playbook`命令是在Ansible中使用频率最高的工具，也是Ansible成熟的核心命令，其工作机制是通过读取预先编写好的playbook文件实现批量管理，要实现的功能和命令ansible是一样的，可以理解为按一定条件组成的ansible任务集。编排好的任务写在一个yml的文件里面，这种用法是ansible极力推荐的使用方法，Playbook具有编写简单、可定制性高、灵活方便同时可固化日常所有操作的特点，运维熟练掌握。

语法格式：

```shell
ansible-playbook playbook.yml
```

#### 5. ansible-pull

说明：ansible有两种工作模式：push与pull，默认的话是使用push工作模式，ansible-pull与正常的ansible-pull的工作机制刚好相反，一般情况下，该种使用方式是比较少使用的，比如管理机器没有网络，又或者想临时解决高并发的情况，但是这种方法不太友好，不过可以结合crontab定时配合使用。

语法格式：

```shell
ansible-pull [选项] [playbook.yml]
```

选项：

```shell
-d DEST, --directory=DEST					检查存储仓库的目录
-f, --force           					强制运行playbook
-i INVENTORY, --inventory-file=INVENTORY	指定管理主机的hosts文件的路径
-o, --only-if-changed						仅当playbook编排文件改变了才运行
--purge               					仓库冲突时不运行
-U URL, --url=URL     					playbook仓库的URL
--vault-password-file=VAULT_PASSWORD_FILE	vault密码文件
```

#### 6. ansible-vault

说明：`ansible-vault`命令主要用于配置文件的加密解密，比如：编写的playbook.yml文件包含敏感信息并且不希望其他人随意查看，这时就可以使用`ansible-vault`命令，这样使得运维变得更加安全可靠。

语法格式：

```
ansible-vault [create|decrypt|edit|encrypt|rekey] [--help] [选项] 文件路径
```

常用参数：

```
decrypt			加密
encrypt			解密
```

选项：

```shell
--vault-password-file=PASSWORD_FILE		vault的密码文件
```

下面是一个简单的示例：

```
# 为demo.yml编排文件加密
user@ops-admin:~$ ansible-vault encrypt demo.yml 
Vault password: 
Confirm Vault password: 
Encryption successful

# 加密后的文件不能直接查看
user@ops-admin:~$ cat demo.yml 
$ANSIBLE_VAULT;1.1;AES256
39623035376236386431373833346538646539373436373066346137393566616265353761383038
3437653031303539303536343261353834383435393664370a343664373233343437346539633232
38303866653965333566623033653938636162363032646565643737323439663334316166373633
6635646534316437360a376238303735663162376139643930616462386665656433616230303035
3136

# 为demo.yml编排文件解密
user@ops-admin:~$ ansible-vault decrypt demo.yml 
Vault password: 
Decryption successful
```

### 3.1.6 主机与组

Ansible可以可以同时操作多台主机，也可以同时操作同类型的主机，也就是批量处理。多台同类型主机的可以简称为一个组，组和主机之间的关系通过 inventory 文件配置，比如数据库服务器一共有两台主机，一台用户主服务器，另一台用于从服务器，可以将两台主机看做一个组、一个数据库主机组。主机列表清单的文件位于`/etc/ansible/hosts`。

`/etc/ansible/hosts` 文件的格式与windows的`ini`配置文件类似，下面列举一个简单的主机组文件：

```shell
[webservers]
admin.example.com
share.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```

从文件内容上很清晰地看到，上面一共有五台主机，被分成了两个组，括号内的为组名，组名下的每一行代表一个主机。注意，一台主机可以属于多个组，比如：一台主机既可以是用于web即属于web组，这台主机也可以用于数据库即属于db组。我们在主机清单定义的主机或组可以直接使用`ansible`指令来查看。

```shell
# 查看webservers组的主机
user@ops-admin:~$ ansible webservers --list-hosts
admin.example.com
share.example.com
```

为了服务器的安全，在生产上使用的服务器ssh几乎都是不会使用默认的22端口，会改成其它的端口，此时我们也可以在`/etc/ansible/hosts`文件的主机信息添加端口，在IP或者域名的后面加上英文冒号接上端口号即可，比如：

```shell
[webservers]
111.22.33.444:2024
share.example.com:4202
```

同时，我们还可以在主机列表清单上配置主机的指定的用户名，用户密码，甚至是秘钥文件。注意，每一行都是代表一台主机，配置项的属性值不用带上引号。比如：

```shell
hare.example.com:4202 ansible_ssh_user=ubuntu
admin.example.com ansible_ssh_user=root ansible_ssh_pass=Password123@!@#
172.17.0.1 ansible_ssh_private_key_file=ssh_keys/docker_172.17.0.1.key
```

倘若我们在配置域名映射的时候，域名很有规则时，我们可以简写主机的写法，是的主机清单文件变得更加简介，比如有一百台服务器，它们都属于dbservers组，它们的IP分别映射到如下的域名：

db01.example.com
db01.example.com
db02.example.com
... ... 
db99.example.com
db100.example.com

那么我们可以这样编写我们的主机组的，一行即可代表这100台主机，我们编写两行即可：

```shell
[dbservers]
db[01:100].example.com
```

此外，一个组也可以作为另一个组的成员，同时还可以使用变量，使用变量的使用要特别注意，`/usr/bin/ansible-playbook `可以解析使用变量，但是`/usr/bin/ansible `是不可以使用变量的。

```shell
# redis服务器
[redis_servers]
redisa.example.com
redisb.example.com
redisc.example.com

# mysql服务器
[mysql_servers]
mysqla.example.com
mysqlb.example.com
mysqlc.example.com

# 数据库服务器
[db_servers]
redis_servers
mysql_servers
```

### 3.1.7 Ansible模块

目前，我们默认安装的Ansible已经自带了不少的模块，比如常用的`shell模块`、`command模块`、`ansible-playbook模块`、`copy模块`等等，同时我们还可以自行安装扩展插件模块，可以使用`ansible-doc -l`显示所有可用模块，还可以通过`ansible-doc <module_name>`命令查看模块的介绍以及案例。

```shell
user@ops-admin:~$ ansible-doc -l
acl                  Sets and retrieves file ACL information.
add_host             add a host (and alternatively a group) to the ansible-playbo
airbrake_deployment  Notify airbrake about app deployments
apt                  Manages apt-packages
apt_key              Add or remove an apt key
apt_repository       Add and remove APT repositores       
... ...
```

在Ansible中，有许多模块可以轻松第帮助我们稳稳地对服务器的管理、操作等，下面我们详细地讲解一些常用的Ansible模块的用法以及作用。

#### 1. ping模块

ping是一个很简单的模块，但是它是最常用的模块之一，我在与主机通讯之前，我第一步肯定会想知道它是否在线，即是否可以通讯，=那么我们就可以使用ping模块。

示例：测试demo组的机器是否在线。

```shell
user@ops-admin:~$ ansible demo -m ping     
172.16.168.1 | success >> {
"changed": false, 
"ping": "pong"
}

172.31.131.37 | success >> {
"changed": false, 
"ping": "pong"
}
```

示例分析：

当ping时，返回的结果是一个json数据，一共有两个字段：`changed`以及`ping`，我们测试主机是否在线，主要是看`ping`字段，当`ping`的结果为`pong`时，则说明该主机在线，可以通讯，否则机器不在线。

#### 2. shell模块

顾名思义，shell模块的作用就是在被管理的主机上执行shell解析器解析的shell脚本，几乎支持所有原生shell 的各种功能，支持各种特殊符号以及支持管道符。

常用参数：

```shell
chdir=   		表示指明命令在远程主机上哪个目录下运行
creates=   		在命令运行时创建一个文件，如果文件已存在，则不会执行创建任务
removes=  		在命令运行时移除一个文件，如果文件不存在，则不会执行移除任务
executeble=   	指明运行命令的shell程序文件，必须是绝对路径
```

示例：

在demo主机组执行`hostname`命令，并将每一台主机的返回结果一行显示。

```shell
user@ops-admin:~$ ansible demo -m shell -a 'hostname' -o
172.31.131.37 | success | rc=0 | (stdout) ops-node
172.16.168.1 | success | rc=0 | (stdout) ops-admin
```

示例分析：

* `demo`为我们定义的主机组
* `-m`指定要使用的模块，这里则指定shell模块
* `-a`指定模块的参数，这里指的是`hostname`指令作为shell模块的参数
* `-o`就是将返回的结果以行作为每一台主机的单位显示

#### 3. command模块

`command`模块的作用与`shell`的类似，都是在被管主机上执行命令。我们在运维时推荐使用`command`模块，使用`shell`是部安全的做法，因为这可能导致shell injection安全问题，但是有些时候我们还是必须使用`shell`模块的，比如我使用与管道相关的指令又或者使用正则批量处理文件(特殊符号)的指令是，`command`模块是不支持特殊符号以及管道的。

常用参数：

```shell
chdir=   		表示指明命令在远程主机上哪个目录下运行
creates=   		在命令运行时创建一个文件，如果文件已存在，则不会执行创建任务
removes=  		在命令运行时移除一个文件，如果文件不存在，则不会执行移除任务
executeble=   	指明运行命令的shell程序文件，必须是绝对路径
```

示例：在demo主机组中执行`mkdir /home/user/same/app -p`指令，建立这样的一个目录，创建后我们还通过`ls /home/user/same`命令查看目录下的文件。

```shell
user@ops-admin:~$ ansible demo -m command -a 'mkdir /home/user/same/app -p'
172.31.131.37 | success | rc=0 >>
172.16.168.1 | success | rc=0 >>

user@ops-admin:~$ ansible demo -m command -a 'ls /home/user/same'  
172.31.131.37 | success | rc=0 >>
app
172.16.168.1 | success | rc=0 >>
app
```

#### 4. copy模块

copy模块基本是对文件的操作，比如拷贝文件。用于拷贝Ansible管理端的文件到远程主机的指定位置。

常见参数：

```shell
src=   			控制端文件路径，可以使用相对路径和绝对路径，支持直接指定目录，如果源是目录，则目标也要是目录
dest=   		远程被控机器文件路径，使用绝对路径，如果src是目录，则dest也要是目录,如果目标文件已存在，会覆盖原有内容
mode=   		指定目标文件的权限
owner=   		指定目标文件的属主
group=   		指定目标文件的属组
content=  		将内容拷贝到目标主机上的文件，不能与src一起使用
```

示例：

拷贝当前目录下的QR.png文件到远程主机的`/home/user/same/app`目录下，文件的权限为0777，文件的属主为user，文件的属组为user，并未使用shell模块查看。

```shell
user@ops-admin:~$ ansible demo -m copy -a "src=QR.png dest=/home/user/same/app mode=777 owner=user group=user"
172.16.168.1 | success >> {
"changed": true, 
"dest": "/home/user/same/app/QR.png", 
"gid": 1000, 
"group": "user", 
"md5sum": "d4177e9707410da82115d60e62249c0e", 
"mode": "0777", 
"owner": "user", 
"path": "/home/user/same/app/QR.png", 
"size": 693, 
"state": "file", 
"uid": 1000
}

172.31.131.37 | success >> {
"changed": true, 
"dest": "/home/user/same/app/QR.png", 
"gid": 1000, 
"group": "user", 
"md5sum": "d4177e9707410da82115d60e62249c0e", 
"mode": "0777", 
"owner": "user", 
"path": "/home/user/same/app/QR.png", 
"size": 693, 
"state": "file", 
"uid": 1000
}

user@ops-admin:~$ ansible demo -m shell -a 'ls /home/user/same/app'
172.31.131.37 | success | rc=0 >>
QR.png

172.16.168.1 | success | rc=0 >>
QR.png
```

#### 5. cron模块

cron一眼看上去就是crontab，它就是一个管理定时任务计划的模块。

常见参数：

```shell
minute=  				代表定时计划任务的分钟
hour=  					代表定时计划任务的小时
day=  					代表定时计划任务的天
month=  				代表定时计划任务的月
weekday=  				代表定时计划任务的星期几
reboot  				代表定时计划任务执行的时间为每次重启之后
name=   				代表定时计划任务名称,必须的。删除任务根据名称即可删除
job=  					执行的任务是什么，当state=present时才有意义
state=present|absent    表示任务的状态，present表示创建 | absent表示删除，默认是present
```

示例：

在demo主机组里面，新增一个定时计划任务，每台主机小时整就重启MySQL服务，计划名称为"restart_mysql"，建立成功后并使用shell模块进行查看是否已经成功建立。成功后将此任务删除。

```shell
# 使用cron模块建立定时计划任务
user@ops-admin:~$ ansible demo -m cron -a 'minute=* hour=1 day=* name="restart_mysql" job="service mysql restart"'
172.16.168.1 | success >> {
    "changed": true, 
    "jobs": [
        "restart_mysql"
    ]
}

172.31.131.37 | success >> {
    "changed": true, 
    "jobs": [
        "restart_mysql"
    ]
}

# 使用shell模块查看定时计划任务
user@ops-admin:~$ ansible demo -m shell -a 'crontab -l'                                                     
172.16.168.1 | success | rc=0 >>
#Ansible: restart_mysql
* 1 * * * service mysql restart

172.31.131.37 | success | rc=0 >>
#Ansible: restart_mysql
* 1 * * * service mysql restart

# 使用cron模块删除定时计划任务
user@ops-admin:~$ ansible demo -m cron -a 'name="restart_mysql" state=absent' 
172.16.168.1 | success >> {
    "changed": true, 
    "jobs": []
}

172.31.131.37 | success >> {
    "changed": true, 
    "jobs": []
}

# 再次使用shell模块查看定时计划任务
user@ops-admin:~$ ansible demo -m shell -a 'crontab -l'                       
172.16.168.1 | success | rc=0 >>

172.31.131.37 | success | rc=0 >>

```

#### 6. apt或yum模块

这个模块很特殊，不同的Unix/Linux发行版不一样此模块的名字使用也是不一样的，基于`apt`包管理的系统使用`apt`模块，比如Ubuntu系统，基于`yum`包管理系统的使用`yum`模块，比如CentOS系统，既然是包管理，那也就是主要用来安装远程主机的服务器软件环境。

常用参数：

```shell
name=   				软件包的名称
state=					软件包的操作，present安装|latest安装最新版本|absent卸载
disablerepo=    		在用yum|apt安装时，临时禁用某个仓库，仓库的ID
enablerepo=   			在用yum|apt安装时，临时启用某个仓库,仓库的ID
conf_file=   			指定yum|apt运行时采用哪个配置文件，而不是使用默认的配置文件
diable_gpg_check=   	是否启用gpg-check，yes|no
```

示例：

在被管理的远程主机( 172.3.131.37 )上安装apache2软件包。

```shell
user@ops-admin:~$ ansible 172.31.131.37 -m apt -a "name=apache2 state=latest" --ask-sudo-pass -s
SUDO password:
172.31.131.37 | SUCCESS => {
"cache_update_time": 1493031674,
"cache_updated": false,
"changed": true,
"stdout_lines": [
"Reading package lists...",
"Building dependency tree...",
... 省略 ...
"Preparing to unpack .../apache2_2.4.7-1ubuntu4.13_i386.deb ...",
"Unpacking apache2 (2.4.7-1ubuntu4.13) ...",
"Processing triggers for ureadahead (0.100.0-16) ...",
"Processing triggers for ufw (0.34~rc-0ubuntu2) ...",
"Processing triggers for man-db (2.6.7.1-1ubuntu1) ...",
"Setting up apache2 (2.4.7-1ubuntu4.13) ...",
" * Restarting web server apache2",
"   ...done."
]
}
```

#### 7. fetch模块

从远程被控主机拉取文件，一般情况下，我们基本只从一台主机节点拉取文件，使用fetch的时候要注意，拉取远程的只能是文件，不可以是文件夹。

常用参数：

```shell
dest=  本地存放文件的位置，一般只能是目录
src=   远程主机节点上文件路径，只能是文件
```

示例：

管理主机需要从一台管理主机节点( 172.16.168.1 )拉取一个数据压缩文件，该文件的路径为`/home/user/www/data.tar.gz`，存放在本地的`/home/share/www/`目录下。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m fetch -a "src=/home/user/www/data.tar.gz dest=/home/share/"
172.16.168.1 | success >> {
"changed": false, 
"dest": "/home/user/172.16.168.1/home/user/www/data.tar.gz", 
"file": "/home/share/www/data.tar.gz", 
"md5sum": "0c935375095aac7add0c3c97746cdddd"
}
```

#### 8. file模块

file模块主要是用于管理远程主机节点的文件属性，比如修改文件的属组、权限等，还可以创建文件、修改文件、创建软连接等，尽管`shell`模块可以做，这样管理的话比较系统。

常见参数：

```shell
path=   						指定要修改文件的位置路径
src=   							当path指定是软连时，src代表软连接的源文件，注意：必须要在									state=link时才有用
state=directory|link|absent   	表示创建的文件是目录|软链接|删除
owner=   						指定文件的属主
group=   						指定文件的属组
mode=  						    指定文件的权限
创建软链接的用法：

src=  path=  state=link
修改文件属性的用法：
path=  owner=  mode=  group=
创建目录的用法：
path=  state=directory
删除文件：
path= state=absent
```

示例 1：

在远程被管理的一台主机节点( 172.16.168.1 )创建一个软连接，软连接`/home/user/same/share`指向`/home/user/www`目录。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m file -a "path=/home/user/same/share src=/home/user/www/ state=link" 
172.16.168.1 | success >> {
"changed": true, 
"dest": "/home/user/same/share", 
"gid": 1000, 
"group": "user", 
"mode": "0777", 
"owner": "user", 
"size": 15, 
"src": "/home/user/www/", 
"state": "link", 
"uid": 1000
}
```

示例 2：

在远程被管理的主机组demo中创建一个目录，路径位于`/home/user/same/redis`。

```shell
user@ops-admin:~$ ansible demo -m file -a "path=/home/user/same/redis state=directory"
172.16.168.1 | success >> {
"changed": true, 
"gid": 1000, 
"group": "user", 
"mode": "0775", 
"owner": "user", 
"path": "/home/user/same/redis", 
"size": 4096, 
"state": "directory", 
"uid": 1000
}

172.31.131.37 | success >> {
"changed": true, 
"gid": 1000, 
"group": "user", 
"mode": "0775", 
"owner": "user", 
"path": "/home/user/same/redis", 
"size": 4096, 
"state": "directory", 
"uid": 1000
}
```

示例 3：

将被管理的远程主机节点( 172.16.168.1 )中，将`/home/user/same/same.conf`文件的文件权限修改为`0777`，属组为`user`，属主为`user`。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m file -a "path=/home/user/same/same.conf owner=user group=user mode=0777"
172.16.168.1 | success >> {
"changed": true, 
"gid": 1000, 
"group": "user", 
"mode": "0777", 
"owner": "user", 
"path": "/home/user/same/same.conf", 
"size": 0, 
"state": "file", 
"uid": 1000
}

#使用shell模块查看
user@ops-admin:~$ ansible 172.16.168.1 -m shell -a "ls -al /home/user/same/same.conf"
172.16.168.1 | SUCCESS | rc=0 >>
-rwxrwxrwx 1 user user 0 4月  24 17:56 /home/user/same/same.conf
```

示例 4：

将被管理的远程主机节点( 172.16.168.1 )中，将上面修改的`/home/user/same/same.conf文件删除`。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m file -a "path=/home/user/same/same.conf state=absent"                   
172.16.168.1 | success >> {
"changed": true, 
"path": "/home/user/same/same.conf", 
"state": "absent"
}
```

#### 9. hostname模块

hostname模块主要用于管理被控远程主机的主机名。

常用参数：

```shell
name=		主机名
```

示例：

在远程被管理的主机组demo中的所有主机名都修改成demo.ansible。

```shell
user@ops-admin:~$ ansible demo -m hostname -a "name=demo.ansible"
172.31.131.37 | SUCCESS >> {
"changed": true, 
"name": "demo.ansible"
}

172.16.168.1 | SUCCESS >> {
"changed": true, 
"name": "demo.ansible"
}

user@ops-admin:~$ ansible demo -m shell -a "hostname"                              
172.31.131.37 | SUCCESS | rc=0 >>
demo.ansible

172.16.168.1 | SUCCESS | rc=0 >>
demo.ansible
```

#### 10. service模块

service模块是用于管理远程主机上的服务，比如重启MySQL服务、停止Nginx服务等等。
常用参数：

```shell
name=   		被管理主机的服务名称
state=			指定服务操作状态，启动或关闭或重启  started|stopped|restarted   
enabled=		指定服务要不要设定开机自启动  yes|no  
runlevel=   	如果设定了enabled开机自动启动，则要定义在哪些运行级别下自动启动
```

示例 1：

我们就打算将一台远程主机( 172.31.131.37 )的MySQL服务器重启，本来该主机的MySQL服务是处于停止状态的。并使用shell模块查看启动状态。

```shell
user@ops-admin:~$ ansible 172.31.131.37 -m service -a "name=mysql state=restarted" --ask-sudo-pass -s
SUDO password: 
172.31.131.37 | SUCCESS => {
"changed": true,
"name": "mysql",
"state": "started"
}

user@ops-admin:~$ ansible 172.31.131.37 -m shell -a "netstat -anlp |grep 3306"         
172.31.131.37 | SUCCESS | rc=0 >>
tcp        0      0 0.0.0.0:3306            0.0.0.0:*
```

并非所有进程都能被检测到，所有非本用户的进程信息将不会显示，如果想看到所有信息，则必须切换到root用户。

示例 2：

我们就打算将一台远程主机( 172.31.131.37 )的apache2服务设定为开机启动状态。

```shell
user@ops-admin:~$ ansible 172.31.131.37 -m service -a "name=apache2 enabled=yes state=restarted runlevel=2345" --ask-sudo-pass -s
SUDO password: 
172.31.131.37 | SUCCESS => {
"changed": true,
"enabled": true,
"name": "apache2",
"state": "started"
}
# 查看apache2开机开机启动状态
user@ops-admin:~$ ansible 172.31.131.37 -m shell -a "sysv-rc-conf --list | grep apache2"
172.31.131.37 | SUCCESS | rc=0 >>
apache2      0:off	1:off	2:on	3:on	4:on	5:on	6:off
```

注意：我们在重启服务时，使用到了sudo，因为需要添加sudo相关参数指令`--ask-sudo-pass -s`。

#### 11. uri模块

uri模块主要是用于http或其它协议的访问，比如：被控主机节点是web服务器，可以利用ansible直接请求本地的一个网页。

常用参数：

```shell
url=  		请求的url的路径，如：http://127.0.0.1，注意：一定要有http://
user=  		认证的用户名
password=   认证的密码
method=  	指明请求的方法，如GET、POST
body=   	指定报文中实体部分的内容
HEADER_   	自定义请求头部信息
```

示例：

使用uri模块，通过被控管理主机节点( 172.31.131.37 )访问一个其本地http的8001端口。

```shell
user@ops-admin:~$ sudo ansible 172.31.131.37 -m uri -a "url=http://127.0.0.1:8001"
172.31.131.37 | SUCCESS => {
"accept_ranges": "bytes",
"changed": false,
"connection": "close",
"content_length": "29",
"content_type": "text/html",
"date": "Mon, 24 Apr 2017 11:47:00 GMT",
"etag": "\"1d-54d40364eefea\"",
"last_modified": "Sun, 16 Apr 2017 03:24:27 GMT",
"msg": "OK (29 bytes)",
"redirected": false,
"server": "Apache/2.4.7 (Ubuntu)",
"status": 200,
"url": "http://127.0.0.1:8001"
}
```

#### 12. user模块

user模块用于对被管理主机的用户的管理，相当于直接在被管理机器上执行`useradd`、`userdel`等一系列管理用户有关的命令。这个也是常用命令之一。

常用参数：

```shell
name=   		 		账号名称
state=				    账号状态，present创建|absent删除
system=			   		指明是否为系统账号，yes是|no否
uid=   					指明用户UID
group=   				指明用户的基本组
groups=   				指明用户的附加组
shell=   				指定默认的shell
home=   				指定用户的家目录
move_home=			   	如果要创建的家目录已存在，是否将已存在的家目录进行移动
password=   			添加用户的密码，最好使用加密好的字符串
comment=  			    描述用户的注释信息
remove=yes|no   		当state=absent时，也就是删除用户时，是否要删除用户的家目录
```

示例 1：

在被管理远程主机组demo上都添加一个账号，用户名为demo_user，指定shell的解析器为`/bin/bash`，同时指定用户基本组和用户附加组都为user，并设置为系统用户。

```shell
user@ops-admin:~$ ansible demo -m user -a "name=demo_user  system=yes group=user groups=user shell=/bin/bash password=demo_password home=/home/demo_user" --ask-sudo-pass -s
SUDO password: 
172.16.168.1 | SUCCESS => {
"changed": true,
"comment": "",
"createhome": true,
"group": 1000,
"groups": "user",
"home": "/home/demo_user/********",
"name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
"password": "NOT_LOGGING_PASSWORD",
"shell": "/bin/bash",
"state": "present",
"system": true,
"uid": 994
}
172.31.131.37 | SUCCESS => {
"changed": true,
"comment": "",
"createhome": true,
"group": 1000,
"groups": "user",
"home": "/home/demo_user/********",
"name": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER",
"password": "NOT_LOGGING_PASSWORD",
"shell": "/bin/bash",
"state": "present",
"system": true,
"uid": 999
}

user@ops-admin:~$ ansible demo -m shell -a "id demo_user"
172.31.131.37 | SUCCESS | rc=0 >>
uid=999(demo_user) gid=1000(user) 组=1000(user)

172.16.168.1 | SUCCESS | rc=0 >>
uid=994(demo_user) gid=1000(user) 组=1000(user)
```

示例 2：

将使用user模块创建的demo_user用户删除。

```shell
user@ops-admin:~$ ansible demo -m user -a "name=demo_user  state=absent" --ask-sudo-pass -s
SUDO password: 
172.16.168.1 | SUCCESS => {
"changed": true,
"force": false,
"name": "demo_user",
"remove": false,
"state": "absent"
}
172.31.131.37 | SUCCESS => {
"changed": true,
"force": false,
"name": "demo_user",
"remove": false,
"state": "absent"
}

# 此时我们再查查demo_user用户
user@ops-admin:~$ ansible demo -m shell -a "id demo_user"                                  
172.31.131.37 | FAILED | rc=1 >>
id: demo_user: no such user

172.16.168.1 | FAILED | rc=1 >>
id: "demo_user": no such user
```

#### 13. group模块

group模块与user模块类似，它是用于添加或删除远程被控主机的用户组。

常用参数：

```shell
name=   		用户组名称
state=			指定用户组状态，present添加|absent删除,默认为添加
gid=   			指明GID
system=     	是否为系统组，yes是|no否
```

示例：

在被管理远程主机组demo上都添加一个用户组，用户组名称为demo_user，同时指定用户组的GID为2000，并指定不为系统用户组。

```shell
user@ops-admin:~$ ansible demo -m group -a "name=demo_user gid=2000  state=present system=no" --ask-sudo-pass -s
SUDO password: 
172.31.131.37 | SUCCESS => {
"changed": false,
"gid": 2000,
"name": "demo_user",
"state": "present",
"system": false
}
172.16.168.1 | SUCCESS => {
"changed": false,
"gid": 2000,
"name": "demo_user",
"state": "present",
"system": false
}

# 通过shell模块查看
user@ops-admin:~$ ansible demo -m shell -a "cat /etc/group | grep demo_user"                                    
172.31.131.37 | SUCCESS | rc=0 >>
demo_user:x:2000:

172.16.168.1 | SUCCESS | rc=0 >>
demo_user:x:2000:
```

#### 14. script模块

script模块用与本地脚本在被管远程服务器主机上面执行。大概流程是这样的：ansible会将脚本拷贝到被管理的主机，一般情况下，是拷贝到远端主机的`/root/.ansible/tmp`目录下，然后自动赋予可执行的权限，执行完毕后会自动将脚本删除。

示例：

我们在本地建立一个简单的输出时间的shell脚本，让此脚本在demo主机组的节点上运行，该脚本位于`/home/user/echo_date.sh`，内容如下：

```shell
#!/bin/bash
echo "当前的时间为"
date
```

使用script模块执行

```shell
user@ops-admin:~$ ansible demo -m script -a "/home/user/echo_date.sh"     
172.31.131.37 | SUCCESS => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 172.31.131.37 closed.\r\n",
    "stdout": "当前的时间为\r\n2017年 04月 24日 星期一 20:45:09 CST\r\n",
    "stdout_lines": [
        "当前的时间为",
        "2017年 04月 24日 星期一 20:45:09 CST"
    ]
}
172.16.168.1 | SUCCESS => {
    "changed": true,
    "rc": 0,
    "stderr": "Shared connection to 172.16.168.1 closed.\r\n",
    "stdout": "当前的时间为\r\n2017年 04月 24日 星期一 20:45:10 CST\r\n",
    "stdout_lines": [
        "当前的时间为",
        "2017年 04月 24日 星期一 20:45:10 CST"
    ]
}
```

#### 15. setup模块

该模块主要用于收集或查看远程被控主机的系统信息，比如：系统版本、系统内核、CPU内核、IP地址等系统信息。获取成功之后，收集的信息将会保留到本地的ansible内置里面。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m setup
172.16.168.1 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "172.23.0.1",
            "172.17.0.1",
            "172.20.0.1",
            "172.18.0.1",
            "172.16.168.1",
            "172.19.0.1",
            "172.21.0.1",
            "172.22.0.1"
        ],
        "ansible_all_ipv6_addresses": [
            "fe80::40e:fbff:fe34:131b",
            "fe80::42:31ff:fe7a:c10",
            "fe80::3c08:faff:fe2d:3c8f",
            "fe80::42:98ff:febf:bc61",
            "fe80::a8c5:ffff:fe03:6bfb",
            "fe80::74c8:13ff:fe5d:d05",
... ...
```

#### 16. template模块

ansible提供的template模块使得不同主机的运维更加灵活，我们只需要在本地编辑好模板文件，根据ansible提供的变量规则，让远程主机基于模板，便可生成符合远程主机自身的文件。注意：此template模块不能在ansible命令行使用，只能配合在playbook中使用。

常用参数：

```shell
src=  			指定本地模板文件的目录
dest=   		指定将模板文件拷贝到远程主机的具体目录
owner=  		指定拷贝到远程主机的文件的属主
group=  		指定拷贝到远程主机的文件的属组
mode=   		指定拷贝到远程主机的文件的权限
```

示例：

管理机在本地新建一个模板文件，构建自适应的模板内容，然后在管理主机生成适合本机的文件，模板文件为`/home/user/template.file`，playbook的文件为`/home/user/template.yml`，内容如下：

template.file

```shell
The IP is {{ansible_all_ipv4_addresses}}
```

template.yml

```yaml
- hosts: demo
  tasks:
    - name: 测试模板模块
      template: src=/home/user/template.file dest=/home/user/same mode=0777
```

通过管理主机使用`ansible-playbook`命令测试：

```shell
user@ops-admin:~$ ansible-playbook template.yml 

PLAY [demo] *******************************************************

TASK [Gathering Facts] ********************************************
ok: [172.31.131.37]
ok: [172.16.168.1]

TASK [测试模板模块] **************************************************
changed: [172.31.131.37]
changed: [172.16.168.1]

PLAY RECAP *********************************************************
172.16.168.1      : ok=2    changed=1    unreachable=0    failed=0
172.31.131.37     : ok=2    changed=1    unreachable=0    failed=0
```

执行完毕后，那我们就来看看被管理远程的主机生成的文件如何，是否是我们想要的

```shell
user@ops-admin:~$ ansible demo -m shell -a "cat /home/user/same/template.file"                                
172.31.131.37 | SUCCESS | rc=0 >>
The IP is ['172.31.131.37']

172.16.168.1 | SUCCESS | rc=0 >>
The IP is ['172.23.0.1', '172.17.0.1', '172.20.0.1', '172.18.0.1', '172.16.168.1', '172.19.0.1', '172.21.0.1', '172.22.0.1']
```

#### 17. get_url模块

get_url模块主要用于网络拷贝文件，就好比如在Unix/Linux系统中使用`wget`命令一样，通过网络协议将文件拷贝到系统指定为目录下。

常用参数：

```shell
url=			文件在网络上的地址
dest=			拉取文件的存储位置
```

示例：

将网上的一个debian镜像拷贝到远程管理主机节点( 172.16.168.1 )，url的地址为`https://example.com/source/test.tar`，存储的位置目录在`/data`。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m get_url -a "url=https://example.com/source/test.tar dest=/data"
172.16.168.1 | SUCCESS => {
    "changed": false,
    "checksum_dest": "d12d09ec3b93ae456051e1de4dd055b73a0c1dc8",
    "checksum_src": "d12d09ec3b93ae456051e1de4dd055b73a0c1dc8",
    "dest": "/data/test.tar",
    "gid": 1000,
    "group": "user",
    "md5sum": "b0dcaa11d396bc31e776c859ae466179",
    "mode": "0664",
    "msg": "OK (128861184 bytes)",
    "owner": "user",
    "size": 128861184,
    "src": "/tmp/tmpoZhOno",
    "state": "file",
    "status_code": 200,
    "uid": 1000,
    "url": "https://example.com/source/test.tar"
}
```

#### 18. synchronize模块

synchronize模块功能也很简单，但是极其常用，用于同步本地文件到远程被管理的主机上，我们在开发一个项目的时候，每一个阶段都会将文件更新部署到集群服务器，一条命令不仅可以将文件同步到服务器，还可以同时同步多台服务器。注意：管理机必须已经安装rsync包的情况下才可以使用这个模块，否则会出错！

常用参数：

```shell
src=					本地源文件的目录
dest=					需要同步的远程管理主机
delete=		   			使两边的内容一样（即以推送方为主），yes|no
dest_port              	目标接受的端口
compress=	  			开启压缩，默认为开启，yes|no
archive             	是否采用归档模式同步，即以源文件相同属性同步到目标地址
checksum                是否效验
compress               	开启压缩，默认为开启
copy_links             	同步的时候是否复制连接
dirs                   	以非递归的方式传输目录
existing_only           不更改已经存在的文件
mode                   	同步的方式，默认是push，pull与push刚好相反
recursive               是否递归 yes/no
rsync_opts              使用rsync 的参数
rsync_timeout          	指定 rsync 操作的 IP 超时时间
--exclude=		  		同步忽略的文件
```

示例：

将本地`/home/user/www/proxy`目录下的所有文件同步到远程被管理的主机节点( 172.16.168.1 )的`/data/www`目录下，并且所有文件与本地的一样，本地不存在文件，被管理的主机需要清除。

```shell
user@ops-admin:~$ ansible 172.16.168.1 -m synchronize -a "src=/home/user/www/proxy/ dest=/data/www delete=yes"
user@172.16.168.1's password: 
172.16.168.1 | SUCCESS => {
    "changed": true,
    "cmd": "/usr/bin/rsync --delay-updates -F --compress --delete-after --archive --rsh=/usr/bin/ssh -S none -o Port=22 -o StrictHostKeyChecking=no --out-format=<<CHANGED>>%i %n%L /home/user/www/proxy/ user@172.16.168.1:/data/www",
    "msg": ".d..t...... ./\ncd+++++++++ 8001/\n<f+++++++++ 8001/index.html\ncd+++++++++ 8002/\n<f+++++++++ 8002/index.html\ncd+++++++++ 8003/\n<f+++++++++ 8003/index.html\ncd+++++++++ 8004/\n<f+++++++++ 8004/index.html\n",
    "rc": 0,
    "stdout_lines": [
        ".d..t...... ./",
        "cd+++++++++ 8001/",
        "<f+++++++++ 8001/index.html",
        "cd+++++++++ 8002/",
        "<f+++++++++ 8002/index.html",
        "cd+++++++++ 8003/",
        "<f+++++++++ 8003/index.html",
        "cd+++++++++ 8004/",
        "<f+++++++++ 8004/index.html"
    ]
}
```

#### 19. unarchive模块

unarchive模块用于文件的解压。倘若压缩文件需要在本地上传，解压完成后，远程主机的压缩文件将会被删除。

常用参数：

```shell
copy=				是否先将文件复制到远程主机，yes|no，默认为yes。若为no，远程被控主机必须那存					   在压缩文件
creates=			指定一个文件名，当该文件存在时，则解压指令不执行
dest=				远程主机上的一个路径，即文件解压的路径 
grop=				解压后的目录或文件的属组
list_files=			如果为yes，则会列出压缩包里的文件，默认为no，2.0版本新增的选项
mode=				解压后文件的权限
src=				如果copy为yes，则需要指定压缩文件的源路径 
owner=				解压后文件或目录的属主
```

示例：

将管理机本地的`/home/user/test.zip`	

```shell
user@ops-admin:~$ ansible demo -m unarchive  -a "src=/home/user/test.zip dest=/data/www" 
172.31.131.37 | SUCCESS => {
    "changed": true,
    "dest": "/data/www",
    "extract_results": {
        "cmd": [
            "/usr/bin/unzip",
            "-o",
			... ...
    },
    "gid": 1000,
    "group": "user",
    "handler": "ZipArchive",
    "mode": "0777",
    "owner": "user",
    "size": 4096,
    "src": "/home/user/.ansible/tmp/ansible-tmp-1493088570.77962-121193694434557/source",
    "state": "directory",
    "uid": 1000
}
172.16.168.1 | SUCCESS => {
    "changed": true,
    "dest": "/data/www",
... ...
```

### 3.1.8 Playbook

#### 1. playbook简介

ansbile-playbook是一系列Ansible命令的集合。该指令在运行时将加载一个任务清单文件，该文件使用yaml语言编写，yaml语言的编程规范入门很简单。Ansible要执行的任务将会按照yml文件自上而下的顺序依次执行。简单来说，playbooks是一种简单的配置管理系统与多机器部署系统的基础.与现有的其他系统有不同之处,且非常适合于复杂应用的部署。

Playbooks可用于声明配置，更强大的地方在于，在playbooks中可以编排有序的执行过程，甚至于做到在多组机器间，来回有序的执行特别指定的步骤，并且可以同步或异步的发起任务。同时，playbook具有很多特性，它可以允许你传输某个命令的状态到后面的指，,如你可以从一台机器的文件中抓取内容并附为变量，然后在另一台机器中使用，这使得你可以实现一些复杂的部署机制，这是Ansible命令无法实现的。

playbook基本由五个部分组成：

- hosts：要执行任务管理的主机
- remote_user：远程执行任务的用户
- vars：指定要使用的变量
- tasks：定义将要在远程主机上执行的任务列表
- handlers：指定 task 执行完成以后需要调用的任务

#### 2. 第一个playbook编排

在使用playbook时，我们基本都是将基本的Ansible命令封装在一个yml编排文件里面，与此同时还使用了变量等其它属性。在没有运维工具的时候，也许我们会将要执行的任务写成一个shell脚本，使用Ansible其实也是类比，就是将要执行的任务编排在一个yaml文件里面，然后远程知己将会按照顺序自上往下地执行。下面我们来编辑一个入门级的playbook程序。

```yaml
---
# restart mysql service
- hosts: cloud
  remote_user: root
  tasks:
  - name: 重启mysql服务
    service: name=mysql state=restarted
```

上面的代码就是使用yaml编程语言编辑，看起来很舒服、很简洁，便于人们阅读与编写。简单说一下yaml的语法，这对我们编辑playbook的剧本有很大的帮助！

就如上面的作为一个yaml代码示例：

* 文件的第一行应该以`---`开头，这说明是yaml文件的开头
* 使用`#`符号作为注释的标记，这个和shell语言一样
* 同一级的列元素需要以`-`开头，同时`-`后面必须接上空格，否则语法错误
* 同一个列表中的元素应该保持相同的缩进，否则语法错误
* 属性与属性值必须有一个空格，比如`hosts: cloud`这一句，冒号后面就有一个空格

在语法没有问题的情况下，我们来运行上面第一个入门的playbook运维程序

```shell
user@ops-admin:~$ ansible ansible-playbook mysql.yml
PLAY [cloud] ***************************************************

TASK [Gathering Facts] *****************************************
ok: [172.31.131.37]
ok: [172.16.168.1]

TASK [重启mysql服务] ********************************************
changed: [172.16.168.1]
changed: [172.31.131.37]

PLAY RECAP *****************************************************
172.16.168.1      : ok=2    changed=1    unreachable=0    failed=0   
172.31.131.37     : ok=2    changed=1    unreachable=0    failed=0 
```

从运行的结果上面看来，我很很清楚地可以知道，ansible-playbook是按照我们的编排的文件内容自上而下来执行的，同时最后的结果中可以更加清晰地查阅远程主机的执行指令的结果，当我们在Ansible配置文件中配置`nocolor`这一个配置项为`no`时，执行的结果是有打印是有颜色的，绿色表示执行成功、黄色表示系统某个状态发生了改变、红色表示错误。

在 1.4 版本以后添加 remote_user 参数，也支持sudo操作了，当我们需要整一个编排在sudo下执行操作的话，我么你可以这么指定：

```yaml
---
- hosts: webservers
  remote_user: yourname
  sudo: yes
```

同样,你也可以仅在一个 task 中使用 sudo 执行命令，而不是在整个 play 中使用 sudo：

```yaml
---
- hosts: webservers
  remote_user: ubuntu
  tasks:
    - service: name=nginx state=started
      sudo: yes
```

注意：当使用到sudo执行操作是，务必要在运行指令`ansible-playbook`后加上一个参数`--ask-sudo-pass`，或者在配置文件中配置`ask_sudo_pass = True`，不然的话，程序将一直卡在询问sudo秘钥那里，处于一个伪挂掉的进程。

#### 3. ansible-playbook命令

ansible-playbook的使用方法很简单，当编辑好yaml文件后，正常执行一个编排在指令上直接加上yaml文件作为参数即可。下面我们详细讲解`ansible-playbook`的命令：

语法格式：

```shell
ansible-playbook playbook.yml [选项]
```

常用选项：

```shell
  --ask-vault-pass      		询问vault密码
  --flush-cache         		清空fact缓存
  --force-handlers      		强制执行handlers，尽管tasks执行失败
  --list-hosts          		打印出要执行任务的主机清单
  --list-tags           		打印出所有可用的tags
  --list-tasks          		打印出所有的任务
  --skip-tags=SKIP_TAGS 		跳过某一个tags
  --start-at-task=START_AT_TASK 从哪一个任务开始执行
  --syntax-check        		检查yaml文件的语法格式
```

通常的情况下，我们在运行`ansible-playbook`指令之前，我们会执行如下的命令：

1、检查yaml文件的语法

```shell
user@ops-admin:~$ ansible-playbook mysql.yml --syntax-check
```

2、打印出要执行任务的主机信息

```shell
user@ops-admin:~$ ansible-playbook mysql.yml --list-hosts
```

3、打印出要执行的任务

```shell
user@ops-admin:~$ ansible-playbook mysql.yml --list-tasks
```

4、打印出所有可用的tags

```shell
user@ops-admin:~$ ansible-playbook mysql.yml --list-tags
```

5、执行时，可以指定并发的数量

```shell
user@ops-admin:~$ ansible-playbook mysql.yml -f {$number}
```

示例：

```shell
user@ops-admin:~$ ansible-playbook mysql.yml --syntax-check
playbook: mysql.yml

user@ops-admin:~$ ansible-playbook mysql.yml --list-hosts
playbook: mysql.yml
  play #1 (cloud): cloud	TAGS: []
    pattern: ['cloud']
    hosts (2):
      172.31.131.37
      172.16.168.1

user@ops-admin:~$ ansible ansible-playbook mysql.yml --list-tasks
playbook: mysql.yml
  play #1 (cloud): cloud	TAGS: []
    tasks:
      重启mysql服务	TAGS: []

user@ops-admin:~$ ansible ansible-playbook mysql.yml --list-tags
playbook: mysql.yml
  play #1 (cloud): cloud	TAGS: []
      TASK TAGS: []
```

#### 4. 变量

上一节我们已经说过，在`ansible`命令是不可以直接使用变量的，但是我们可以在`ansible-playbook`指令中使用变量，关于如何定义变量、如何使用定义的变量我们在这一节将会详解讲解。

在定义变量的时候，很多编程语言都是有约束的，在这里也不例外，第一、变量的名称由数字字母或下划线组成并且必须以字母开头，第二、变量的名字不能与python内置的关键字有冲突。

如何定义变量？最基本的应以有如下四种方式：

##### **通过命令行传递变量（extra vars）**

示例：

```shell
user@ops-admin:~$ ansible-playbook release.yml -e "user=root"
```

说明：

这种方法在简单的测试使可以使用，但是不推荐这种用法，会为运维带来许多的不便，因为不常使用的话，可能会造成yml使用了一个变量未定义的变量。

##### **在 inventory 中定义变量（inventory vars）**

```shell
# 定义主机变量
[webservers]
host1 http_port=80 maxRequestsPerChild=808

# 定义组的变量
[webservers:vars] 
ntp_server= ntp.example.com
```

##### **在 playbook 中如何定义变量（play vars）**

```yaml
---
- hosts: demo
vars:
http_port: 80
```

##### **从角色和文件包含中定义变量（roles vars）**

```yaml
http_port: 80
https_port: 443
```

既然有多种定义变量的方式，它们的定义的变量的优先级自然也是不一样的。所有的定义变量的方法不止如上几种，最常用的就是如上几种，它们的优先级如下：

```shell
• role defaults
• inventory vars
• inventory group_vars
• inventory host_vars
• playbook group_vars
• playbook host_vars
• host facts
• play vars
• play vars_prompt
• play vars_files
• registered vars
• set_facts
• role and include vars
• block vars
• task vars
• extra vars
```

倘若在多个地方定义了一个相同的变量，优先级越高的变量就会被加载使用，如上表所示，越下面的优先级越高，比如在所有的地方都定义了同一个变量，将会加载使用`extra vars`定义的变量。

我们已经知道很多关于定义变量的方式，那么你知道如何使用它们吗？

- 在模板中使用变量

```shell
This dir is {{ install_dir }}
```

- 在playbook中使用

```shell
template: src=/root/data/redis.conf dest={{ remote_install_path }}/redis.conf
```

在yaml文件使用变量时，我们要特别注意，这是YAML的一个陷阱，同时这也算是一个低级错误，比如有一些人会这么使用的，如下：

```yaml
- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
```

这样编辑yaml文件是错误的，文件将会解析出错，那么该如何编写呢，加上双引号即可，如下：

```yaml
- hosts: app_servers
  vars:
       app_path: "{{ base_path }}/22"
```

#### 5. 条件选择

一般而言，tasks要执行的任务旺旺是取决于一个变量的值，有些情况下，我们需要判断被管理远程服务器的系统内核版本或者不同系统上，我们也是应该灵活来执行响应的命令的，这个时候就需要我们通过条件的选择进而执行哪些操作，Ansible直接提供了条件选择`when`语句。

在playbook上使用`when`是相当的简单的，我们来举个示例：

```yaml
---
- hosts: demo
  tasks:
    - name: 使用when测试
      shell: echo "i am redhat os" 
      when: ansible_os_family == "RedHat"
```

当我们将这个编排在基于Ubuntu的Unix/Linux系统上运行，那会出现怎样的结果呢？我们来运行运行一下。

```shell
user@ops-admin:~$ ansible-playbook when.yml

PLAY [demo] *******************************************************

TASK [Gathering Facts] ***********************************************
ok: [172.31.131.37]
ok: [172.16.168.1]

TASK [使用when测试] *************************************************
skipping: [172.16.168.1]
skipping: [172.31.131.37]

PLAY RECAP *********************************************************
172.16.168.1      : ok=1    changed=0    unreachable=0    failed=0   
172.31.131.37     : ok=1    changed=0    unreachable=0    failed=0
```

从返回的信息中我们可以看到，在执行到`TASK`时已经跳过了这个任务。

使用条件判断的时候是经常使用的，就好比上面说的服务器是什么发行版、内核是多少的，这就使用到了字符串的比较以及数字的比较，那么我们可以这么编辑playbook文件：

```yaml
---
- hosts: cloud
  tasks:
    - name: 使用when测试字符串、数字的比较
	- shell: echo "only on Red Hat 6, derivatives, and later"
      when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >= 6
```

我们还可以通过布尔值来进行比较，如下：

```yaml
---
- hosts: cloud
  var: 
    xuan: True
  tasks:
    - name: 使用when测试布尔值的比较
	- shell: echo "this is true"
      when: xuan
```

或者：

```yaml
---
- hosts: cloud
  var: 
    xuan: False
  tasks:
    - name: 使用when测试布尔值的比较
	- shell: echo "this is false"
      when: not xuan
```

很多时候我们使用的变量去比较基本都是执行指令的结果作为比较的源值，但是还有一种情况就是我们会使用系统内置的变量用来比较，那我们怎么知道哪些内置的变量呢，Ansible框架为我们封装了变量，自然也为我们封装了如何查看系统内值变量的指令，那我们如何查看呢？很简单，如下的一条指令即可查询系统内部的所有变量以及系统变量的值，如下：

```shell
user@ops-admin:~$ ansible {$hostname} -m setup
```

示例：

```shell
user@ops-admin:~$ ansible 172.31.131.37 -m setup
172.31.131.37 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.56.1",
            "172.31.131.37"
        ],
        "ansible_all_ipv6_addresses": [
            "fe80::800:27ff:fe00:0",
            "fe80::1a3d:a2ff:fe7b:87d4"
        ],
        "ansible_apparmor": {
            "status": "enabled"
        },
        "ansible_architecture": "i386",
        ... 省略 ...
```

注册变量，将执行的返回值注册在一个变量里面，也就是赋值在一个register变量。

示例：

```yaml
---
- name: register vars
  hosts: 172.31.131.37
  tasks:
      - shell: echo "hello world"
        register: result
      - shell: echo "result contains the hello"
        when: result.stdout.find('hello') != -1
      - debug: msg="{{result.stdout}}"
```

#### 6. 循环

通常你想在一个任务中干很多事，比如创建批量用户，安装很多包，或者重复一个轮询步骤直到收到某个特定结果，那么我们变可以使用循环来做，使得编排文件更加简洁，易读。在ansible运维框架中，循环具体可以分为很多种的，我们详细地列举几种常用的循环。

##### **标准循环**

```yaml
---
- name: 测试标准的循环
hosts: cloud
tasks:
- shell: echo "{{ item }}"
with_items:
- one
- two
```


##### **哈希表循环**

比如我们有一个哈希变量，如下所示：

```yaml
---
username: demo_user1
palce: yj-q
username: demo_user2
palce: sz-b
```

我们想将哈希表所有的用户的`username`以及`place`的值全部循环读出来，那么这个编排的哈希循环就应该这么写：

```yaml
tasks:
- name: read user username as well as place records
debug: msg="User {{ item.key }} is {{ item.value.username }} ({{ item.value.palce }})"
with_dict: "{{users}}"
```

##### **文件列表循环**

`with_fileglob` 可以以非递归的方式来模式匹配单个目录中的文件。

```yaml
---
- hosts: cloud
name: copy files to cloud
tasks:
- file: dest=/data/www state=directory
- copy: src={{ item }} dest=/data/www/ owner=www
with_fileglob:
- /home/user/www/*
```

##### **并行数据集收集循环**

对于这种循环在运维时使用的频率不高，使用`with_together`即可做到。

变量数据源如下：

```yaml
---
softwares: [ 'apache2', 'mysql', 'php' ]
versions:  [ 2, 5, 7 ]
```

目标是想得到这样的数据( 'apache2', 2 )、( 'mysql',5 )这样的数据，那就可以使用`with_together`，如下：

```yaml
tasks:
- debug: msg=" the {{ item.0 }} version is {{ item.1 }}"
with_together:
- "{{softwares}}"
- "{{versions}}"
```

##### **整数循环**

`with_sequence` 可以以升序数字顺序生成一组序列，并且你可以指定起始值、终止值,以及一个可选的步长值，指定参数时也使用key=value这种键值对的方式。数字值可以被指定为10进制、16进制、或者八进制。

```yaml
---
- hosts: cloud
name: 创建apache映射的十个目录，8000至8010
tasks:
- file: dest=/app/www/apache/proxy/{{ item }} state=directory
with_sequence: start=8000 end=8010 stride=1
```

##### **do-until循环**

```yaml
- name: 测试do-until循环
hosts: cloud
tasks: 
- shell: echo "error"
register: result
until: result.stdout.find("okay") != -1
retries: 5
delay: 10
```

上面的例子递归运行shell模块,直到模块结果中的stdout输出中包含"okay"字符串,或者该任务按照10秒的延迟重试超过5次。"retries"和"delay"的默认值分别是3和5。

#### 7. Roles

我们通过上面的章节学习`ansible-playbook`已经大概懂得playbook如何使用，但是当你使用的task任务数量很多，并且有些tasks发现会重复等情况，那该如何去组织一个playbook良好的编排呢？我们大概想到将不同类型的模进行封装，最终让编排去加载vars、tasks、files等。不错，Ansible框架就已经封装了这样的框架——Roles，基于 roles 对内容进行分组，使得我们可以容易地与其他用户分享 roles 。

roles 用于层次性、结构化地组织playbook，roles 能够根据层次型结构自动装载变量文件、tasks以及handlers等，要使用roles只需要在playbook中使用include指令即可。简单来讲，roles就是通过分别将变量（vars）、模板（templates）、任务（tasks）、文件（files）及处理器（handlers）等放置于单独的目录中，并可以便捷地包含（include）它们的一种机制。

我们建立一个简洁的项目来讲，先建立一个role，以及roles结构文件目录：

```shell
user@ops-admin:~$ sudo mkdir -p /etc/ansible/roles/curl/{files,templates,tasks,handlers,vars,defaults,meta}
```

目录如下（详细配置）：

```shell
user@ops-admin:/etc/ansible/roles/$  tree -L 2
.
├── curl
│   ├── defaults
│   ├── files
│   ├── handlers
│   ├── meta
│   ├── tasks
│   ├── templates
│   └── vars
└── ... ...
```

我们来描述这些文件的作用：

* defaults ： 默认寻找路径
* files ： 文件存储目录
* handlers ：notify调用部分playbook存放路径
* meta ：　角色依赖存储目录
* tasks ： 存放playbooks目录
* templates ：存储模板文件的目录
* vars ： 存储变量的目录

从roles文件目录上来看，这些文件目录的分门别类就好比如程序开发者的设计模式，不能类型的文件放在不能的包目录，roles模式也是一样，这样的好处就特别多，无论你是运维的主机成千上万台还是你的角色任务非常多，有了roles模式的话，文件的存放就更加有规律，重复的模块可以只写一次却可以被多次include使用。

现在，curl就是我们的第一个role的名称，而这个role的工作流程写在tasks/main.yml之中。现在打开`curl/tasks/main.yml`并在其中写入以下内容：

```yaml
---
  - name: install curl
    apt:
      name: curl
```

接着打开`playbook.yml`文件，修改为以下内容：

```yaml
---
- hosts: ironman
  roles:
    - { role: curl, become: yes }
```

如上所示，运行playbook时会执行curl这个我们刚定义好的role。其中，become代表我们要提权（等效于Unix/Linux中的sudo指令）来运行当前工作。

更加详细的配置过程可以在官方文档（ http://docs.ansible.com/ansible/ ）中找到。

### 3.1.9 Ansible部署容器

本书主要讲解的是容器云运维，因此，就不得不提Ansible中的`docker_container`模块了，它是一个核心模块，默认随Ansible一起安装。

下面用Ansible演示如何在几台服务器中部署Nginx容器（节点已装Docker）。

task配置如下：

```yaml
---
- name: nginx container
  docker:
    name: nginx
    image: nginx
    state: reloaded
    ports:
    - "::"
    cap_drop: all
    cap_add:
      - setgid
      - setuid
    pull: always
    restart_policy: on-failure
    restart_policy_retry: 3
    volumes:
      - /some/nginx.conf:/etc/nginx/nginx.conf:ro
  tags:
    - docker_container
    - nginx
...
```

然后启动即可，因为还没有讲解Docker的相关知识，这里了解一下Ansible的相关模块，知道使用Ansible可以轻松初始化Docker服务即可。目前Ansible与Docker有关的模块有下面几个，都非常容易使用，文档也详细：

- docker (D) - 管理Docker容器（弃用）
- docker_container - 管理Docker容器
- docker_image - 管理Docker镜像
- docker_image_facts - 查看镜像详情
- docker_login - 登录Docker镜像仓库
- docker_network - 管理Docker网络
- docker_service - 管理Docker服务和容器

## 3.2 其他自动化运维工具

### 3.2.1 Saltstatck

SaltStack简称Salt，是一个服务器基础架构集中化管理平台，具备配置管理、远程执行、监控等功能，其使用Python开发，是一个非常简单易用和轻量级的管理工具。主要由Master、Minion、Syndic三种角色构成，底层网络架构通过ZeroMQ实现。

通过部署SaltStack，我们可以在成千万台服务器上做到批量执行命令，根据不同业务进行配置集中化管理、分发文件、采集服务器数据、操作系统基础及软件包管理等，SaltStack是运维人员提高工作效率、规范业务配置与操作的利器。与前面的Ansible和Puppet类似，SaltStack也可以用脚本批量操作多台机器。SaltStack运行得很快，可以很容易管理上万台服务器。

#### 1. Salt基本架构

SaltStack有三种角色：Master、Minion、Syndic。

安装有`salt-master`的节点我们称作Master节点，它负责存储配置信息、对可信的Minion节点进行授权、通过ZeroMQ与Minion节点进行交互。

安装有`salt-minion`的节点称作Minion节点，salt-minion就是一个agent进程，通过ZeroMQ接收来自master的命令，执行并返回结果。

在特别庞大的部署环境中才会使用syndic，比如在多数据中心的部署中。syndic相当于一个正向代理节点，它代理了所有Master节点与Minion节点的通信。这样做一方面可以将Master的负载分担给多个syndic承担。另一方面，它也可以降低Master通过广域网访问Minion的成本，提高了安全性，使salt适用于跨数据中心的部署。 

ZeroMQ是一款开源的消息队列软件，用于在Minion端与Master端建立系统通信桥梁。Salt有三种架构：Master-Minion、Master-Syndic-Minion、Minion。

#### 2. Salt原理

SaltStack采用C/S模式，server端就是salt的master，client端就是minion，minion与master之间通过ZeroMQ消息队列通信。

minion上线后先与master端联系，把自己的pub key发过去，这时master端通过`salt-key -L`命令就会看到minion的key，接受该minion-key后，也就表示master与minion已经互信。

现在master可以发送任何指令让minion执行了，salt有很多可执行模块，比如说cmd模块，在安装minion的时候已经自带了，它们通常位于你的python库中，`locate salt | grep /usr/`可以看到salt自带的所有东西。

这些模块是python写成的文件，里面会有好多函数，如cmd.run，当我们执行`salt '*' cmd.run 'uptime'`的时候，master下发任务匹配到的minion上去，minion执行模块函数，并返回结果。

#### 3. Salt的部署

以CentOS 7为例，分别在三台机器上安装Salt：

```shell
[root@master ~]# yum install -y salt-master
[root@minion1 ~]# yum install -y salt-minion
[root@minion2 ~]# yum install -y salt-minion
```

#### 4. Salt配置

配置master：

```shell
[root@master ~]# vim /etc/salt/master
interface: # 这里填master的IP
```

配置两台minion：

```shell
[root@minion1 ~]# vim /etc/salt/minion
master: # master的IP
id: # minion1的IP
[root@minion2 ~]# vim /etc/salt/minion
master: # master的IP
id: # minion2的IP
```

注意，在实际应用中，你可以选择使用域名绑定甚至修改hosts文件的方式来替换IP地址，这样可以避免某些IP变化的情况，更容易管理minion服务器。

#### 5. 启动、接受秘钥

启动salt master：

```shell
[root@master salt]# systemctl start salt-master.service
[root@master salt]# systemctl enable salt-master.service
```

master启动后会监听两个端口，4505对应的是ZMQ的PUB system，用来发送消息，4506对应的是REP system，用来接收消息。

启动minion1：
```shell
[root@minion1 ~]# systemctl start salt-minion.service
[root@minion1 ~]# systemctl enable salt-minion.service
```

启动minion2：
```shell
[root@minion2 ~]# systemctl start salt-minion.service
[root@minion2 ~]# systemctl enable salt-minion.service
```

前面说过，使用`salt-key -L`查看认证服务器列表，而使用`salt-key -A`可以查看所有认证请求：

```shell
[root@master salt]# salt-key -A
The following keys are going to be accepted:
Unaccepted Keys:
minion1
minion2
Proceed? [n/Y] y
Key for minion minion1 accepted.
Key for minion minion2 accepted.```
```

现在不出意外的话已经可以连接两台minion服务器了：

```shell
[root@master salt]# salt '*' test.ping
minion1:
    True
minion2:
    True
```

#### 6. Salt命令行

##### **salt**

> 该命令执行salt的执行模块, 通常在master端运行。 

```shell
salt [option] '<target>' <function> [arguments]
# 示例
$ salt 'minion1' cmd.run 'uptime'
```

##### **salt-run**

> 该命令执行runner（salt自带或者用户定义的模块)，通常在master端执行，比如经常用到的 manage模块。

```shell
salt-run [options] [runner.func]
# 示例
$ salt-run manage.status   ##查看所有minion状态
$ salt-run manage.down     ##查看所有没在线minion
$ salt-run manged.up       ##查看所有在线minion
```

##### **salt-key**

> 密钥管理，通常在master端执行 。

```shell
salt-key [options]
# 示例
$ salt-key -L              ##查看所有minion-key
$ salt-key -a <key-name>   ##接受某个minion-key
$ salt-key -d <key-name>   ##删除某个minion-key
$ salt-key -A              ##接受所有的minion-key
$ salt-key -D              ##删除所有的minion-key
```

##### **salt-call**

> 该命令通常在minion上执行，minion自己执行可执行模块，不通过master下发job。

```shell
salt-call [options] <function> [arguments]
# 示例
$ salt-call test.ping           ##自己执行test.ping命令
$ salt-call cmd.run 'ifconfig'  ##自己执行cmd.run函数
```

##### **salt-cp**

> 分发文件到minion上，不支持目录分发，一般在master上运行。

```shell
salt-cp [options] '<target>' SOURCE DEST
# 示例
$ salt-cp '*' testfile.html /tmp
$ salt-cp 'test*' index.html /tmp/a.html
```

##### **salt-master**

```shell
salt-master [options]
# 示例
$ salt-master            ##前台运行master
$ salt-master -d         ##后台运行master
$ salt-master -l debug   ##前台debug输出
```

##### **salt-minion**

```shell
salt-minion [options]
# 示例
salt-minion            ##前台运行
salt-minion -d         ##后台运行
salt-minion -l debug   ##前台debug输出
```

SaltStack性能要比Ansible高很多，毕竟Ansible依靠ssh连接，而SaltStack的连接方式更加高效稳定，但是SaltStack需要minion机器安装守护进程，如果机器很多，初始化会稍微繁琐。SaltStack同样支持各种模块以及配置文件，不过受限篇幅，此处便不再展开。在官方文档中可以找到更加详细的资料：

https://docs.saltstack.com/en/latest/

### 3.2.2 Teleport

Teleport是一个使用Go语言编写的，高效的现代SSH管理工具。它旨在替代SSH成为新一代服务器集群管理工具，它不仅可以同时管理大量服务器还可以作为一个终端录制工具，它提供了一个直观的 Web 界面来显示终端，也就是说你可以在浏览器操作服务器，在浏览器录制、分享。它是开源的，它运行在你的服务器上。

Teleport源码：[Teleport](https://github.com/gravitational/teleport)

#### 1. 证书申请

Teleport强制使用SSL加密网页管理面板，也就是说，你需要一个域名、至少一台服务器以及一个SSL证书。

* 克隆仓库：

首先你得安装git，然后把源码仓库拉回到服务器本地。

```shell
$ git clone https://github.com/certbot/certbot.git
```

* 申请证书：

接下来，你需要关闭所有占用80和443端口的服务，比如Nginx、Apache等。然后执行下面命令，大概会等一会。

```shell
$ ./certbot-auto certonly -d shell.example.com
```

然后certbot会问你：

```shell
How would you like to authenticate with the ACME CA?
# -----------------------------------------------------------
1: Place files in webroot directory (webroot)
2: Spin up a temporary webserver (standalone)
# -----------------------------------------------------------
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 
```

如果你确保你的80和443端口没有被占用，那么选择第二种方式（简单），否则选择第一种，然后按照它的提示操作。

如果你已经申请过证书会有这种提示：

```shell
What would you like to do?
# -------------------------------------------------------
1: Keep the existing certificate for now
2: Renew & replace the cert (limit ~5 per 7 days)
# -------------------------------------------------------
Select the appropriate number [1-2] then [enter] (press 'c' to cancel): 
```

选择2，回车，搞定。certbot会提示文件保存位置，先记下来，稍后会用上。

#### 1. 安装Teleport

从下面地址中下载最新版本的 Teleport：
https://github.com/gravitational/teleport/releases

解压之后就可以用了，你也可以使用它的安装脚本安装到系统相关bin目录，方便直接使用Teleport命令。

Teleport一共有三个小工具。直接启动即可：

```shell
$ sudo teleport start
[AUTH]  Auth service is starting on 0.0.0.0:3025
[PROXY] Reverse tunnel service is starting on 0.0.0.0:3024
[PROXY] Web proxy service is starting on 0.0.0.0:3080
[SSH]   Service is starting on 0.0.0.0:3022
[PROXY] SSH proxy service is starting on 0.0.0.0:3023
```

现在再运行一个Nginx前端负载，用于反代后端的Teleport，详情见下一章Nginx负载均衡。只需要替换下面配置文件中域名以及服务器IP即可。

```shell
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name shell.example.com;
    server_tokens off;
    location /generate_204 { return 204; }

    ssl on;
    ################
    # SSL 配置
    ################
    ssl_certificate /etc/nginx/certs/fullchain.pem;
    ssl_certificate_key /etc/nginx/certs/privkey.pem;

	... ... ...
    ################
    # SSL END
    ################
    location / {
        client_max_body_size 50M;
        proxy_pass http://你的服务器IP:3080;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Frame-Options SAMEORIGIN;
    } 
}
```

打开 https://shell.example.com 就可以访问到UI界面了。

这个工具提供的 Web 界面是强制使用 HTTPS 访问的，使用 HTTP 将无法打开网页，此外它还使用了谷歌二步验证（离线工具，不用翻墙）作为登录验证，因此你需要手机安装谷歌二步验证应用。

下载地址：https://support.google.com/accounts/answer/1066447?hl=en

国内地址：http://www.coolapk.com/apk/com.google.android.apps.authenticator2

虽然整体安装配置比较麻烦，但是Teleport安全而且界面优雅。如果你没有域名，也可以打开Web界面，输入 `https://<你的IP地址>:3080` 会看到下面图3-2的界面：

![图3-2 直接使用IP方式打开](images/图3-2 直接使用IP方式打开.png)

点击继续前往就可以看到登录界面如图3-3，如果你要建立私密连接，你必须购买一个域名和申请SSL证书。打开之后二步验证工具扫描二维码，输入验证码就可以登录了。

![图3-3 登录成功](images/图3-3 登录成功.png)

现在看到的是服务器列表，因为是一个集群管理工具，所以你可以添加很多服务器进来。点击其中一台服务器，会直接连接到那台服务器（在这个工具中所有的操作都会被记录下来，你可以回放你的操作），如图3-4所示：

![图3-4 连接服务器](images/图3-4 连接服务器.png)

Teleport的web terminal处理特殊符号效果不是很好，建议使用终端的tsh连接，网页这个只做为备选登录方式。退出就结束本次会话，结束录制，你可以在界面中查看之前的录制内容，如图3-5所示：

![图3-5 操作过程回放](images/图3-5 操作过程回放.png)

#### 2. 创建一个用户

这里的用户是指Teleport的用户。

```shell
> tctl users add $USER

Signup token has been created. Share this URL with the user:
https://shell.example.com/web/newuser/96c85ed60b47ad345525f03e1524ac95d78d94ffd2d0fb3c683ff9d6221747c2
```

在浏览器打开返回的链接，输入密码完成新用户注册。

#### 3. 添加节点

```shell
> tctl nodes add

The invite token: n92bb958ce97f761da978d08c35c54a5c
Run this on the new node to join the cluster:
teleport start --roles=node --token=n92bb958ce97f761da978d08c35c54a5c --auth-server=shell.example.com
```

在你的节点服务器执行：

```shell
teleport start --roles=node --token=n92bb958ce97f761da978d08c35c54a5c --auth-server=shell.example.com
```

查看节点（在管理节点执行）：

```shell
> tsh --proxy=shell.example.com ls

Node Name     Node ID                     Address            Labels
---------     -------                     -------            ------
localhost     xxxxx-xxxx-xxxx-xxxxxxx     10.0.10.1:3022     
new-node      xxxxx-xxxx-xxxx-xxxxxxx     10.0.10.2:3022     
```

修改节点信息（在节点服务器执行）：

```shell
teleport start --roles=node \
    --auth-server=shell.example.com \
    --nodename=db \
    --labels "location=virginia,arch=[1h:/bin/uname -m]"
```

#### 4. 登录

登录到某个服务器：

```shell
tsh --proxy=shell.example.com ssh new-node
```

分享操作会话：

```shell
> tsh --proxy=shell.example.com ssh db
db > teleport status

User ID    : joe, logged in as joe from 10.0.10.1 43026 3022
Session ID : 7645d523-60cb-436d-b732-99c5df14b7c4
Session URL: https://shell.example.com:3080/web/sessions/7645d523-60cb-436d-b732-99c5df14b7c4
```

别人加入当前会话（简单来说就是围观你的操作）：

```shell
> tsh --proxy=shell.example.com join 7645d523-60cb-436d-b732-99c5df14b7c4
```

#### 5. 本地分享

如果你的电脑处于一个需要认证网络的内网，申请SSL不太方便。自己电脑启动，指定服务器角色：

```shell
> teleport start --roles=node --proxy=shell.example.com
```

然后继续在自己电脑执行：

```shell
> tsh --proxy=shell.example.com ssh localhost
localhost> teleport status
```

和上面一样你会得到一个会话ID，把它分享给别人，然后你就可以在本地共享终端操作了。这个办法可以用于分享一堆服务器，并且记录用户的操作。管理起来很方便～

## 3.3 本章总结

自动化运维管理工具千千万万，本章不可能全部介绍完全，本章选取三个比较有代表性的集群自动化运维工具作为示例，展示不同实现机制的集群管理工具在自动化运维上的特点，为后面的容器集群章节提供多样的部署方式，以适应不同读者的需求。

除了本章介绍到的三个工具以外，像Puppet、Chef等等也是非常著名的自动化运维工具，还有一大批新兴的小有名气的工具更是在这个日新月异的容器云时代展现着各自的光芒。