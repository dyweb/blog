title: "Go Hack 17 参赛日记"
date: 2017-10-24 07:30:10 +0000
update: 2017-10-24 07:30:10 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "hackathon"
    - "TiDB"
    - "Go"
preview: "2017 年 10 月 21 日，由 Golang Foundation 和 PingCAP 联合举办的 Go Hack 17 在上海心动网络举行，东岳的小哥哥 @gaocegege 和 @codeworm96，以及工作一年的的 Go 工程师 @hawkingrei 一起组成了队伍 ，参加了这次 hackathon，凭借 killy: Play TiDB in Minecraft! 取得了二等奖以及 PingCAP 赞助的专项奖。这篇文章是 @gaocegege 第一人称视角的 hackathon 记录。"

---

[@codeworm96]: https://github.com/codeworm96
[@hawkingrei]: https://github.com/hawkingrei
[@prism-river]: https://github.com/prism-river
[Killy]: https://github.com/prism-river/killy

2017 年 10 月 21 日，由 [Golang Foundation](http://golangfoundation.org/) 和 [PingCAP](https://pingcap.com/index) 联合举办的 [Go Hack 17](http://gohack2017.golangfoundation.org/) 在上海心动网络举行，东岳的小哥哥 [@gaocegege](https://github.com/gaocegege) 和 [@codeworm96][]，以及工作一年的 Go 工程师 [@hawkingrei][] 一起组成了队伍 ，参加了这次 hackathon，凭借 [killy: Play TiDB in Minecraft!](https://github.com/prism-river/killy) 取得了二等奖以及 PingCAP 赞助的专项奖。这篇文章是 [@gaocegege](https://github.com/gaocegege) 第一人称视角的 hackathon 记录。

## 好名字是成功的一半

先从开头说起，最开始，是从 TiDB Contributor 的微信群中，看到了 PingCAP 小狼发的链接，知道了这个 hackathon。因为之前 hackathon 中的一些不好的体验，所以当时对是否参加这个比赛还是持观望态度。但是考虑到自己马上就要毕业了，需要多多地接触公司为一年后的实习还有两年后的工作做一些铺垫，在赞助公司里有好多是自己比较感兴趣的公司，于是拉拢了与我同在软院的大四学弟 [@codeworm96][] 和之前在 [Processing.R](https://github.com/gaocegege/Processing.R) 项目上有过合作的 Go 工程师 [@hawkingrei][] 组队报名了。

在报名的时候，组织方要我们提交项目名和队名，于是我们提交了两个特别二次元的名字。团队的名字“Prismriver”是 [@codeworm96][] 学弟起的，是 [东方 Project 里的三姐妹](https://zh.moegirl.org/%E8%8E%89%E8%8E%89%E5%8D%A1%C2%B7%E6%99%AE%E8%8E%89%E5%85%B9%E5%A7%86%E5%88%A9%E5%B7%B4)。项目的名字“Killy”是 [@hawkingrei][] 提出的，一部硬科幻的男主的名字，据他说男主挺帅的。当时想着反正之后做项目可以改，并没有什么关系。但是后来开始之后也就没那么多闲心去想名字了，索性一直沿用到最后。而因为在 GitHub 上创建 organization 的时候我忘了 Prismriver 是连在一起的还是分开的，错误地使用了 prism-river，Go 对项目的路径是有要求的，直接改动组织名会造成很多麻烦的事情，所以现在在 GitHub 上我们的名字是 [@prism-river][]。

## Idea 是成功的一半的一半

定下了名字，开始想 idea。在石墨文档上记录着我们当时所有想到的 idea，一共有十二个。[@hawkingrei][] 工作了一年多，想到的很多 idea 是跟他的日常工作息息相关的，都是一些可以解决他的痛点的小 idea。因为我之前做过容器和持续集成方面的工作，因此想到的多是跟 Docker 或者 CI 有关系，偶尔有一些跟 TiDB 搭点边，下面的截图是我们想到一部分 idea。

<figure>
	<img src="/images/posts/killy/idea.png" alt="Ideas" width="500">
</figure>

在所有的 idea 中，我们确定了两个候选 idea，按照意愿排序是 TiDBcraft 和 Local Travis Runner Based on Docker。后者是我在实现 [caicloud/cyclone](https://github.com/caicloud/cyclone) 的过程中想到的一个工具。在日常的生活中，我比较常用的 CI 工具是 Travis CI，而因为在很多公司里用的多的还是 Jenkins。所以我在想怎么能把 Travis CI 的 build 放在 Jenkins 里跑，一种比较简单的做法，就是保留 Travis CI 的配置，根据配置运行一个容器，把容器放在 Jenkins 的 build 中去跑。Travis CI 自身的设计使得这样的实现变得非常简单，因为它们有专门的一个组件是做 `.travis.yml -> build.sh` 的转换的，得到 bash 脚本之后，放到 Travis CI 对应语言的官方镜像里去跑就好了。通过这样的实现，只要 repo 里有 .travis.yml 配置文件，就可以在任何支持 Docker 的 CI 工具中去运行。

TiDBcraft 就是我们后来决定实现的 [Killy][]，最初的 idea 来自于之前写的 [dronecraft](https://github.com/gaocegege/dronecraft)，而 [dronecraft](https://github.com/gaocegege/dronecraft) 是受 [dockercraft](https://github.com/docker/dockercraft) 启发。我们想在 Minecraft 中监视整个 TiDB 集群的状态，以及其中表的状态，等等，这可以理解为是一个 Minecraft 里的 TiDB Dashboard。这只是一个概念，在未来甚至可以把整个物理机房都建模在 Minecraft 里，再配合 HoloLens，就可以实现 VR 运维了 /w\

最后在这两个里投票选一个做的时候，是挺纠结的，最后是 [@codeworm96][] 更倾向于 Just for Fun，于是就拍定了做 TiDBcraft。

<figure>
	<img src="/images/posts/killy/record.jpg" alt="Record" heighy="400">
</figure>

## 好的分工是成功的一半的一半的一半

在介绍分工之前，先向大家介绍一下我们的架构。

<figure>
	<img src="https://github.com/prism-river/killy/raw/master/presentation/images/arch.png" alt="Arch" width="500">
</figure>

Killy 一共有两部分，前端与后端。前端是一个在 [Cuberite](https://cuberite.org/) 服务器中的插件。[Cuberite](https://cuberite.org/) 是一个用 C++ 实现的 Minecraft 服务器，支持使用 Lua 语言实现插件来扩展服务器功能，相信玩 Minecraft 的同学一定都接触过。后端是用 Go 实现的服务器，它负责从 TiDB 集群或者是 Prometheus 中定期拿到整个 TiDB 集群状态，然后转发给前端的插件，前端插件会将其绘制在 Minecraft 世界中，前后端通过一个 TCP 连接通信。整体的架构非常简单。

比赛开始的周六，在 5 分钟内我们三个人就敲定了分工。由我来负责前端插件的实现，因为相对来说我对 Minecraft 比较熟悉而且之前也写过几十行 Lua，尽管我更想写 Go =。= [@codeworm96][] 和 [@hawkingrei][] 负责实现后端的逻辑。更具体来说，[@codeworm96][] 负责与数据库本身的交互，[@hawkingrei][] 负责跟整个集群交互获得集群实时的状态。

## 完整的实现是成功的一半的一半的一半的一半

第一天下午是我们精力最充沛的时候。这个时候我在构思并实现如何在 Minecraft 中显示数据库的表，而他们两个人在调研如何订阅 TiDB 中数据的变更和感知到整个集群的状态变更。对于前者我个人觉得 binlog 可能是可以用的，但是这样有点麻烦，不是在这个 hackathon 中适合的解决方案，所以提出直接暴力地轮询。在 [@codeworm96][] 认可后他开始着手实现，而我快速地实现了第一版 UI。在第一版中，有很多局限性，比如字段最多只支持 4 个，因为 Minecraft 里一个告示板只能显示 4 行。后来在晚上的时候，[@codeworm96][] 实现了第一版逻辑，暴力轮询数据库表然后转发给前端，然后我们进行了集成。而 [@hawkingrei][] 这时也实现了第一版，可以拿到所有 TiDB 集群上实例的静态信息。在晚上 12 点左右，我跟女朋友先走了，回去后，[@codeworm96][] 告诉我接受 SQL 查询的功能也实现了，于是我对接了这部分逻辑，实现了在 Minecraft Console 中执行 SQL 查询的功能，并且做了一个小 trick，把查到的记录高亮显示，就是原本是蓝色羊毛，查询到会变成绿色羊毛。

<figure>
	<img src="https://raw.githubusercontent.com/prism-river/killy/master/presentation/images/table.png" alt="Table UI" width="500">
</figure>

这些结束后，就选择了睡觉，这个时候大概是 1 点半，睡前与 [@hawkingrei][] 约定好三点起来。[@hawkingrei][] 在彻夜工作，在 3 点半的时候微信告诉我他负责的监控部分已经准备好了，因为 Prometheus 有延迟，所有方案换成了直接通过 TiKV，PD 的 REST API 拿到状态数据。可是这个时候我还没起来 =。=

4 点 50 分的时候，我终于意识到再睡下去要背锅了，于是艰难地爬了起来。在 5 点 40 分的时候到了心动网络，从旁边的全家里买了一份三明治，走进了 hackathon 场地，发现大多数人都醒着，还在继续写 `_(:з」∠)_` 随后我们进行了联调，并且修改了第一版与数据库表相关的 UI，变成了更像表的结构，这个时候项目的主要功能都已经实现结束了，这个时候大概是早上 9 点。

随后，我开始着手写 PPT 与 README，进行 demo 的录制。在中午的时候与女朋友玩了一局王者荣耀，结束后就到了答辩的时间。

## 良好的答辩是成功的一半的一半的一半的一半的一半

我们组是第十一个答辩的，所以前面听了几组，感觉很多组的 idea 都非常有趣。轮到自己上场的时候，着重强调了功能，演示了 demo，介绍了架构，吹了一下前景（等于没有）。内容而言自己感觉还可以，就是形象不是特别好，人比较憔悴，因为熬夜头发比较油所以戴着帽子显得不是很尊重，而且也有点驼背。

在听过所有人的答辩后，我觉得大概是已经没戏了。有很多组的 idea 是真的非常棒，要技术有技术要场景有场景。但是可能做游戏天生就在展示上比较有优势，而且做的东西也确实比较有趣，最后误打误撞地拿到了二等奖。这可以说是非常有成就感了，要是放在之前，我会觉得一个 hackathon 的二等奖也就只能说说，但是这次的质量让我觉得有种成就达成的感觉，于是决定把它放在我的简历里 =。=

在整场比赛里，给我留下的印象最深刻的项目是 [xcbuild](https://github.com/setekhid/ketos)，他们希望通过实现一个 `docker build` 的替代品，希望能优化 CI 场景下镜像的构建方式。当然还有很多其他有趣的项目，可以去 [Go Hack 17 主页](gohack2017.golangfoundation.org) 里去看看。

这篇文章就到此为止了 :)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
