# Service详解

## Service定义

我们已经多次提到，Service作为Kubernetes的一种抽象资源类型，它的最大作用就是代理后端的Pod，把后端多个Pod整合使外部访问时只感觉到一个服务而不是多个Pod，避免了使用Pod或者NodePort地址去访问服务（这两者IP往往不够稳定）。Service与Pod基于Label来关联。

下面是一份Service模板：

```yaml
apiVersion: v1  # API 版本
kind: Service  # 对象类型
matadata:  # 对象元数据
  name: string  # Service名称
  namespace: string  # Service所在命名空间（默认为default）
  labels:  # 标签
    - name: string  # 标签键值对
  annotations:  # 注释
    - name: string  # 注释键值对
spec:  # 定义规则
  selector: []  # 选择器，选择具有指定Label的Pod为管理对象
  type: string  # 指定Service的访问方式（NodePort、Clusterip、Loadbalancer）
  clusterIP: string  # 指定集群的虚拟IP（默认自动分配）
  sessionAffinity: string  # 是否支持Session，可选值为ClientIP（来自同一个IP地址的访问请求都转发到同一个后端Pod），默认为空。
  ports:
  - name: string
    protocol: string
    port: int
    targetPort: int
    nodePort: int
  status:
    loadBalancer:  # 外部负载均衡器配置
      ingress:
        ip: string
        hostname: string
```

## Service使用

定义一个RC，用来创建几个Pod，配置如下：

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: frontend-nginx
spec:
  replicas: 3
  selector:
    app: nginx
  template:
    metadata:
      labels:
        app: nginx:alpine
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
```

现在创建这个RC对象：

```shell
kubectl create -f frontend-nginx-rc.yaml
# 使用get查看
kubectl get pod --selector app=nginx
```

然后创建Service，配置如下：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-nginx
spec:
  selector:
    app: nginx
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
```

通过定义文件创建Service：

```shell
$ kubectl create -f frontend-nginx-service.yaml
# 直接使用expose也可以创建一个服务
$ kubectl expose rc frontend-nginx \
	--name=frontend-nginx-service \
	--port=80 --target-port=80
```

查看服务：

```shell
kubectl get service frontend-nginx-service
kubectl describe service frontend-nginx-service
```

## 集群外部访问

之前已经介绍过服务要让外部访问，有三种方式，一种是使用NodePort，另一种是负载均衡服务。前者已经在入门章节中介绍，这次来看如何使用负载均衡暴露一个服务给外部。

以Hello World程序为例：

```shell
$ kubectl run hello-world \
 	--replicas=5 --port=8080 \
 	--labels="run=load-balancer-example" \
 	--image=gcr.io/google-samples/node-hello:1.0
```

以上命令会创建一个Deployment资源对象和一个关联的ReplicaSet对象。ReplicaSet控制五个Pods，每个Pods都运行Hello World应用程序。

使用get和describe命令查看状态：

```shell
$ kubectl get deployments hello-world
NAME           DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
hello-world   5               5                 5                      5                   6s
$ kubectl describe deployments hello-world
```

查看RS资源状态：

```shell
$ kubectl get replicasets
$ kubectl describe replicasets
```

使用expose把deployment暴露：

```shell
$ kubectl expose deployment hello-world --type=LoadBalancer --name=my-service --port=80 --target-port=8080
```

然后查看所有Service：

```shell
$ kubectl get services my-service
 NAME          CLUSTER-IP     EXTERNAL-IP      PORT(S)    AGE
 my-service  10.3.245.137   119.28.85.233   8080/TCP   54s
 # 如果EXTERNAL-IP显示为<pending>，请等待一段时间再查看。
```

显示Service有关详细信息：

```
$ kubectl describe services my-service
Name:                   my-service
Namespace:              default
Labels:                 run=load-balancer-example
Annotations:            <none>
Selector:               run=load-balancer-example
Type:                   LoadBalancer
IP:                     10.110.134.31
LoadBalancer Ingress:   119.28.85.233
Port:                   <unset> 8080/TCP
NodePort:               <unset> 32737/TCP
Endpoints:      172.17.0.2:80,172.17.0.3:80,172.17.0.3:80 + 2 more...
Session Affinity:       None
Events:
```

使用外部IP地址访问Hello World应用程序：

```shell
$ curl http://119.28.85.233:8080
Hello Kubernetes!
```

关闭外部访问服务直接删除my-service即可：

```shell
$ kubectl delete services my-service
```

> 使用`kubectl delete deployment hello-world`删除本例子创建的资源。

## Ingress

通常情况下，service和pod的IP仅可在集群内部访问。集群外部的请求需要通过负载均衡转发到service在节点上暴露的NodePort上，然后再由kube-proxy将其转发给相关的Pod。而Ingress就是为进入集群的请求提供路由规则的集合。

Ingress可以给service提供集群外部访问的URL、负载均衡、SSL终止、HTTP路由等。为了配置这些Ingress规则，集群管理员需要部署一个Ingress controller，它监听Ingress和service的变化，并根据规则配置负载均衡并提供访问入口。

为什么需要Ingress，因为对外访问的时候，NodePort类型需要在外部搭建额外的负载均衡，而LoadBalancer要求kubernetes必须跑在特定的云服务提供商上面。

定义一个Ingress如下：

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  rules:
  - http:
      paths:
      - path: /testpath
        backend:
          serviceName: test
          servicePort: 80
```

每个Ingress都需要配置rules，目前Kubernetes仅支持http规则。上面的示例表示请求/testpath时转发到服务test的80端口。

根据Ingress Spec配置的不同，Ingress可以分为以下几种类型：

### 1. 单服务Ingress

单服务Ingress即该Ingress仅指定一个没有任何规则的后端服务。

```shell
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test-ingress
spec:
  backend:
    serviceName: testsvc
    servicePort: 80
```

单个服务还可以通过设置Service.Type=NodePort或者Service.Type=LoadBalancer来对外暴露。

### 2. 多服务Ingress

路由到多服务的Ingress即根据请求路径的不同转发到不同的后端服务上，比如可以通过下面的Ingress来定义：

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - path: /foo
        backend:
          serviceName: s1
          servicePort: 80
      - path: /bar
        backend:
          serviceName: s2
          servicePort: 80
```

上面例子中，如果访问的是 /foo ，则路由转发到s1服务，如果是 /bar 则转发到s2服务。

### 3. 虚拟主机Ingress

虚拟主机Ingress即根据名字的不同转发到不同的后端服务上，而他们共用同一个的IP地址，如下所示是一个基于Host header路由请求的Ingress：

```yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: test
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: s1
          servicePort: 80
  - host: bar.foo.com
    http:
      paths:
      - backend:
          serviceName: s2
          servicePort: 80
```

根据不同的域名路由到不同的后端服务。

### 4. 更新Ingress

可以通过`kubectl edit ing name`的方法来更新Ingress：

```shell
$ kubectl edit ing test
```

这会使用编辑器打开一个已有的Ingress的yaml定义文件，修改并保存就会将其更新到Kubernetes API server，进而触发Ingress Controller重新配置负载均衡：

```
spec:
  rules:
  - host: foo.bar.com
    http:
      paths:
      - backend:
          serviceName: s1
          servicePort: 80
        path: /foo
  - host: bar.baz.com
    http:
      paths:
      - backend:
          serviceName: s2
          servicePort: 80
        path: /foo
..
```

当然使用`kubectl replace -f new-ingress.yaml`来更新也是可以的。