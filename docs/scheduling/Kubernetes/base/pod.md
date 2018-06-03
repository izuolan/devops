# Pod详解

作为Kubernetes调度的最小单位，学习Pod的细节有助于理解Kubernetes整个系统的工作流程，本节将深入理解Pod的相关原理，学习Pod的主要操作。

## Pod配置详解

下面以一份完整的Pod配置文件来了解Pod的定义，使用`<>`表示该位置一般来说必须填写相应的内容，使用`[]`表示该位置的值可以为空或者不写该标签。

首先是Pod定义的元数据部分，apiVersion表示使用的api版本，在本章最后会有相关资料；kind表示了资源类型是Pod；metadata定义了这个Pod的元数据，包括名称、名字空间、标签以及注释，这些标签的用法在上一章都已经讲解过了。

```yaml
# 第一段
apiVersion: v1
kind: Pod
metadata:
  name: <string>
  namespace: [string]
  labels:
    - name: [string]
  annotations:
    - name: [string]
```

----

下面来看Pod的容器规则，依旧截断文件来看。imagePullPolicy表示镜像启动时是否拉取最新版本的镜像，有三个值可以选择，Always表示总是拉取最新版本镜像，Never表示不自动拉取最新镜像。默认是IfNotPresent，它表示本地不存在镜像就拉取镜像，但如果镜像定义中特别指定了`:latest`标签则与Always一样每次启动都拉取镜像。

command与args有点像Dockerfile中ENTRYPOINT和CMD指令，例如下面这个例子，command指定entrypoint，args指定了entrypoint的执行参数：

```yaml
command: ["/bin/sh"]
args: ["-c", "while true; do echo hello; sleep 10;done"]
```

workingDir就是工作目录和Dockerfile中的WORKDIR一样意思，volumeMounts表示数据卷的定义，此处数据卷定义与Docker中的定义无差异。但是别忘了数据卷定义在Kubernetes中是可以指定类型的，也就是说在containers标签之外，还有数据卷类型的定义，具体可以看下面第五段内容。

```yaml
# 第二段
spec:
  containers:
  - name: <string>
    image: <string>
    imagePullPolicy: [Always|Never|IfNotPresent]
    command: [string]
    args: [string]
    workingDir: [string]
    volumeMounts:
    - name: <string>
      mountPath: <string>
      readOnly: [true|false]
```

----

接下来看容器的端口、环境变量与硬件资源分配的定义。在这部分配置文件中，有大家熟悉的ports标签，与Docker不同的是，此处的端口是一个列表，也就是说ports下一级可以列几个端口定义，containerPort表示Pod里面的容器要监听的端口，hostPort表示容器所在主机需要监听的端口号（默认与containerport相同），除非必要，否则不要使用hostPort（例如作为节点Daemon程序时需要用到），设置hostport时，同一台宿主机只能启动一个容器实例。

env环境变量大家已经很熟悉，没有什么特别需要指出的地方，resources资源限制与Docker run类似，limits表示最大使用值，requests表示请求使用值。

```yaml
# 第三段
    ports:
    - name: <string>
      containerPort: <int>
      hostPort: [int]
      protocol: [string]
    env:
    - name: <string>
      value: <string>
    resources:
      limits:
        cpu: [string]
        memory: [string]
      requests:
        cpu: [string]
        memory: [string]
```

----

下面配置文件中的标签想必有些陌生，livenessProbe定义了对Pod内部容器健康检查的设置，当监测异常之后，系统将自动重启该容器。可以设置的方法有exec、httpGet和tcpSocket。一般而言一个容器仅需设置一种健康检查方法。

* initialDelaySeconds表示容器启动成功后到第一次监测的时间间隔（单位是秒）；
* timeoutSeconds表示超时秒数，超过就表示容器不正常（默认1秒）；
* periodSeconds表示多少秒监测一次（默认10秒）；
* successThreshold表示探针监测失败之后要连续监测多少次成功才算正常（默认为1次，最小1次）；
* failureThreshold表示连续多少次监测失败才判定容器异常（默认为3次，最小为1次）。

详细设置方法在稍后小节中会详细讲解。

```yaml
# 第四段
    livenessProbe:
      exec:
        command: [string]
      httpGet:
        path: [string]
        port: [number]
        host: [string]
        scheme: [string]
        httpHeaders:
        - name: [string]
          value: [string]
      tcpSocket:
        port: [number]
      initialDelaySeconds: <int>
      timeoutSeconds: [int]
      periodSeconds: [int]
      successThreshold: [int]
      failureThreshold: [int]
      securityContext:
        privileged: [true|false]
```

----

最后，是关于重启策略与网络、数据持久化的配置定义。

restartPolicy表示Pod的重启策略，默认值为Always。
* Always：Pod一旦终止运行，则无论容器是如何终止都将自动重启容器。
* Onfailure：当Pod以非零退出码终止时自动重启容器。退出码为 0 则不重启（正常退出）。
* Never：Pod终止后不重启容器。

nodeSelector表示将该Pod调度到包含这些label的Node上，以键值对格式指定，在后面调度实战中会使用到。

拉取镜像时使用的secret名称，以 `name:secretkey` 格式指定。例如给节点打一个标签：

```shell
kubectl label nodes ops-node1 disktype=ssd
```

然后配置中就可以这样写：

```yaml
  nodeSelector:
    disktype: ssd
```

调度时会把这个Pod调度到有这个标签的节点上。

hostNetwork表示是否使用主机网络模式，默认为false。如果设置为true，则表示容器使用宿主机网络，不再使用Docker网桥，这样的话这个Pod只能在宿主机上启动一个实例。

```yaml
# 第五段
    restartPolicy: [Always|Never|OnFailure]
    nodeSelector: <object>
    imagePullSecrets:
    - name: [string]
    hostNetwork: [true|false]
    volumes:
    - name: <string>
      emptyDir: {}
      hostPath:
        path: string
      secret:
        secretName: string
        items:
        - key: string
        path: string
      configMap:
        name: string
        items:
        - key: string
          path: string
```

最后到了volumes定义，这个前面有过简单介绍，在本章后面会单独有一个小节讲解Kubernetes数据持久化的方法。

## Pod生命周期

### 1. 创建Pod

在前面的章节中，我们已经多次创建Pod了，使用`kubectl create`即可创建，大部分资源对象都是通过这个命令创建的。如果创建失败，它会提示你哪里出错。

快速使用run命令创建：

```shell
kubectl run my-nginx --image=nginx --replicas=2 --port=80
```

手动暴露一个服务：

```shell
kubectl expose deployment my-nginx --port=8080 --target-port=80 --external-ip=x.x.x.x
# external-ip必须是安装了Kubernetes的机器的IP，随便一个集群外部的IP是不能访问的。
```

多容器Pod的创建一般使用`kubectl create -f FILE`命令来创建，完整的Pod创建请看之前的细谈Kubernetes命令行部分。

### 2. 查看Pod

查看Pod几乎是kubectl中最常用的命令了，使用`kubectl get pods`，相关参数在上一章已经全部介绍了。使用`kubectl describe pods <pod-name>`可以查看指定Pod的生命周期事件，使用相关参数可以过滤出你要的信息，这些都在上一章介绍过了。

查看Pod的更多信息：

```shell
$ kubectl get pod NAME -o wide
$ kubectl describe pod NAME
Name:        example-1934187764-scau1
Namespace:   default
Image(s):    kubernetes/example-php-redis:v2
Node:        gke-example-c6a38461-node-xij3/10.240.34.183
Labels:      name=frontend
Status:      Running
Reason:
Message:
IP:          10.188.2.10
Replication Controllers:  example (5/5 replicas created)
Containers:
  php-redis:
    Image:   kubernetes/example-php-redis:v2
    Limits:
      cpu:   100m
    State:   Running
      Started:   Tue, 04 Aug 2015 09:02:46 -0700
    Ready:   True
    Restart Count: 0
Conditions:
  Type    Status
  Ready   True
  ... ...
```

### 3. 删除Pod

使用`kubectl delete pod <pod-name>`可以删除指定Pod，或者使用-f选项指定配置文件删除该Pod，如果要删除所有Pods，可以使用--all选项。

以下两种方式都可以删除指定的Pod：

```shell
kubectl delete pod POD_NAME
kubectl delete pod/POD_NAME
```

如果你删除Deployment或者RC、RS等资源，也会删除它们关联的Pod。

### 4. 升级Pod

使用`kubectl replace -f /path/nginx.yml`可以更新一个Pod。但Pod的很多属性是无法修改的，所以更新Pod时修改配置文件后往往没有改变Pod的属性，可以使用`--force`强制更新，这种操作等同于重建一个Pod。

这种替换Pod的方式并不适用于大规模集群，为了实现一个服务的滚动升级，往往有大量Pods需要升级，而且还要保证服务不间断，因此滚动升级可以通过执行`kubectl rolling-update`命令完成，该命令会创建一个新的RC，然后自动控制旧的RC定义中的Pod副本的数量逐渐减少到0，同时新的RC中的Pod副本的数量从0逐步增加到期望值，最终实现整个服务所有Pod的升级。不过，新RC与旧RC需要在相同的命名空间（Namespace）内才能执行这个命令。

例如，现有Pod正在运行java-web容器，Pod的版本是1.0，现在需要升级到2.0版本。

创建java-web-v2.yaml

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
 name: java-web-v2
 labels:
  name: java-web
  version: v2
spec:
  replicas: 2
  selector:
    name: java-web
    version: v2
  template:
    metadata:
      labels:
        name: java-web
        version: v2
    spec:
    containers:
    - name: master
      images: user/java-web:2.0
      ports:
      - containerPort: 2333
```

保存文件，然后更新：

```shell
kubectl rolling-update java-web -f java-web-v2.yaml
```

注意，RC的名称（name）不能与旧的RC名称相同。因为在selector中至少要有一个Label与旧的Label不同，才能标识其为新的RC。

另外，使用不同的镜像标签表示Pod镜像有变化，也可以实现Pod升级（RC不变）。第一种方法需要改变RC定义文件，可控性强。第二种方法可以使用rolling-update的选项`--image`指定，使用`--rollback`可以回滚。

## 共享Volume

在Pod中定义容器的时候可以为单个容器配置volume，然后也可以为一个Pod中的多个容器定义一个共享的Pod级别的volume。比如一个Pod里定义了一个Nginx容器，访问日志放在了一个文件夹。此外还定义了一个收集日志的容器，那这个时候你就可以把存放日志的文件配置为Pod级别共享的volume，这样一个容器写，一个容器读相互共享一个volume。

```yaml
spec:
  containers:
  - name: frontend-nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: nginx-logs
      mountPath: /usr/local/nginx/logs
  - name: analyze-log
    image: analyze-image
    volumeMounts:
    - name: nginx-logs
      mountPath: /logs
  volumes:
  - name: nginx-logs
    emptyDir: {}
```

这里设置的Volume名为nginx-logs，类型为emptyDir，挂载到nginx容器内的/usr/local/nginx/logs目录和analyze-log容器的/log目录。

## Pod配置管理

在前面的内容中，介绍过一种同一的集群配置管理方案ConfigMap，以文件cm-vars.yaml为例，将几个应用所需的变量定义为ConfigMap：

```yaml
kind: ConfigMap
apiVersion: v1
metadata:
  creationTimestamp: 2017-07-18T19:14:38Z
  name: example-config
  namespace: default
data:
  example.property.1: hello
  example.property.2: world
  example.property.file: |-
    property.1=value-1
    property.2=value-2
    property.3=value-3
```

`data`一栏包括了配置数据，ConfigMap可以被用来保存单个属性，也可以用来保存一个配置文件。 配置数据可以通过很多种方式在Pods里被使用。ConfigMaps可以被用来：

1. 设置环境变量的值

2. 在容器里设置命令行参数

3. 在数据卷里面创建config文件

使用`kubectl create`创建：

```shell
kubectl create -f cm-vars.yaml
# 此处的文件并不一定是要yaml格式，可以是任意键值对格式的文档。例如下面，可以是一个目录、键值对文件：
$ ls my-cm/hello/
test.properties
ui.properties

$ cat my-cm/hello/test.properties
enemies=aliens
lives=3
enemies.cheat=true
enemies.cheat.level=noGoodRotten
secret.code.passphrase=UUDDLRLRBABAS
secret.code.allowed=true
secret.code.lives=30

$ cat my-cm/hello/ui.properties
color.good=purple
color.bad=yellow
allow.textmode=true
how.nice.to.look=fairlyNice
# 上一章有关于cm的详细介绍。
```

如何使用这些cm？建立一个Pod定义文档如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: gcr.io/google_containers/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.how
        - name: SPECIAL_TYPE_KEY
          valueFrom:
            configMapKeyRef:
              name: special-config
              key: special.type
      envFrom:
        - configMapRef:
            name: env-config
  restartPolicy: Never
```

其中在env标签中，使用了名为env-config和special-config的cm资源，这两个文件如下：

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: special-config
  namespace: default
data:
  special.how: very
  special.type: charm
----
apiVersion: v1
kind: ConfigMap
metadata:
  name: env-config
  namespace: default
data:
  log_level: INFO
```

如果执行这个Pod，会输出如下几行：

```shell
SPECIAL_LEVEL_KEY=very
SPECIAL_TYPE_KEY=charm
log_level=INFO
```

在cm中的键值对对于Pod内部的容器来说是作为全局的变量存在的。除了使用上面的env方式加载cm，还可以使用volume挂载cm资源。

## 健康检查

### 1. 健康检查

Kubernetes健康检查被分成Liveness和Readiness两种Probes。LivenessProbe用于检测容器是否正在运行，又称存活探针。通常情况下，容器一旦崩溃，Kubernetes就会知道这个容器已经终止，然后自动重启这个容器。LivenessProbe的目的就是监测容器的运行状态并返回给API server，所以一个简单的HTTP请求就可以成为一个LivenessProbe。

LivenessProbe探针通过三种方式来检查容器是否健康：

* ExecAction：在容器内部执行一个命令，如果返回码为0，则表示健康。
* TcpAction：通过IP和Port发送请求，如果能够和容器建立连接则表示容器健康。
* HttpGetAction：发送一个http Get请求（ip+port+请求路径）如果返回状态码在200-400之间则表示健康。

下面是三个方法的示例：

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: liveness-test
spec:
  containers:
  - name: liveness-test
    image: busybox
    args: 
    - /bin/sh
    - -c
    - echo ok > /tmp/healthy: sleep 10; rm -rf /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
    initialDelaySeconds: 15 # 启动15秒后执行探针
    periodSeconds: 5 # 探针每5秒检查一次
    timeoutSeconds: 1 # 1秒内不返回信息则标记为不正常
```

在这个例子中，设置了一个容器，使用`echo ok > /tmp/healthy: sleep 10; rm -rf /tmp/healthy; sleep 600`模拟一个容器“不健康”的状态，下面的exec类型的探针中定义了使用cat命令检查/tmp/healthy文件的内容，当10秒之后，容器内部的/tmp/healthy文件被删除，探针无法获取这个文件，于是这个容器就会被标记为“不健康”状态。

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-with-healthcheck
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      tcpSocket:
        port: 80
    initialDelaySeconds: 15
    timeoutSeconds: 1
```

在这个例子中，使用了TcpAction类型的探针，探针在容器启动15秒后执行tcp连接测试，如果一秒内没有成功建立连接，那么探针就会标记容器为“不健康”，并向API server汇报，等待Kubernetes重新调度新的容器或者根据重启策略恢复容器状态。

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-with-healthcheck
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /_status/healthy  //请求路径
        port: 80
    initialDelaySeconds: 15
    timeoutSeconds: 1
```

在这个例子中，使用了HttpGetAction类型的探针，探针在容器启动15秒后执行http get操作，如果一秒内没有返回200到400之间的状态码，表示容器不正常，然后汇报API Server。

### 2. 重启策略

Pod的重启策略是指当容器异常退出后调度器如何处理容器的策略，重启策略在上面配置详解中有介绍。Pod一共有四种状态，如下表12-1：

| 状态值     | 描述                                       |
| ------- | ---------------------------------------- |
| Pending | APIserver已经创建该Service，但Pod内有容器还未完成创建，例如镜像可能在下载中，或者容器正在创建。 |
| Running | Pod内所有的容器已创建，并且至少有一个容器处于运行状态。            |
| Failed  | Pod内所有容器都处于exit状态，或者其中有容器运行失败并且无法恢复。     |
| Unknown | 由于某种原因无法获取Pod的状态，比如网络不通。                 |

表12-1 Pod四种状态

Pod的重启策略应用于Pod内的所有容器，由Pod所在Node节点上的Kubelet进行判断和重启操作。重启策略有以下三种，见表12-2：

| 重启策略      | 描述                                 |
| --------- | ---------------------------------- |
| Always    | 容器总是自动重启，不管因为什么原因退出。               |
| OnFailure | 容器终止运行，且退出码不为0时重启。退出嘛为0表示容器是正常退出的。 |
| Never     | 容器退出后不重启。                          |

表12-2 三种重启策略

创建一个Pod如下：

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: on-failure-restart-pod
spec:
  containers:
  - name: container
    image: "ubuntu:14.04"
    command: ["bash","-c","exit 1"]
  restartPolicy: OnFailure
```

查看Pod的重启次数：

```shell
kubectl get pod on-failure-restart-pod \
	--template="{{range .status.containerStatuses}}{{.name}}:{{.restartCount}}{{end}}"
```

## Pod扩容和缩容

Pod的规模伸缩在入门章节中已有介绍，例如HPA资源；在细谈命令行中，也介绍了相关的命令，例如scale等。

例如通过scale来完成扩容或缩容，假设nginx这个Pod原来定义了5个副本，想扩容到10个，执行命令：

```shell
kubectl scale rc nginx --replicas=10
# 缩容到2个，执行命令：
kubectl scale rc nginx --replicas=2
```

还可以使用动态扩容缩容（HPA），通过对CPU使用率的监控，HPA（Horizontal Pod Autoscaler）可以动态地扩容或缩容。

Pod的CPU使用率是通过Heapster组件来获取的，所以要预先安装好（见本章稍后）。

下面创建一个HPA，在创建HPA前需要已经存在一个RC或Deployment对象，并且该RC或Deployment中的Pod必须定义 `resource.request.cpu` 的请求值，否则Kubernetes不会主动获取CPU使用情况，导致HPA无法工作。

假设现在有一个java的RC，现在通过`kubectl autoscale`命令创建：

```shell
kubectl autoscale rc java --min=1 --max=10 --cpu-percent=50
```

上面命令表示当CPU使用率超过50%就启动自动伸缩规模，副本数量范围在1-10之间调整。除了使用autoscale命令创建HPA之外，还可以通过配置文件的方式创建HPA：

```
apiVersion: autoscaling/v1
kind: HorizaontalPodAutoscaler
metadata:
 name: java-web
spec:
 scaleTargetRef:
   apiVersion: v1
   kind: ReplicationController
   name: java-web
 minReplicas: 1
 maxrReplicas: 10
 targetCPUUtilizationPercentage: 50
```

含义与上面命令相同。
