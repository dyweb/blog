title: "Google Summer of Code 申请指南"
date: 2017-07-11 09:02:34 +0000
update: 2017-07-11 09:02:34 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "Google Summer of Code"
    - "申请指南"
preview: "本文的受众主要是想在暑假找点事情做，挣点外块的同学，亦或是想积累一下参与真实软件开发经验的同学。"

---

本文的受众主要是想在暑假找点事情做，挣点外块的同学，亦或是想积累一下参与真实软件开发经验的同学。

## 背景介绍

[Google Summer of Code](https://developers.google.com/open-source/gsoc/)（下称作 GSoC）是谷歌组织并提供经费，面对全球（绝大多数国家）在读学生的在线编程项目。它的[官方介绍](http://write.flossmanuals.net/gsocstudentguide/what-is-google-summer-of-code/)是：

> Google Summer of Code (GSoC) is a global program that matches students up with open source, free software and technology-related organizations to write code and get paid to do it! The organizations provide mentors who act as guides through the entire process, from learning about the community to contributing code. The idea is to get students involved in and familiar with the open source community and help them to put their summer break to good use.

即是：

> Google 编程之夏是一个全球性项目，旨在为学生们和开源、自由软件、技术相关的组织建立联系，让学生们贡献代码并获得报酬！组织会提供导师，在学生从熟悉社区到贡献代码的整个过程中提供指导。这个想法的目的是让学生们参与和熟悉开源社区，并帮助他们充分利用暑假时间去得到锻炼。

整个活动的流程是这样的：在每年的二月末，GSoC 会公布一个 Mentoring organizations 的列表，比如 [2017 Organizations](https://summerofcode.withgoogle.com/organizations/)，这个列表是受到谷歌认可的开源社区或者组织。随后学生可以从列表中挑选出适合自己的 organization，并且在 organization 的 ideas list 中找出自己感兴趣，觉得可以胜任的 idea，提出申请。一个学生最多可以申请 5 个 idea，申请在 3 月末开始，4 月初结束。在 5 月份，Google 会公布所有入选的学生，社区会给每个学生分配一个或多个 mentor，mentor 负责指导学生的工作，并评估学生的工作是否满足了社区的要求。

公布之后，会有持续一个月的 Community Bonding Period，在这个阶段学生需要尽快融入社区，跟自己的 mentor 建立联系，熟悉社区工具链，交流工具等等。6 月份开始正式的开发工作。开发工作一共有三个阶段，同时也会有三个 evaluation。每个阶段大约一个月，会有一个小目标，如果 mentor 认为你完成了阶段性的目标，Google 会在每次 evaluation 结束后发放奖金。三次一共的奖金在 1200 - 6600 美刀之间。具体的数额跟所在地的 [Purchasing Power Parity](https://developers.google.com/open-source/gsoc/help/student-stipends) 有关,中国是 3600 美刀。

整个项目大概在 9 月份结束，但是社区的期望肯定是学生能够继续进行贡献，这也是他们获得新的 contributors 的一个重要途径。并且在持续贡献后，学生可以在来年的 GSoC 时申请成为 mentor，虽然 mentor 没有奖金，但是有一个 Google 组织的 Mentor Summit，据说就是公费旅游。

## 名词解释

因为在申请的时候不同的社区对于同一个对象的叫法都有所不同，所以这里列一些常见的名词的解释。

| 名词        | 解释           |
| ------------- |-------------|
| Organization，组织，社区    | Google 公布的 Mentoring organizations 中的组织，可以接收学生参与 GSoC |
| 学生，申请者    | 申请参加 Google Summer of Code 的学生 |
| Slots         | 社区可以接收的学生数量，由 Google 决定 |
| Mentor，导师   | 学生申请成功后社区指定的导师，指导学生的具体工作，以及负责评估完成度  |
| Stipend，奖金，奖励   | 在学生完成阶段性目标后由 Google 发放的奖金，具体的数额跟所在地的 [Purchasing Power Parity](https://developers.google.com/open-source/gsoc/help/student-stipends) 有关  |
| Evaluation    | 阶段性检查，mentor 会检查学生有没有达成阶段性成果，影响奖金发放 |

## 申请之前的准备

申请是一个比较漫长的过程，如果想更加稳妥一点，建议不要在谷歌公布 Mentoring organizations 列表后再进行准备，而是要提前选定一个或几个社区，进行持续的贡献和交流，尽可能混一个脸熟。这样与后期才开始准备申请的同学而言就有了很大的优势。除此之外，要日常性地多给开源项目做贡献。在申请的时候很多社区会要求学生提供其开源贡献的经历，无论是不是对自己社区的。这时如果你已经是其他社区的积极贡献者了，那无疑是会加分的。

对于社区的选择，如果你偏向保守，可以多回顾往年的列表，有一些组织是雷打不动的，比如 Python Software Foundation, Apache 这些老牌开源社区，这些相对于其他组织，有更大的可能被谷歌选中。如果你喜欢高风险，可以事先问问社区是否有申请 GSoC organization 的打算，如果有，而且你也看好，可以选择这样的社区进行贡献。

至于贡献的时间，窃以为比较理想的时间是前一年的 12 月份或者同年的 1 月份开始，就要尝试着去给社区做一些微小的工作。这些工作包括但不限于：

* 贡献代码，无论什么社区，都喜欢高质量的 PR
* Review PR，给别人的 Review 点赞
* 提交 Bug
* 添补更新文档
* 在 IRC 里解决别人的问题

在贡献的过程中，要注意交流，不要只是提交了就走人了，最好是可以时刻跟进，及时回复别人的信息也是一种表明你的热情的方式。

## 申请

### Organization 介绍

申请真正开始于谷歌公布的 Mentoring organizations 列表，这里大致介绍下其内容。

![](-/images/posts/gsoc/processing-org.png)

以 2017 年 GSoC 其中的一个开源组织 [The Processing Foundation](https://summerofcode.withgoogle.com/organizations/4962961559912448/) 为例，介绍一下 GSoC 主页上 organization 的页面布局。每个 organization 都会有一段介绍性的文字，这个不是很关键。右边的一栏是比较重要的，其中 Technologies 是方便大家在搜索 organization 的。上面的 VIEW IDEAS LIST 比较重要，一般来说每个社区会事先提出一些他们期望的 idea，学生可以就这些 idea 进行申请。当然社区也鼓励学生提出自己的 idea。其下的 Chat 和 Email 一般来说会写明该社区常用的交流工具，在申请的过程中往往需要频繁地与社区相关人员交流。

### 正式申请

Proposal，是一个申请时很关键的材料。它是学生在申请时需要提交的一个设计文件，在其中，学生往往需要写明自己的背景（学术背景，开源贡献经历等），对 idea 的了解与认识，以及大致的实现思路和方法。Proposal 的书写是没有定式的，只要可以突出你的长处就好，这是社区对你了解的唯一途径，所以需要你把自己所有的优势都要写在其中。

[Proposal for Processing.R](https://docs.google.com/document/d/1b0HhRVKtCJkDaxP9dfSwzthzX0FRv6Y_0Yk58r634TA/edit?usp=sharing) 是我在申请时的一份 Proposal，可以列为参考，介绍下常规的写法。

首先是 Project Description，这个部分就是让社区知道你对 idea 没有理解错，你深刻地了解这个 idea 想做的是什么。三言两语就好了。

然后是 Implementation，我个人觉得是比较重要的部分。要向社区证明你已经有了完整的实现思路，现在差的就是写代码实现而已了。

其次，是 Development Process，社区肯定更喜欢那些风险低，feature 吸引人的申请。一个好的 schedule 可以让社区相信你是真的已经做好了准备。精确到天自然最好，但是基本来说比较难，周和月都是不错的选择。不过有一点需要注意，不要把所有时间都安排的满满的，还是需要有一些 buffer 的。不然看起来太假了 =。=

最后是 About Me，因为我对于申请的项目而言，没有什么积累，而且没有相关领域的贡献，所以把这一项放在了最后。如果你是申请 Kubernetes，而日常是 Docker 的 contributor，那把 About Me 放在最前面是更好的选择，完全看申请而定。

一般来说这些是都要有的，还有一些其他的，社区特定的要求，这个也是要注意的。这里还有一些我认为写的比较好的 proposal：

* [Integrate Unikernel Runtime](https://docs.google.com/document/d/1Vld4j0B-wk1A1827gIc5fzWHJlzQVqcYQnCAKJwe_ZM/edit?usp=sharing)
* [Optimization of Distance Between Methods in Single Java Class](https://docs.google.com/document/d/1lWXpWhUN6cE06sjQANjWxamc_X3ddbSphTRSofChLyk/edit?usp=sharing)

感兴趣也可以看下。

### Community Bonding Period

走到这一步，离拿钱就不远了，因为 GSoC 申请比完成更难。在 Community Bonding Period，你需要跟自己的 mentor 建立联系，积极融入社区等等，但是没有量化的标准，这个就不再多说了。

### 开始写码

写码这个，不同的项目有不同的要求。有一部分项目是给开源的 repo 贡献代码，因此要走整个 review 的流程，这想必大家都比较熟悉，不再多说。但是还有一部分项目，是 standalone 的，就是自己开了个 repo，自己写，比如我申请到的 [Processing.R](https://github.com/gaocegege/Processing.R)。这就会有很多问题，这里也着重说一下对于这一类项目的建议。

首先，要明确之前 proposal 里写的 schedule 只是为了给社区信心的，事实上在开始写码之前，mentor 会跟你重新制定计划。所以如果你在 Community Bonding Period 写了很多 feature，很可能没有用，因为 mentor 说不定会给你重新制定要求。

关于 standalone 的项目，跟 mentor 以及社区其他成员的交流是很关键的。因为你的 repo 别人都是没有 watch 的，所有的变动，可能只有你和你的 mentor 知道。如何让社区里的其他人看到你的贡献，非常重要。所以尽可能多在 IRC 里跟大家分享你遇到的问题，或者你的项目中的新 feature，可能会让你感觉到自己不是玩单机游戏。

其次就是要尽早引入 CI，并且所有变动都以 PR merge 的方式进行，以保证代码质量。一个人的项目，质量很容易滑坡，CI 和 PR 可以让 mentor 对你的代码有一个很好的 review 体验，他也会更加积极一点。

最后是不要太肝。因为自己的项目，每个 PR 的生命周期都是由自己负责的，很容易就会进入疯狂开发的状态，但是记住上面说的，在开始写码之前，mentor 会跟你重新制定计划 :)

### Evaluation 与奖金发放

Evaluation 是一个双向的评估，mentor 会评估学生的工作完成度如何，学生会评估社区和 mentor 对自己的帮助是否到位，学生对社区的评估可能会影响社区明年能够参加 GSoC 以及 slots 的数量，mentor 的评估决定学生能否拿到奖金。

如果通过了 evaluation，奖金会在几天内到账。

## 注意事项与 Tips

1. **只有**学生才可以申请 GSoC。
1. 一般来说 GSoC 主页需要科学上网才能访问。
1. 时差问题是申请的时候需要注意的问题，这个需要格外注意，每年都有人错过申请。
1. 奖金的发放是通过 [Payoneer](https://www.payoneer.com/home/) 发放的，如果是非美元账户，需要支付 4% 左右的换汇费用。
1. 第一次入选 Mentoring organizations 的组织原则上只有 1 个或者 2 个 slots。

## 结语

这是一篇摸鱼作，希望能够对各位有所帮助。其实大家在选择开源社区的时候可以多问问有经验的人，尽可能选择一个友好的社区作为开始，这样会在开源的路上走的远一点。。

## 相关文章

* [Google 编程之夏(GSoC)：海量优质项目，丰厚报酬，你竟然还不知道？](https://zhuanlan.zhihu.com/p/27330699)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
