title: "Ayi"
date: 2016-12-24 08:18:08 +0000
update: 2016-12-24 08:18:08 +0000
author: at15
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - golang
preview: Ayi 跨平台的工具库

---

## 简介

[Ayi](https://github.com/dyweb/Ayi) 是一个跨平台的命令行工具，类似于[busybox](https://busybox.net/about.html)。
开始于 2015 年 7 月。主要目的是为了方便配置环境和解决各种由于配置环境导致的问题，比如:

> - 我这里跑的好好的，怎么到了你那(服务器上)就挂了
> - 我用 Mac 自带的 PHP 和 Apache 就挺好，我不用 Vagrant 和 Nginx
> - 我就想用 Windows 下的一键安装包

考虑到没钱给大家每人配个 Mac，以及东岳的男女比例。
我们需要一个跨平台的配置环境和收集环境信息的工具，用于**快速**的解决上述问题。

## 技术选型

在选择 Ayi 使用的技术时主要考虑的是以下几个问题

- 跨平台
- 可维护性
- 对于东岳其他项目的帮助

<!-- TODO:找不到是哪个 issue 了，倒是找到了 commit https://github.com/dyweb/Ayi/commit/3a96921ccb6b5edb7c294e2a1eab2b9e63cc130b -->
最开始和咩的考虑是使用 shell 来进行操作， 但是 shell 的问题在于很难维护，基本不可能测试。
东岳 shell 用的很少，并且 shell 对于其他项目帮助十分有限。

之后考虑到 PHP, python, java 都需要运行时，C/C++ 写起来太累， Rust 没人会 (那会还没有 Ivan 和 Codewarm)，
就选择了 Golang，当时版本是 1.5。

Golang 的主要优点是

- 跨平台 & 交叉编译
- 简洁的包管理
- 性能好，可以用来改进东岳现有的纯 PHP 服务端体系
- 一个活跃的社区，PHP 沉浸在 CMS 和抄 Rails 中不能自拔，JS 日新月异
- Google 老爹

## 主要问题

- 人太少，基本只有 @at15 (我) 一个人
- 需求不是很明确
- 对 Golang 语言本身很不熟悉
- Golang 的一些工具链不是很成熟，比如不支持依赖的 vendor 。

但是由于项目拖了很长时间，后面三个问题基本都解决了

- 主要需求是
  - 生成器
  - 环境检查
  - [git 操作的简化](https://github.com/dyweb/Ayi/tree/master/app/git)
  - [makefile 类似的自动化工具](https://github.com/dyweb/Ayi/tree/master/util/runner)
  - [静态 web 服务器](https://github.com/dyweb/Ayi/tree/master/app/web)
  - [进程管理](https://github.com/dyweb/Ayi/pull/64)
  - waka time 服务器
  - 文件传输
- go 的版本从 1.5 跳到了 1.7。原生支持 vendor 并且有了很多更好的依赖管理工具，比如 [glide](https://github.com/Masterminds/glide)

第一个问题的话，基本无解，目前东岳经常写 Golang 的人好像只有我和策策。策策有空就要去陪妹子，自然不可能陪我来填坑。
(要有妹子的话我还会去填坑么?)

## 实现的功能

### Git 操作的简化

前提是：你习惯使用 Golang 的 workspace，有关 workspace 我在以前东岳的讲座中[有提到](http://dongyueweb.com/course/web/2016_Spring/environment/slide.html#/4) (btw: 按方向键`下`而不是`右`)。我个人的工作区是这样的 (`cd ~/workspace && tree -L 4`)。

````
├── bin
│   ├── Ayi
│   ├── glide
│   └── ink
├── pkg
│   └── linux_amd64
│       └── github.com
│           └── dyweb
└── src
    └── github.com
        ├── at15
        │   └── at15.github.io
        ├── dyweb
        │   ├── Ayi
        │   └── blog
        └── xephonhq
            └── xephon-b
````

当使用 `git clone` 时后面必须跟完整的 remote 地址，并且默认 clone 到当前文件夹下，而使用
`Ayi git clone` 地址可以是浏览器地址，并且根据配置文件，可以支持非默认端口的 ssh，比如东岳的 GitLab。
从下面的输出可以看到 `Ayi git clone github.com/at15/at15.gihub.io` 被展开成了 `git clone git@github.com:at15/at15.github.io.git /home/at15/workspace/src/github.com/at15/at15.github.io`。

````
at15@pc4038:~/workspace|⇒  Ayi git clone github.com/at15/at15.github.io
INFO[0000] git clone git@github.com:at15/at15.github.io.git /home/at15/workspace/src/github.com/at15/at15.github.io pkg=a.a.git
Cloning into '/home/at15/workspace/src/github.com/at15/at15.github.io'...
remote: Counting objects: 435, done.
remote: Total 435 (delta 0), reused 0 (delta 0), pack-reused 435
Receiving objects: 100% (435/435), 3.56 MiB | 1.64 MiB/s, done.
Resolving deltas: 100% (234/234), done.
Checking connectivity... done.
INFO[0002] Sucessfully cloned to: /home/at15/workspace/src/github.com/at15/at15.github.io pkg=a.cmd
````

btw: `Ayi` 的 log 组件看上去很像 [logrus](https://github.com/sirupsen/logrus)，但其实是[自己的轮子](https://github.com/dyweb/Ayi/pull/60)

### 自动化

自动化部分很类似 `npm run`，但是主要有以下区别

- 使用 yaml 而不是 json, json 不支持注释，而且即使使用支持注释的 parser，编辑器也会有提示
- 支持一个指令对应一系列命令, 类似 Travis 等 CI 的配置文件

````
debug: true
dep-install:
    - go get github.com/at15/go.rice/rice
    - go get github.com/mitchellh/gox
    - glide install
install:
    - go build -o Ayi
    - rice append -i github.com/dyweb/Ayi/app/web --exec Ayi
    - sh -c "mv Ayi $GOPATH/bin/Ayi"
test:
    - go install
    - sh -c "go test -v -cover $(glide novendor)"
scripts:
    build: gox -output="build/Ayi_{{.OS}}_{{.Arch}}"
````

内置指令如`install`, `test` 跟 `Ayi run <script-name>` 都是使用 `util/runner`。
目前准备把 runner 做成一个通用的 package，因此[又在重构](https://github.com/dyweb/Ayi/pull/64)。

## 开发人员

[GitHub 传送门](https://github.com/dyweb/Ayi/graphs/contributors)

- 咩在项目开始时提交了一些 shell 脚本，但是由于转到了 Golang 以及咩一向很忙，遂弃婶
- @kdplus (丘) 参与过 `Ayi check` 的开发，不过那时我 Golang 菜的抠脚，导致丘也在划水。
- @gaocegege (策策) 因为周报的功能，参与过一段时间的开发，
引入了`Godep` 交叉编译，不过最后周报的功能并没有投入实用。


## 总结

- 等有钱了，给大家都配 MBP


## 杂项

- 使用 `git log -reverse` 可以反过来看log, 可以用来找第一个提交。
- shell 在 windows 下基本不会有问题，因为为了使用 git，东岳所有的 windows 用户都安装了
msysgit (现在叫 git for windows)，它自带了 bash 和一些基本的工具。
- 周报的功能作为 MOS 的一个项目交给了 @codeworm96, 进度见[这个issue](https://github.com/dyweb/mos/issues/1)
- [所有带 `backlog` 标签的 issue](https://github.com/dyweb/Ayi/issues?q=is%3Aissue+label%3Abacklog+is%3Aclosed)

第一个提交
````
commit 19858fe3958317da08dc512116c58acbd82b2a35
Author: At15 <at15@outlook.com>
Date:   Sun Jul 26 13:24:38 2015 +0800

    Initial commit
````

## 更新

## 引用

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
