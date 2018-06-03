# 索引

## 1. 运维

### 1.1 持续交付

- **[Jenkins](https://jenkins.io)：最常见的持续集成工具。**
- [Gitlab CI](https://about.gitlab.com)：GitLab中集成的持续集成模块。
- [Spinnaker](https://github.com/spinnaker/spinnaker)：Netflix开源的持续集成系统。
- 其他：Buildbot、GoCD、Drone
- 软件服务：Travis CI、CircleCI、Bamboo、Shippable、TeamCity、AWS CloudFormation

### 1.2 自动化

- **[Ansible](https://github.com/ansible/ansible)：基于ssh实现的自动化运维工具。**
- [Puppet](https://github.com/puppetlabs/puppet)：一个服务器自动化框架。
- [Chef](https://github.com/chef/chef)：自动化管理基础架构的工具。
- AWS OpsWorks

### 1.3 编排和调度

- **[Compose](https://github.com/docker/compose)：Docker官方钦定的容器编排工具。**
- **[Kubernetes](https://github.com/kubernetes/kubernetes)：企业级容器编排和管理平台。**
- [Marathon](https://github.com/mesosphere/marathon)：在Apache Mesos上部署和管理容器（包括Docker）。
- [Nomad](https://github.com/hashicorp/nomad)：高度可用的分布式数据中心和应用调度程序。

### 1.4 服务注册和发现

- **[Etcd](https://github.com/coreos/etcd)：高可用分布式键值存储工具。**
- **[Consul](https://github.com/hashicorp/consul)：Consul让服务发现和配置变得简单。**
- [Traefik](https://github.com/containous/traefik)：一个先进的反代理程序。
- [Registrator](https://github.com/gliderlabs/registrator)：针对Docker的服务注册适配器。
- [SkyDNS](https://github.com/skynetservices/skydns)：基于Etcd实现的DNS服务发现。

### 1.5 可视化（容器方向）

- [Portainer](https://github.com/portainer/portainer)：一个功能丰富的Docker可视化管理工具。
- [Swarm Visualizer](https://github.com/dockersamples/docker-swarm-visualizer)：常用的演示用可视化工具。
- [Rapid](https://github.com/ozlerhakan/rapid)：轻量级Docker Remote API开发界面。
- [DockStation](https://github.com/DockStation/dockstation)：即将开源的可视化Docker界面管理工具。
- 其他（不活跃开发状态）：Shipyard、Seagull、Kitematic、Dockeron

### 1.6 基础设施集成

- **[Mesos](https://github.com/apache/mesos)：云计算领域霸主之一，无需多言。**
- **[OpenStack](https://www.openstack.org)：云计算领域的霸主之一，一言难尽。**
- [Machine](https://github.com/docker/machine)：以Docker为中心的物理主机管理工具。
- [Vagrant](https://github.com/hashicorp/vagrant)：基于虚拟机实现的构建和分发开发环境的工具。

### 1.7 部署

- 概念：蓝绿部署、灰度发布、金丝雀发布、Canary部署、Phoenix部署。
- 自动部署：PXE、Cobbler、Kickstat。

## 2. 开发

### 2.1 开发流程

Scrum、Crystal、FDD

### 2.2 **Shell**

- 基本语法
- sed
- awk
- 正则表达式

### 2.3 Python

### 2.4 **Go**

- 基本语法
- 文件处理
- 并发编程
- 网络编程

### 2.5 版本控制

- **Git：常见工作流操作。**
- 其他：Subversion、Mercurial、Bazaar、SourceTree

### 2.6 数据结构与算法

- 数据结构
- 设计模式

## 3. 架构

### 3.1 架构基础

- 负载均衡
  - **HAProxy：最流行的负载均衡工具之一。**
  - **Nginx：两大Web服务器之一。**
  - **Apache：两大Web服务器之一。**
  - AWS ELB
- 虚拟化
  - Hypervisor
    - Xen
    - **KVM：最常见的基础设施虚拟化方案之一。**
    - Hyper-V
  - 容器
    - **Moby/Docker：最流行的容器引擎/平台。**
    - **RunC：最流行的容器引擎核心。**
    - Rkt
    - LXC
    - 其他：Systemd-nspawn、Hyper/RunV、Garden、Vagga
- **容器原理**
  - 命名空间
  - Cgroups
  - 镜像
  - 容器启动原理
- **微服务**
- **RESTfull**
  - **[Swagger](https://swagger.io)**：面向OpenAPI规范的API开发工具。

### 3.2 网络

- **OSI七层模型：最基础的知识。**
- **TCP/IP：最常见的协议簇之一，必备基础知识。**
- **DNS/CDN：最基本的概念。**
- **VLANs：容器集群网络的基本原理。**
- **HTTP/HTTPS协议：基础知识，无需多言。**
- **CAP理论**
  - [Raft一致性算法](http://thesecretlivesofdata.com/raft/)
- 容器网络
  - **[Libnetwork](https://github.com/docker/libnetwork)：Docker的网络实现抽象库。**
  - **[Flannel](https://github.com/coreos/flannel)：Kubernetes网络实现。**
  - **[CNI (Container Network Interface)](https://github.com/containernetworking/cni)：用于Linux容器的网络接口。**
  - [Weave](https://github.com/weaveworks/weave)：一个流行的容器网络实现。
  - [OVS (Open vSwitch)](https://github.com/openvswitch/ovs)：和OpenStack相关的SDN工具。
  - [Calico](https://github.com/projectcalico/calico)、[Romana](https://github.com/romana/romana)、[Canal](https://github.com/projectcalico/canal)、[Pipeworks](https://github.com/jpetazzo/pipework)

### 3.3 存储

- 网络存储
  - **NFS v4**
  - GlusterFS
  - Ceph
  - AWS EBS
- 对象存储
  - **AWS S3**
  - OpenStack Swift
  - AliCloud OSS
- 块存储
  - **RAID 概念**
  - **SAN**
  - AWS EBS
- 备份恢复
  - **数据备份**
- 文件系统
  - **ext4**
  - XFS

### 3.4 消息

- 消息队列
  - **ZeroMQ**
  - **ActiveMQ**
  - **RabbitMQ**
  - AWS SQS
- 事件/消息驱动
  - AWS SWS
  - **AWS Lambda**
  - AKKA
- RPC
  - **gRPC**
  - Thrift
  - Protobuf

### 3.5 数据管理

- SQL
  - AWS RDS
  - **MySQL**
  - PostgreSQL
- NoSQL
  - DynamoDB
  - **MongoDB**
  - Cassandra
- 缓存
  - **Memcached**
  - **Redis**
  - AWS ElastiCache
- 检索
  - Solr
  - **Elasticsearch**
  - AWS Elasticsearch
- MapReduce
  - Hadoop
  - HDFS
  - HBase
  - Hive
  - Spark   
- 数据流
  - AWS Kinesis
  - Storm

### 3.6 数据持久化

- **[Flocker](https://clusterhq.com)：大概是Docker生态中最完善的数据卷管理工具。**
- Convoy
- REX-Ray
- Blockbridge
- Netshare
- NetApp
- OpenStorage

## 4. 平台

### 4.1 操作系统

- Linux
  - **Systemd**
  - **常用工具**
    - ip top sar dig iostat netstat
    - perf strace trace dstat
  - **Alpine**
- Container Linux
- Project Atomic
- RancherOS
- ClearLinux
- CargoOS

### 4.2 Kubernetes

#### 安装与运维

- 安装
  - Kubeadm
  - Minikube：本地部署工具
  - Kops：云端部署工具
- 资源回收（GC）
  - Container GC
  - Image GC
- Kubernetes升级 
- etcd
  - etcd集群高可用
  - 键值对操作
  - Metrics监控
  - 备份恢复

#### Worker/Kubelet

- 运行时
  - CRI (Container Runtime Interface)
  - 运行时插件（shims）
    - **containerd**
    - **Dockershim （Docker）**
    - **Cri-o （runC）**
    - Rktlet （rkt）
    - Frakti （runV）
- 网络
  - CNI (Container Network Interface)
  - 网络插件
    - **Flannel**
    - Calico
    - OVS
    - Weave
    - SR-IOV
    - macvlan/ipvlan
    - Opencontrail
- 存储
  - CSI (Container Storage Interface)
  - 数据卷插件
    - **NFS**
    - Cinder
    - GlusterFS
    - Ceph
    - Local path
- Kube-proxy
  - **Iptables转发链与随机模式**
  - **ipvs负载均衡**

#### Master

- API Server
  - Watch和通知框架（Watch & Informer） 
  - 权限控制插件
  - 基于角色的访问控制插件（RBAC）
- Controller Manager
  - 控制循环与状态协调机制（Reconcile）
- Scheduler
  - 自定义调度器
  - 自定义调度算法（algrhrim）
- Etcd
  - Etcd操作（operator）

#### 作业管理

- ReplicaSet （容器副本）
- Deployment （常规作业发布）
  - Rolling update （自动的滚动更新）
  - Pause/resume （可控的更新流程）
  - Canary deploy （金丝雀发布）
  - Rollback （版本回滚）
- DaemonSet （Daemon 作业）
- StatefulSet （有状态任务）
- Job （一次性任务）
- CronJob （定时任务）

#### 应用配置

- Service （服务发现）
  - Publish service（对外暴露 Service）
  - Nginx/HAproxy service（自定义 Service）
  - External Load Balancer
- ConfigMap （应用配置管理）
- Ingress （7层服务发现）
- Secret （加密信息管理）
- Headless Service（DNS 服务发现）
- External Load Balancer

#### 扩展和插件

- Custom Resources Definition （自定义 Kubernetes API 对象）
  - Customized controller （自定义 API 对象控制器）
  - Workqueue （自定义 API 对象任务队列）
- Kube-dns
  - SkyDNS
- Fluentd （日志收集）
  - Fluent-bit 
- Heapster (容器集群监控）
- Istio（微服务路由和负载均衡）
- Federation （集群联邦）
- Helm (kubernetes application package)

### 4.3 日志与监控

- 运维平台
  - **Zabbix**
  - **Nagios**
  - **Cacti**
  - Ganglia
- **ELK/EFK**
  - ElasticSearch
  - LogStash
  - Kabana
  - Fluentd
- 可视化
  - **InfluxDB**
  - **Grafana**
- 容器监控
  - **cAdvisor**
  - **Open-Falcon**
  - [Prometheus](https://github.com/prometheus/prometheus)：警告系统。
  - [Sysdig](https://github.com/draios/sysdig)：Linux系统监测和故障排除工具（支持容器）。
  - Docker-Alertd
  - Splunk
  - Meros
- SaaS：AWS CloudTrail、AWS CloudWatch、NewRelic、OneAPM
- 其他：TICK Stack、Flume、Scribe、Chukwa、PagerDuty、Observium、Inicga

### 4.4 容器仓库

- Registry
- Harbor
- Portus
- Sonatype Nexus

### 4.5 容器PaaS

- **Rancher**
- Mesosphere DC/OS
- Dokku
- Flynn
- Tsuru
- Deis Workflow
- Nanobox
- Openshift

## 5. 安全

### 5.1 服务器安全

- **Firewall**
- **DDoS**
- **iptables**
- WAF
- IDS/IPS
- VPN

### 5.2 容器安全

- **Clair**
- **AppArmor**
- **SELinux**
- Notary
- Twistlock
- OpenSCAP

### 5.3 身份认证

- **LADP**
- SAML
- OpenID
- Microsoft AD
- AWS IAM

### 5.4 密钥管理

- **Git Secrets**
- Threat Modeling
- OWASP ZAP
- OpenTPX
- Passive Total
- Critical Stack
- Vault
- BlackBox
- Transcrypt
- Keybase
