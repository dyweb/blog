title: "Unikernel: 从不入门到入门"
date: 2017-09-04 11:23:26 +0000
update: 2017-09-04 11:23:26 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "Docker"
    - "云计算"
    - "虚拟化"
preview: "Unikernels: Beyond Containers to the Next Generation of Cloud 是 Russ Pavlicek 的一本动物书（虽然是 O'Reilly 的，但是封面不是动物，是石榴），这本书对 Unikernel 有着比较全面的介绍，而且电子书是免费的，值得一读。"

---

[Unikernels: Beyond Containers to the Next Generation of Cloud](http://www.oreilly.com/webops-perf/free/unikernels.csp) 是 [Russ Pavlicek](https://www.linkedin.com/in/rcpavlicek/) 的一本动物书（虽然是 O'Reilly 的，但是封面不是动物，是石榴），这本书对 Unikernel 有着比较全面的介绍，而且电子书是免费的，值得一读。

## 啥是 Unikernel？

从 2014 年以来，容器以一种不可逆转的态势席卷了全球，Unikernel 是很多人眼中的下一个容器。如果要了解什么是 Unikernel，首先需要了解什么是 kernel，kernel 是操作系统中的一个概念。应用要运行起来，是肯定要跟硬件打交道的，但是如果让应用都直接操作硬件，那一定是一场灾难。那内核就是在应用与硬件中间的一层抽象，内核提供了对底层硬件的抽象，比如把硬盘抽象成了文件，通过文件系统进行管理。传统的内核会将所有的硬件抽象都实现在其中，其中的代表就是 Linux，这样的内核被称为宏内核（Monolithic Kernel)。在宏内核中，所有的模块，诸如进程管理，内存管理，文件系统等等都是实现在内核中的。这样虽然不存在通信问题，但是任何一个模块的 bug 会使得整个内核崩溃。

于是学者们提出了微内核（Micro Kernel）的概念，在内核中只保留必要的模块，比如IPC，内存管理，CPU调度等等。而其他，诸如文件系统，网络IO等等，都放在用户态来实现。这样会使得内核不那么容易崩溃，而且内核需要的内存小了。但是由于模块间的通信需要以 IPC 的方式进行，因此有一定的 overhead，效率不如很莽的宏内核。

那后来又有了混合内核（Hybrid Kernel)，把一部分不常使用的内核模块，或者是原本需要的时间就很长，因此 IPC 的 overhead 看起来就不是那么夸张的功能，移出内核，而其他的就会放在内核里。

再后来还有 Exokernel，但是太长了就不讲了，这部分内容在 [CSP 课堂笔记之 UniKernel](http://gaocegege.com/Blog/csp/unikernel) 一文中有更详细的解释。

直接说 Unikernel，[Unikernel 的官方解释](http://unikernel.org/)是

>Unikernels are specialised, single-address-space machine images constructed by using library operating systems.

翻译一下就是

>Unikernel 是专用的，单地址空间的，使用 library OS 构建出来的镜像

其最大的卖点就是在，没有用户空间与内核空间之分，只有一个连续的地址空间。这样使得 Unikernel 中只能运行一个应用，而且对于运行的应用而言，没有硬件抽象可言，所有的逻辑，包括应用逻辑和操作硬件的逻辑，都在一个地址空间中。

## 这样有啥好？

哦，原来 Unikernel 就是一个单一内存空间的内核镜像，其中只能有一个应用在运行，那这样有啥好呢，为啥值得我放弃 Linux 而用你这么一个看上去像是阉割版的内核呢？好处就在，小，快，安♂全 /w\

Unikernel 镜像都很小，由 [MirageOS](https://mirage.io/) 实现的一个 DNS server 才 184KB，实现的一个 web server 674 KB，小到恐怖的程度。

然后就是快，启动很快。因为镜像都很小，所以起停都在毫秒级别，比传统的 kernel 要快多了。

最后是安全，一般来讲，小的东西相对而言比较安全。Unikernel 中没有 Shell 可用，没有密码文件，没有多余的设备驱动，这使得 Unikernel 更加安全。

## 开发测试与传统有啥不同？

Unikernel 在真正实践中，如何开发与测试是一个值得关注的问题。在开发过程中，开发者可以假定自己在传统的操作系统上进行开发，而所有内核相关的功能，暂且由开发机的操作系统提供。

而在测试环境中，大部分 Unikernel 的实现会将应用代码与需要的内核模块构建成 Unikernel 后，再将其跑在一个传统的操作系统上，利用传统操作系统上的工具来测试 Unikernel。以 [Rumprun](https://github.com/rumpkernel/rumprun) 为例，它可以通过 KVM/QEMU 来运行一个 Rumprun Unikernel VM，随后用 Host OS 上的 GDB 来对其进行调试，具体细节可见[此处](https://github.com/rumpkernel/wiki/wiki/Howto:-Debugging-Rumprun-with-gdb)。关于调试就介绍到此，如果你想了解更多，[Hacker News 上的这个 post](https://news.ycombinator.com/item?id=10954132) 可能会给你一些启发。

在发布阶段，这是 Unikernel 最简单的事情了。Unikernel 最后的产物就是一个 kernel image，可以在 Hypervisor，Bare Metal 等等各种环境上运行。

所以可以看到，其中 Unikernel 在软件过程中与传统方式最大的不同就在于调试与测试。而在发布的阶段，传统的方式可能发布的是一个应用，时髦一点那一个容器镜像，而 Unikernel 则是一个高度定制化的 kernel。

## 目前的 Unikernel 项目

介绍完 Unikernel，接下来将介绍下目前比较成气候的 Unikernel 项目，Unikernel 的实现大部分都是语言特定的。因为涉及到具体语言的运行时，所以很难有一个项目可以适配所有的技术栈。

[MirageOS](https://mirage.io) 应该是名气最大的一个 Unikernel 项目，它是使用 OCaml 进行开发的，也是要求开发者懂 OCaml 才行。与其他 Unikernel 相比，它非常成熟，而且有一些[论文](https://mirage.io/wiki/papers)，对钟爱论文的同学非常友好。

[HaLVM](https://github.com/GaloisInc/HaLVM#readme) 也是一个比较早的 Unikernel 项目，它可以帮助 Haskell 程序员们把自己的 Haskell 程序构建成 Unikernel。如果你不会 Haskell，那就算了 =。=

[ClickOS](http://cnp.neclab.eu/clickos) 是一个比较独特的项目，他也非常古老了，但是原本 Click 并不是以 ClickOS 的形式出现的，原本它只是一个支持定制的 router，后来就变成了 ClickOS，一个基于 Unikernel 的 router。它也有很多[论文](http://www.read.cs.ucla.edu/click/publications)，大部分都是关于 Click 本身，而不是 Unikernel 实现的。

[Rumprun](https://github.com/rumpkernel/rumprun/) 也是一个非常独特的项目，其利用了 [Rump Kernel](http://rumpkernel.org/)，理论上 POSIX 兼容的程序，都可以用 Rumprun 来构建成 Unikernel。

如果这些还不能满足你的好奇心，[Open source work on unikernels](http://unikernel.org/projects/) 上列出了众多的 Unikernel 项目，如有需要还请自行浏览。

## Unikernel, Docker，Hyper 与 Linuxkit

对 Unikernel 的介绍就是这些了，最后再谈谈自己对目前很火的一些概念的看法，以及它们之间的联系。

Unikernel，在我看来，是另一种形式上的容器。在一个 Unikernel 中，只能运行一个应用，这与容器的哲学不谋而合。但现在容器最吸引人的特性并不是它的便捷，而是在它的分发。Docker 让我们看到了，原来应用的分发可以这么无痛。而 Unikernel 与容器相比，虽然可以做的更小更安全，而且也不需要有 Docker Daemon 这样的后台程序存在，甚至不需要 Host OS，或者 Hypervisor，但是它一是与传统的软件过程有较大的出入，二是在分发等等方面不能做到像容器那样方便。所以它目前肯定不会成为主流的应用分发方式，还需要进一步探索。

为了能够让 Unikernel 尽快进入生产环境，有一项工作很值得关注。

![](-/images/posts/unikernel/unikernel.png)

在 Unikernel 里运行一个 Docker Container，想法很美好，但是同样也有很多问题。这样其实并没有利用到容器便于分发的优势，也没有完全发挥 Unikernel 的优势，我觉得这不是未来。不过作为一种折中方案值得一看，可惜从 DockerCon 15 之后就没听见什么动静了。

Hyper Container 的技术特别独特，之前在 [Docker 与 Hyper](http://gaocegege.com/Blog/docker-rambles) 一文中介绍过，这里不再多说。他们的实现很完整，有对标 runc 的 runv，有扩展 Kubernetes 中 container runtime 的 frakti，虽然我没有尝试过，但是我觉得是比 Docker in Unikernel 更加可行的方案，讲道理很有前途。

Linuxkit 是 Docker 改名 Moby 后随之发布的一个项目。Linuxkit 严格来说是一个构建操作系统的工具集，可以用来构建 Unikernel，但是也可以用来构建最小化的 Linux Kernel，目前还不知道要往什么方向发展。

这些概念或多或少都有相互重叠的部分，也没有谁一定胜过谁的说法，但都有一个特点：有趣。它们都有自己不同的应用场景，本来嘛，Docker 也不是银弹。

PS：本文都是纸上谈兵，作者本人并无对 Unikernel 在生产环境中的使用经验（应该暂时也没有人有），大家看看就好，如有疏漏还请不吝指教:)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
