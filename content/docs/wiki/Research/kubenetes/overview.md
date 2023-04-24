[https://www.cnblogs.com/qsing/p/15263713.html](https://www.cnblogs.com/qsing/p/15263713.html)

[https://www.cnblogs.com/qsing/p/15272351.html](https://www.cnblogs.com/qsing/p/15272351.html)

基本概念和组件

NameSpace：命名空间是对一组资源和对象的抽象集合， 是 Linux 内核用来隔离内核资源的方式。NameSpace做隔离，Cgroups 做限制，rootfs 做文件系统。

Label：标签以 key/value 的方式附加到资源对象上如Pod， 其他对象可以使用 Label Selector 来选择一组相同 label 的对象。

Pod：Kubernetes 项目中最小的 API 资源对象，Pod可以由一个或多个业务容器和一个根容器(Pause容器)组成。一个Pod表示某个应用的一个实例。

ReplicaSet：Pod副本的抽象，用于解决Pod的扩容和伸缩。

Deployment：通常用来部署无状态应用，如Web服务， 该服务的实例不会在本地存储需要持久化的数据，并且多个实例对于同一个请求响应的结果是完全一致的。在内部使用ReplicaSet来实现Pod副本的创建。Deployment确保指定数量的Pod“副本”在运行，并且支持回滚和滚动升级。

StatefulSet：通常用来部署有状态应用，如Mysql服务，服务运行的实例需要在本地存储持久化数据，多个实例之间有依赖拓扑关系，比如：主从关系、主备关系。如果停止掉依赖中的一个Pod，就会导致数据丢失或者集群崩溃。他的核心功能就是通过某种方式记录这些状态，然后在 Pod 被重新创建时，能够为新 Pod 恢复这些状态。它包含Deployment控制器ReplicaSet的所有功能，增加可以处理Pod的启动顺序，为保留每个Pod的状态设置唯一标识。

DaemonSet：服务守护进程，它的主要作用是在Kubernetes集群的所有节点中运行我们部署的守护进程，相当于在集群节点上分别部署Pod副本，如果有新节点加入集群，Daemonset会自动的在该节点上运行我们需要部署的Pod副本，相反如果有节点退出集群，Daemonset也会移除掉部署在旧节点的Pod副本。特点：这个 Pod 运行在 Kubernetes 集群里的每一个节点（Node）上；每个节点上只会运行一个这样的 Pod 实例；如果新的节点加入 Kubernetes 集群后，该 Pod 会自动地在新节点上被创建出来；而当旧节点被删除后，它上面的 Pod 也相应地会被回收掉。监控系统的数据收集组件，如Prometheus Node Exporter。

HPA：Horizontal Pod Autoscaling（Pod水平自动伸缩），简称HPA。通过监控分析RC或者Deployment控制的所有Pod的负载变化情况来确定是否需要调整Pod的副本数量。

Service：是一种抽象的对象，它定义了一组Pod的逻辑集合和一个用于访问它们的策略，我们可以通过访问Service来访问到后端的Pod服务，其实这个概念和微服务非常类似。一个Serivce下面包含的Pod集合一般是由Label Selector来决定的。

CRD：对 Kubernetes API 的扩展，Kubernetes 中的每个资源都是一个 API 对象的集合，例如我们在YAML文件里定义的那些spec都是对 Kubernetes 中的资源对象的定义，所有的自定义资源可以跟 Kubernetes 中内建的资源一样使用 kubectl 操作。

Operator：由CoreOS公司开发的，用来扩展 Kubernetes API，特定的应用程序控制器，它用来创建、配置和管理复杂的有状态应用，如数据库、缓存和监控系统。Operator基于 Kubernetes 的资源和控制器概念之上构建，但同时又包含了应用程序特定的一些专业知识，比如创建一个数据库的Operator，则必须对创建的数据库的各种运维方式非常了解，创建Operator的关键是CRD（自定义资源）的设计。Operator是将运维人员对软件操作的知识给代码化，同时利用 Kubernetes 强大的抽象来管理大规模的软件应用。

Master节点：

apiserver：作为k8s的入口，与其他组件通信时都需要提供或验证证书。

主要提供两方面功能：1. 网关功能(认证、鉴权、消息转发)；2. 是提供k8s的资源注册与发现：创建 CRD 就是我们自定义资源的注册；Controller/Operator 就是我们知道了资源事件从而作出响应的处理。

etcd：

scheduler：

controller-manager：Replicaset Controller、Node Controller、Namespace Controller 和 ServiceAccount Controller

Node节点：
---
weight: 100
title: "overview"
---

kubelet：

kube-proxy：是每个节点上运行着的网络代理。

ContainerRuntime（容器运行时）：容器运行时接口（CRI）是 kubelet 和容器运行时之间通信的主要协议(grpc)。目前主要的运行时比如: Docker(1.20已经弃用)、 containerd、CRI-O 等

工作流程

通过deployment部署pod的常规流程：

2013 openstack -> 2018 kubernetes

Kubernetes

k8s-pod:一组容器(app+agent)，一个服务=n个容器=一个set=一个deployment

k8s: scheduler、controller-manager、api-server、etcd

Scheduler：

预选：过滤合适的机器，PodFitsHostPorts、PodFitsHost、PodFitsResources、PodMatchNodeSelector、NoDiskConflict、GeneralPred、CheckNodeCondition、MatchNodeSelector

优选：对所有合适的机器打分选取最优，SelectorSpreadPriority、LeastRequestedPriority、NodeAffinityPriority、EqualPriorityMap、TaintTolerationPriority、ImageLocalityPriority、MostRequestedPriority、ResourceLimitsPriority

controller-manager：

声明式API管理，通过循环不断检查对象的当前状态和预期状态是否一致，若不一致尝试把当前状态达到我们预期所声明的状态->k8s自愈

命令式：向系统发送一条条的指令，系统负责执行

挑战：

1. ⼤规模集群的可⽤性和性能问题

2. 风险控制和安全需求⾮常强烈

3. 如何满⾜不同场景、不同业务类型的多样化需求?

4. 如何减少误操作和故障的出现?

5. ⼈力、时间有限的情况下，如何提升运营和运维效率?

APIServer流量击穿问题：

问题:apiserver重启时，所有client需要重新list&watch导致请求量过⾼，超过⾃身的流控:返回响应码429，同时设置响应头Retry-After，告诉client 1s 后再试，造成apiserver⻓时间过载不可用，甚⾄将数据库(ETCD)打挂

A：多级流控:限制kubelet以及监控等组件，优先处理核⼼组件(Controller、Scheduler、调⽤方等) 的请求; 多级拥塞控制:静态Retry-After改为 动态(令牌桶)：令牌数剩余50%以上:1s；令牌数剩余25%以上:2s；令牌数剩余12.5%以上:4s；低于12.5%:8s

ETCD：

raft算法-分布式，1000次/秒写，restful接口，

Nodemanager:容器生命周期管理

配额、IP、DNS、扩缩容链路、SetName管理、故障隔离平台、策略配置中心、重调度

定制调度

需求：机房内核版本有要求、强制打散、自定义环境变量

分析：抽象出四类需求：

容器配置要求，如cpu核数、内存大小、环境变量、启动脚本等

调度策略要求，如机房、

容器间要求，如和某服务不能放在同宿主机上，需要和某容器放在同宿主机

冗灾和打散，宿主机级别，机房级别，地域级别

挑战：公司内部严重依赖windows、安卓等vm，如何支撑？容器vm统一调度

kata容器：轻量级虚拟机，

云原生：

surgeon：

- 集群内横向分析
    - 集群异常点检测：找出与集群内其它机器偏差较大的机器

- 单机纵向分析
    - 基线检测：指标值是否超出服务历史基线
    - 阈值检测：指标值是否超出一定阈值（目前仅针对系统指标有此项检测）
    - 序列平稳性检测：指标序列是否平稳，存在突增/突降情况
    - 趋势检测：指标值是否发生变化，适用于递增型指标
