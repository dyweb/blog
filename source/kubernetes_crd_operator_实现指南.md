title: "Kubernetes CRD Operator 实现指南"
date: 2018-06-25 08:04:31 +0000
update: 2018-06-25 08:04:31 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "Kubernetes"
preview: "8012 年了，Kubernetes 已经成为了集群调度领域最炙手可热的开源项目之一。而多工作负载支持，是讨论到集群调度时不得不谈的一个话题。CRD 是 Kubernetes 的一个特性，通过它，集群可以支持自定义的资源类型，这是在 Kubernetes 集群上支持多工作负载的方式之一。本文希望讨论在实现一个 Kubernetes CRD Operator 时可能遇到的问题以及解决方案，抛砖引玉，探索实现的最佳实践。文章其余部分如下安排：首先在“导论”中，讨论了多工作负载的意义以及不同架构的调度系统的支持方式。其次在“预热”一节详细介绍了在 Kubernetes 上对多工作负载的不同支持方案，进一步划定本文的讨论范围。最后在“正文”一节介绍实现 CRD Operator 的注意事项。本文主要内容来自笔者在实现 kubeflow/tf-operator 时的经验教训。
"

---

8012 年了，Kubernetes 已经成为了集群调度领域最炙手可热的开源项目之一。而多工作负载支持，是讨论到集群调度时不得不谈的一个话题。CRD 是 Kubernetes 的一个特性，通过它，集群可以支持自定义的资源类型，这是在 Kubernetes 集群上支持多工作负载的方式之一。本文希望讨论在实现一个 Kubernetes CRD Operator 时可能遇到的问题以及解决方案，抛砖引玉，探索实现的最佳实践。文章其余部分如下安排：首先在“导论”中，讨论了多工作负载的意义以及不同架构的调度系统的支持方式。其次在“预热”一节详细介绍了在 Kubernetes 上对多工作负载的不同支持方案，进一步划定本文的讨论范围。最后在“正文”一节介绍实现 CRD Operator 的注意事项。本文主要内容来自笔者在实现 [kubeflow/tf-operator][] 时的经验教训。

## 导论

集群资源的调度问题，是云计算领域一直很火热的研究方向。学术界与工业界目前也有诸多如 Borg, Docker Swarm, Firmament, Fuxi, Hawk, Kubernetes, Mercury, Mesos, Nomad, Omega, Sparrow, Yarn 等等各具特色的调度器进入我们的视线。机器集群在调度器的帮助下混合运行多种工作负载，大幅度提高了整个集群的利用率。不同的工作负载之间相互地削峰填谷，这也是集群化的管理能够提高机器利用率的一大原因。举例说明，在线任务白天利用大部分资源，而晚上业务空闲时让渡资源给离线计算任务。因此多工作负载的支持对于一个生产环境可用的集群管理系统而言，是非常重要的特性。

单体架构的调度器，对于多工作负载的支持并不是特别让人满意。由于只有一个单体的调度器，所有的工作负载都需要被统一地调度。在大规模的场景下会成为系统的瓶颈。因此目前 Kubernetes 也在探索支持多调度器，但目前在解决调度冲突问题时尚不成熟。以 Mesos 为代表的两层式调度器架构，对多工作负载的支持相对较好，但也有受制于中心化的调度器接口限制，难以获取集群全局状态的问题。以 Sparrow 为代表的去中心化架构，是为了短时批处理任务的负载优化的调度器，因此对于长时任务并不友好。以 Hawk 为代表的混合式调度器架构，和以 Nomad 为代表的共享状态的调度器架构，是对多工作负载支持最好的调度器，但是，它们都没有 Kubernetes 火= =

目前的 Kubernetes 在笔者心中，并不是最完美的集群调度系统，但是架构并不能说明一切，它的开发速度，社区活跃程度是其他项目完全不能媲美的，因此讨论在 Kubernetes 上的多工作负载支持是最具有实际意义的。

## 预热

Kubernetes 对多工作负载的支持见仁见智，有着各种不同的实现方式。这里举一些比较具有代表性的例子。首先就利用 Kubernetes 自带的资源类型，如 Pod, Service, Job 等，在 Kubernetes 之上构建出满足工作负载的应用。Kubernetes 本身的资源类型足以支撑大多数互联网应用的需求，比如前后端应用等。之前介绍的 [kubeflow/katib][] 也是这样的实现方式。这样的实现优点在于简单方便。这样的方式适合以网站前端后端为代表的应用逻辑。

而基础资源类型的表达能力是有限的，哪怕是经过了内置的 controller 的扩展。因此 Kubernetes 支持 Custom Resource Definition，也就是我们一直提到的 CRD。通过这一特性，用户可以自己定义资源类型，并对其提供支持。这种方式也是我们本次讨论的重点。相比于之前的方式，这样的实现更加原生一点，Kubernetes 会将其视为资源的一种，apiserver 中的各种检查对其也是起作用的。因此 CRD 是可以起到四两拨千斤的作用，与其相关的生命周期的管理是由用户代码进行的，与此同时 Kubernetes 的一些公共特性，比如 kubectl 展示，namespace，权限管理等等都是可以被复用的。以 [kubeflow/tf-operator][]，[coreos/prometheus-operator](https://github.com/coreos/prometheus-operator)，[coreos/etcd-operator](https://github.com/coreos/etcd-operator) 为代表的 operator 都是利用了 CRD 这一特性对 TensorFlow，Prometheus 或 etcd 等不同的系统或框架进行了支持。

第三种实现方式，是 custom API Server。这种方式是复用 Kubernetes 的一些特性的同时，自由度最高的方式。在这种方式中，你可以自定义存储，以及其他在上述方式中不能自定义的内容，同时保有一定程度的公共特性。据我所知，Cloud TiDB 的实现就是通过自定义 API server 进行的。

本文主要聚焦在第二种方式上，大多数的工作负载的需求通过第二种方式即可得到满足。因此这里首先大致介绍下第二种方式的实现思路。让我们从一个 Kubernetes 用户的角度，来看第二种方式的支持。首先，与声明其他资源的方式一样，在创建自定义的资源时，我们需要一个定义的文件，通常是 YAML 格式的。随后，我们的会利用 `kubectl create` 命令来创建出对应的资源，这时，Kubernetes 会负责处理一系列对象创建的工作，随后我们可以利用 `kubectl describe` 命令来获得创建的对象的相关信息。

从一个程序员的角度来看，用户的资源请求到达 Kubernetes API server 后，需要被处理，处理特定资源请求的控制器，一般被称为 controller 或者 operator（关于 controller 和 operator 的异同的讨论可见 [kubeflow/tf-operator#300](https://github.com/kubeflow/tf-operator/issues/300)，以下统称为 operator）。Operator 会监听 API server，当有关于该 CRD 的请求到来时，operator 会通过回调函数处理请求，随后更新资源的状态。

这种方式始于 coreos 的 etcd operator，目前有了非常多的实践，在这篇文章中，主要介绍一下在实现过程中的一些问题，抛砖引玉地讨论 operator 的实现的最佳实践。

## 正文

正文终于开始了，这部分将从 CRD 定义，校验，状态管理，容错问题和架构等方面对 operator 的实现进行介绍。

### CRD 定义

CRD 是一切的开始，因此从这里出发。CRD 的定义并没有太多值得注意的地方，只是有一些惯例需要稍微关注一下。比如 CRD 的 name 通常是 plural 和 group 的结合。另外，一般来说 CRD 的作用域是 namespaced 就可以了。还有 kind 一般采用驼峰命名法等等。这里给出一个例子，不再赘述。

```yaml
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: tfjobs.kubeflow.org
spec:
  group: kubeflow.org
  version: v1alpha2
  scope: Namespaced
  names:
    kind: TFJob
    singular: tfjob
    plural: tfjobs
```

### CRD Validation

CRD validation 是 Kubernetes 1.9 的新特性，这是由一个学生的 Google Summer of Code 项目。通过这一特性，API server 会检查来自用户的输入是否是合法的，如果不合法会挡在 API server 门外，operator 可以不需要处理非法输入。这一特性是通过 OpenAPI 3.0 支持的，但是并不是完整的实现，诸如 `$ref` 和 `additionalProperties` 等等字段，在这一特性中是不支持使用的，可以说在 1.9 中是部分的实现。而仍有一部分函需支持的功能正在实现当中。

由于不支持 `$ref`，因此对于某些使用了 Kubernetes 的结构定义（如 PodTemplate）的 CRD 而言，就相对不是非常友好。因为如果要完全校验输入的合法，使用到的 Kubernetes 资源也需要定义 schema 进行校验，这相当于是重复性的工作。因此这里的建议是利用 [kubernetes/kubernetes#54579](https://github.com/kubernetes/kubernetes/issues/54579#issuecomment-370372942) 提供的方法，将 Kubernetes 的对象的引用进行一次自动 inline，参考实现可见 [gaocegege/crd-validation](https://github.com/gaocegege/crd-validation)。生成的 validation 定义如下所示：

```yaml
validation:
    openAPIV3Schema:
        description: TFJob represents the configuration of signal TFJob
        properties:
        apiVersion:
            description: 'APIVersion defines the versioned schema of this representation
            of an object. Servers should convert recognized schemas to the latest
            internal value, and may reject unrecognized values. More info:
            https://git.k8s.io/community/contributors/devel/api-conventions.md#resources'
            type: string
            ...
```

另外，如果 CRD 定义中存在 map 数据结构，比如这样：

```go
type TFJobSpec struct {
	// TFReplicaSpecs is map of TFReplicaType and TFReplicaSpec
	// specifies the TF replicas to run.
	// For example,
	//   {
	//     "PS": TFReplicaSpec,
	//     "Worker": TFReplicaSpec,
	//   }
	TFReplicaSpecs map[TFReplicaType]*TFReplicaSpec `json:"tfReplicaSpecs"`
}
```

由于缺乏对 `additionalProperties` 的支持，对于其的校验目前也是无法进行的，具体可见 [kubernetes/kubernetes#59485](https://github.com/kubernetes/kubernetes/issues/59485#issuecomment-380032718)。在 Kubernetes 1.11 之后这一问题会得到解决。

### 状态管理

由于 Kubernetes API Server 背后的存储是 etcd，对于频繁读写的需求并不是特别友好，因此这对 CRD 的状态管理也有一些建议。在实现时，尽量使用状态的 summary 来描述状态。以 Job 为例，Job 本身并不会维护其创建的所有的 pod 的状态，而是以汇总的方式维护一共有多少 running 的 pod，多少 succeeded 的 pod。这样可以尽量避免频繁的写。

除此之外，尽量用 Condition 而非 Phase 来描述状态，这也是 Kubernetes 社区推崇的方式。之前的很多资源都用 Phase 定义了一套状态机，这样并不方便处理，具体细节可以参考 [kubernetes/kubernetes#7856](https://github.com/kubernetes/kubernetes/issues/7856)。

### 容错性

由于目前 Kubernetes 对 CRD validation 的支持还存在一定的局限性，因此在 operator 得到的输入中仍有可能是非法的。而在非法的输入中，存在一些类型错误，比如在应该输入 string 的地方，得到的是一个 integer。这样的错误可以 crash
整个 operator，使得 operator 的可用性降低。

一个临时的解决方案是使用一个无类型的 informer，代替由 API 生成的 typed informer，随后再进行一次 convert 转为对应类型。具体可见 [kubeflow/tf-operator#561](https://github.com/kubeflow/tf-operator/issues/561#issuecomment-392412816)。

### 架构

因为 operator 本身其实是将对某种类型的应用的运维逻辑固化在了其中，所以很容易就会被实现成有状态的方式。比如在 [kubeflow/tf-operator] 的第一版实现中，会在 operator 的内存中维护一个 cache，来记录当前由 operator 处理的请求的状态，并且基于 cache，在新的请求到来时也会根据 cache 决定如何处理新的请求。这样的实现方式乍一看好像没什么问题，但是当 operator 遇到问题 crash 需要被重新运行时，因为内存中的 cache 是不会被持久化的，因此就会在处理新请求时出现问题。

因此更推荐的方式是利用 informer，完全以事件驱动的方式处理请求。举例说明，如果不是以事件驱动的架构来处理一个新的请求“创建一个新的 TensorFlow 分布式训练任务”，operator 会在内存里维护从训练任务的名字到训练任务对象的映射，在检查过发现映射不存在后，会创建出对应的对象，并且在 Kubernetes 中创建对应的资源。当任务完成时，通过在内存中的映射找到对应的对象，更新它的状态为 completed。

而如果是事件驱动的架构，在受到请求后，发现 Kubernetes 上并没有对应的资源，这时会创建出来，然后结束逻辑。随后对应的资源被创建时，会产生新的创建事件，operator 再基于新的事件，更新训练任务的状态。在训练完成后，从 Kubernetes 中获取资源并且更新它的状态。不知是否解释地够清楚，总结来说就是保证 operator 是无状态的，所有的状态都应该依赖 API Server。

## 结语

本篇文章介绍了在实现 Kubernetes CRD operator 时可能遇到的一些问题以及对应的解决方案，希望能够对各位有所帮助。

## 关于作者

[高策](http://gaocegege.com)，上海交通大学软件学院研究生，预计 2019 年毕业，Kubeflow Maintainer。如有问题还请不吝赐教。

欢迎关注我们的 [GitHub](https://github.com/dyweb) 以及[博客](http://blog.dongyueweb.com/) :)

## 参考资料

- [The evolution of cluster scheduler architectures](http://firmament.io/blog/scheduler-architectures.html)
- [Container Camp AU 2017 - Building a Kubernetes Operators](https://github.com/lukebond/cc-au-k8s-operators-workshop)
- 唐瑞. 基于Kubernetes的容器云平台资源调度策略研究[D].电子科技大学,2017.
- [kubeflow/tf-operator][]

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
