title: "Google SRE 阅读笔记(1)-监控"
date: 2017-01-02 08:27:04 +0000
update: 2017-01-02 08:27:04 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "site reliability engineering"
preview: "SRE，全称是 Site Reilability Engineer，是一个类似于运维，但是跟传统运维不一样的职业，更加偏向于 DevOps。谷歌在 [SRE-谷歌运维解密](https://book.douban.com/subject/26875239/) 一书中分享了 SRE 的工作职责，以及谷歌在自己的运维工作中的一些经验。"

---

#### 转载自 [gaocegege 的博客](http://gaocegege.com/Blog/%E9%98%85%E8%AF%BB/sre-0)

## SRE 介绍

SRE，全称是 Site Reilability Engineer，是一个类似于运维，但是跟传统运维不一样的职业，更加偏向于 DevOps。谷歌在 [SRE-谷歌运维解密](https://book.douban.com/subject/26875239/) 一书中分享了 SRE 的工作职责，以及谷歌在自己的运维工作中的一些经验。

## 本文介绍

这篇博客是系列文章中的第一篇，主要分享在阅读这本书时的一些感想。这本书在我看来更加适合在分布式领域或者在运维领域工作的工程师阅读，对于一个还在念书，没有完整接触过分布式系统实现的新手来说，有些过早了。因此就当是抛砖引玉，随便写写吧。

这次关注的是书中的第六章，分布式系统的监控。

## 关于作者

第六章的作者是 [Rob Ewaschuk](https://www.linkedin.com/in/robewaschuk)。作者主要工作的领域是分布式存储，而且在自我介绍中写道自己在谷歌干的很过瘾，16-17年是不打算换工作的。O'Reilly 摘录了他在 SRE 一书中关于分布式监控的部分，做了一本电子书 [Monitoring Distributed Systems](http://www.oreilly.com/webops-perf/free/monitoring-distributed-systems.csp)。

## 阅读之前

在读文章之前，我对监控的了解非常浅薄。因为无论是在学校还是在之前实习，都没有涉及到对生产系统进行监控的工作。在念了研究生之后，稍微了解了一些关于分布式监控的知识。[Dapper, a Large-Scale Distributed Systems Tracing Infrastructure](https://static.googleusercontent.com/media/research.google.com/zh-CN//pubs/archive/36356.pdf) 是谷歌在 2010 年发表的论文，是关于其内部的分布式 tracing 系统的一个介绍性的论文。Tracing 在我的理解是细粒度监控中很关键的一部分。点评开源了一套这样的系统 [CAT](https://github.com/dianping/cat)。这些系统的作用就是跟踪系统相互之间的调用。比如 Web 前端调用了后端，就会生成一个从前端指向后端的 trace 记录。业界比较常见的实现是埋点或者修改字节码，前者更加可行。在阅读之前，对于分布式监控的了解也就仅限于此了。

虽说读过相关论文，但是并没有真实使用过，最多就是去过点评，见过点评的 CAT 的 dashboard 是长什么样子的。

## 正文

全文中提到的一些东西让我非常感兴趣。其中有一句话：

>我们会避免任何『魔法』系统--例如视图自动学习阈值或者自动检测故障原因的系统。

之前在去大众点评学习 CAT 系统时，听他们说下一步发展规划中，就有利用机器学习来学习阈值和原因的想法。我认为谷歌在为什么要保持监控系统简单时没有说清楚，这可能是跟他们的监控规模和信奉的哲学有关。他们把这类复杂的有各种特性的系统称为『魔法』系统，因为我也没有什么发言权。但是在我看来，随着复杂性的上升，引入机器学习等等是自动化的新阶段。现在可能人工的方式或者硬编码等等方式还是可以操作的，可能谷歌考虑到监控系统要尽可能稳定吧。但是机器学习可以更好地取代人工，就像在容量规划方面，我始终认为机器学习会比经验估计的更准。

书中写了四个谷歌认为的黄金监控指标，分别是延迟、流量、错误和饱和度。对于延迟，他们提到的一点对我来说特别具有启发性，那就是要区分成功请求和错误请求的延迟。这两类请求有着不同的模式，是不能混为一谈的。之前用过的少数几个监控的工具都没有区分正确与错误请求的能力。这一点是在看了这本书后才学到的。

还有一个比较有趣的指标，是饱和度。饱和度是指服务容量有多满，一般是用瓶颈资源的使用率来衡量。这样衡量饱和度的方式很取巧，之前没有过工程经验，都是各种指标全看一遍，最后看哪个资源不够用了，就断定服务满载了。如果事先判断好是 Memory-bound 还是 CPU-bound 类型的服务，然后每次只需要看对应的瓶颈资源就好了。

关于长尾问题，谷歌给出了一种监控的方法，使用直方分布图而不是平均值来进行展示。因为可能一小部分请求导致了长尾，但是平均值是看不出这个问题的。

在监控系统构建后，有一个值得考虑的问题，是短期可用性与长期可用性的冲突。短期的可用性体现在对问题的及时修复上，而长期的可用性在于对系统造成问题的根源的消除上。看起来这两者是统一的，但是其实是冲突的。人的精力是有限的，如果一直在处理 On-Call 的问题，那必然会导致缺少时间投入到根源性问题的解决上，这时需要权衡，放弃一些 On-Call 非核心的问题，去优化系统，提高长期预期的可用性。

## 下文预告

下一篇文章将会谈谈有关发布工程（Releasing Engineering）的事情。

## 系列文章

* [Google SRE 阅读笔记(1)-监控](http://blog.dongyueweb.com/google_sre_%E9%98%85%E8%AF%BB%E7%AC%94%E8%AE%B0%281%29-%E7%9B%91%E6%8E%A7.html)

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
