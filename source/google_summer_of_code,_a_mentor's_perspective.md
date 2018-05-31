title: "Google Summer of Code, A Mentor's Perspective"
date: 2018-05-07 12:33:23 +0000
update: 2018-05-07 12:33:23 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "Google Summer of Code"
preview: "这篇文章的受众是想更加深入了解 Google Summer of Code 这一活动，或者有志于担任某一开源社区 mentor 的同学。由于有些背景知识没有介绍，因此配合 Google Summer of Code 学生申请指南阅读更佳。"

---

这篇文章的受众是想更加深入了解 Google Summer of Code 这一活动，或者有志于担任某一开源社区 mentor 的同学。由于有些背景知识没有介绍，因此配合 [Google Summer of Code 学生申请指南](https://zhuanlan.zhihu.com/p/27823910)阅读更佳。

## 背景介绍

[Google Summer of Code](https://developers.google.com/open-source/gsoc/)（下称作 GSoC）是谷歌组织并提供经费，面对全球（绝大多数国家）在读学生的在线编程项目。它的[官方介绍](http://write.flossmanuals.net/gsocstudentguide/what-is-google-summer-of-code/)是：

> Google Summer of Code (GSoC) is a global program that matches students up with open source, free software and technology-related organizations to write code and get paid to do it! The organizations provide mentors who act as guides through the entire process, from learning about the community to contributing code. The idea is to get students involved in and familiar with the open source community and help them to put their summer break to good use.

即是：

> Google 编程之夏是一个全球性项目，旨在为学生们和开源、自由软件、技术相关的组织建立联系，让学生们贡献代码并获得报酬！组织会提供导师，在学生从熟悉社区到贡献代码的整个过程中提供指导。这个想法的目的是让学生们参与和熟悉开源社区，并帮助他们充分利用暑假时间去得到锻炼。

具体可见 [Google Summer of Code 学生申请指南](https://zhuanlan.zhihu.com/p/27823910)，这里不再赘述了。这篇文章主要是从一个 mentor 的角度，来谈一谈对 Google Summer of Code 这个活动的理解。

## GSoC 的流程 Extended

在上一篇文章中，我介绍了一下从学生的角度看到的 Google Summer of Code 的流程，不过在 mentor 的角度来看，又有一些不同的地方。这里从头开始，重新介绍一下整个 GSoc 的 Timeline。

一切的一切始于 organization 的申请。在 GSoC 中，不只是需要学生来申请 organization 的 slots，organization 也是要先向谷歌申请参加当年 GSoC 的。GSoC 的申请向来是一个黑盒的过程，我们看不到谷歌内部做了怎样的考量，会允许哪些组织参与今年的 GSoC。但是一般来说，老牌的组织很少有申请不中的情况，所以如果想尽早关注 GSoC 的话，建议还是从每年的 slots 数量比较多的组织下手，这些组织已经参加过多次 GSoC，再次入选的可能相对比较大。不过值得一提的是，像 The Processing Foundation 这样的老牌组织，在 2016 年的时候就被拒绝了。所以这只能保证概率，而不是绝对。

一般对于 organization 申请的时间窗口大概是在 20 天左右，谷歌在申请结束后花 20 天左右的时间来确定入选的组织，因此这整个过程大概要花 40 天。接下来就是我们熟知的，学生申请的过程。在这个过程里学生会根据每个组织列出的 idea 来提交自己的 proposal，这个的时间窗口在 15 天左右。

接下来 10 天的时间，是社区的 mentor 和 admin 们来 review 学生的 proposal 的阶段。在这一阶段，组织的 admin 需要在看过所有的 proposal 后，根据申请的质量来确定今年向谷歌申请的 slots 数量。这个数量是以区间的形式提交的，即提交一个最小值与一个最大值。谷歌不能保证给到你最小值的 slots 但可以保证最多不给你超过最大值的 slots。另外值得注意的是，一个新的 org，通常来讲只会有 1-2 个 slots。因为谷歌认为这些 org 可能还不太了解 GSoC 对组织的负担其实还是蛮大的。因此如果是申请的新 org 时，要格外注意这一点。

接下来谷歌会花 1 天的时间来确定 org 真正可以拿到多少个 slots，这也是黑盒的操作，org 中的任何一个人在谷歌公布之前，都不能确定今年一共几个 slots。

在确定了 slots 的数量后，org admin 会来分配 slots 给学生。这个过程大概持续 10 天的时间。在这个期间 mentor 起不到决定性的作用，因为 slots 的名额分配是 org admin 来做的。而 mentor 起到的作用是对其 mentor 的 idea 的 proposal 打分，给出参考性的意见。

在确定了 slots 分配后，org admin 和 mentor 就会知道哪些学生可以参加今年的 GSoC，但是真正面向学生的公布会在 5-6 天后由谷歌在 GSoC 的网站上进行。在这段时间里谷歌会复查所有被选中的学生的 eligibility。

随后在项目公布后，便会进入为期 20 天的 Community Bonding Process。在此期间，mentor 需要与学生建立联系，相互熟悉为后面的合作打好基础。除此之外学生也应积极地参与社区，如果 mentor 认为学生在这段时间并没有很好地进行交互，是可以而且被建议直接 fail 掉学生的。因为这段时间是 GSoC 项目的前期准备时间，如果这段时间里准备不是很充分，后面真正开始写代码的时候或多或少会有风险。

在度过了 Community Bonding Process 后，就进入真正的 coding 环节。Coding 环节一共有三个 evaluation，将整个编程环节分成了三个 phase，每个 phase 大概有一个月的时间，所以整个编程的时间大概有三个月（五月到八月）。

## Mentor 职责

Mentor 在 organization 开始申请之前，需要先写出自己想 mentor 的 idea 的 description，来说清楚 idea 的目标是什么，需要什么技术栈的同学来做，以及难度如何等等，例如 [coala Language Server](https://projects.coala.io/#/projects?project=coala_language_server&lang=en) 这样。期间可能需要跟 org admin 交流来确定 idea 的工作量和重要程度等等。

在开放学生申请后，Mentor 需要接受来自各位对 idea 的学生的询问和套瓷，解答他们的疑惑，review 他们的 proposal 草稿并且给出你的意见。这是一个非常艰难的阶段，一方面有一些申请者由于对社区和 idea 都不熟悉，会有很多在文档里都有记录的问题来问。另一方面，不同的学生对 idea 的解读不同，导致会花很多时间在 sync mentor 和学生之间的理解上。

在学生申请 deadline 后，mentor 需要 review 所有的 proposal，随后给出自己的选择倾向。如果遇到了两个 candidate 都很强的情况，可能还要组织一次 video interview 或者类似的考核方式。不过前面也提到了，最终的选择是 org admin 进行的<del>，当然mentor 的决定权也是很重要的</del>。

在 Community Bonding Process 中，mentor 需要和学生取得联系，并且与 org admin 沟通确定学生在这个期间需要做的事情，这是因社区而异的。同时，最好在这个时候确定下来与学生的常规交流时间，以及管理与交流工具的选型。在随后的 coding phase 中，mentor 主要起到的是进度管理，和解决学生对 code base 的疑惑等等这些问题。

## 申请相关的建议

最后谈一谈申请相关的事情吧。就我看过的申请情况来说，大体上申请人基本可以分为这么几类：

首先就是在申请的社区里贡献了很久（甚至有的已经成为了 maintainer），与此同时有一些与申请的 idea 强相关的贡献的一类候选人。这种候选人基本来说如果 idea 不是特别边缘，都是板上钉钉的样子，这个就不多讨论了。

其次是在申请的社区里贡献了很久，但是与申请的 idea 并没有什么交集的一类。这一类候选人，是稍微有点吃亏的。虽然在社区里做了一段时间，但是因为没有 PR 或者经历来证明其对申请的 idea 的了解。

还有一类是虽然在社区里声明不显，但是在申请的 idea 有关的技术领域有一定的积累的候选人。这种就有点神经刀的感觉，看上去并无太大出众之处，但搞不好就可以交出一份方案详实，安排合理的 proposal。

上面提到的三类申请者是比较可能申请到 GSoC 的候选人，而一个社区参与不多，对申请的 idea 上也无太多了解的同学就相对难度较大了，因为 GSoC 很少接受只是 ok 程度的 proposal。

谈一下对第二类和第三类候选人的建议。如果你是第二类的候选人，在社区里属于活跃的贡献者，那你应该有近水楼台先得月的优势。所以我觉得需要做的是尽早跟感兴趣的 idea 的 mentor 联系，学习 idea 相关的知识，做出一些针对性的贡献。要是跟第三类候选人在同等条件下，肯定会倾向于选在社区已经有过贡献的第二类啦。

对于第三类候选人，因为社区贡献不是一个可以短期速成的东西，因此建议可以多跟 mentor 沟通，在少量贡献的同时完成一份更高质量的 proposal，可能是更有竞争力的一种选择。

## 结语

这又是一篇摸鱼作，希望能够对各位有所帮助。如果你在申请 GSoC 的过程中有什么疑惑，欢迎加入 GSoC CN 的在线聊天频道 [Gsoc-cn/Lobby](https://gitter.im/Gsoc-cn/Lobby)。GSoC CN 是一个由国内的参加过 GSoC 的同学们创建的社区，我们维护有一些[社区的介绍](https://github.com/gsoc-cn/gsoc-cn/tree/master/resources/organizations)和往年的 proposal，可能会对你有些帮助。

欢迎关注我们的 [GitHub](https://github.com/dyweb) 以及[博客](http://blog.dongyueweb.com/) :)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
