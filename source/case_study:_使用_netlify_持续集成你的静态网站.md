title: "Case Study: 使用 Netlify 持续集成你的静态网站"
date: 2017-11-26 06:04:56 +0000
update: 2017-11-26 06:04:56 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "TODO: write your tag here"
preview: "TODO: write your blog abstract here"

---

[Netlify]: https://www.netlify.com/
[Travis CI]: https://travis-ci.org/

现在有越来越多的开发者选择把自己的博客以静态网站的方式托管在 GitHub 上, 这样的方式只需要一个域名就可以通过诸如 [Jekyll](https://jekyllrb.com/), [Hexo](https://hexo.io/), [纸小墨](http://www.chole.io/) 等等现有的静态博客生成工具, 非常便捷地搭建出一个样式美观的静态博客.

目前传统的软件项目, 可以通过 [Travis CI][] 等等工具来进行编译, 测试等等持续集成任务, 但是对于一个静态网站来说, 其最主要的产物是 HTML 文件. 而主流的持续集成工具都不支持对静态的页面进行构建的预览. 这篇文章主要介绍了 [Netlify][], 一个可以用来做静态网站的持续集成与持续部署的工具. 通过 [Netlify][], 用户可以非常简单地为其静态网站项目引入持续集成, 并且允许其他成员对静态网站进行 UI 层面的 review.

## 需求介绍

[东岳团队博客](http://blog.dongyueweb.com/) 是一个使用[纸小墨](http://www.chole.io/)构建的静态博客网站, 其托管在 [github.com/dyweb/blog](https://github.com/dyweb/blog) 下. 因为我们的博客采取投稿制, 每个项目成员都可以为这个博客进行投稿, 所以对于投稿的审核是一个非常重要的需求.

目前我们的投稿是以 Pull Request 的方式进行, 作者会首先提交自己的文章, 这是以 Markdown 的格式书写的. 然后会基于 Markdown 文件, 构建出对应的 HTML 文件并加入到 docs/ 目录下. 因此我们对于投稿的审核是在 Pull Request 下进行的.审核包括但不限于对博客样式是否被新的投稿破坏, 投稿内容是否贴合博客方向, 有无 typo 等等. 

而因为在 Pull Request 中, 我们只能看到所有文本文件的变动, 而看不到变动后的博客页面. 这在之前只能在文章被合并后, 再次访问[东岳团队博客](http://blog.dongyueweb.com/), 才可以进行效果的审核, 而这时文章已经是合并状态了, 再次修改需要提交新的 Pull Request 才能继续, 这样无疑延长了审核的周期.

因此我们需要一个工具, 可以帮助我们为每个 Pull Request 构建出静态网站, 并且是允许所有成员都可以访问的.

## 相关工作

[Travis CI][] 是一个非常成熟的持续集成工具, 通过它, 用户可以执行自定义的脚本任务, 测试等等. 在之前我们使用它来确认我们的代码是可以完成构建出静态网站这一步操作的. 但是 [Travis CI][] 存在一些问题, 它不能为每个 Pull Request 构建出静态网站供我们审核, 而只能简单地返回构建的成功与否, 这个信息对我们而言是不充分的. 而其他此类的服务也往往具有这个问题.

## 使用 Netlify 进行静态网站持续集成

[Netlify][] 对自己的描述是:

> Netlify is a unified platform that automates your code to create high-performant, easily maintainable sites and web apps.

[Netlify][] 与 [Travis CI][] 等等都是持续集成工具, 但是它更加关注前端, 或者说网站或者 web app 的持续集成与持续部署, 这也是它与其他持续集成工具最大的区别. 我们目前对于 [Netlify][] 的使用也非常简单, 但是这是其他持续集成工具没有的.

为了能够在每个 Pull Request 中看到新的博客文章预览, 我们需要在 [Netlify][] 中为我们的 repository 做一些设置. 在我们的使用中, 设置过程非常地简单:

- 为 repository 启用 Netlify
- 设置发布目录为 docs/

首先最重要的是为 repository 启用 [Netlify][], 这一部分与其他持续集成工具并无二致. 这一环节最主要的是让 [Netlify][] 在 GitHub 中建立 web hook, 使得它可以监听到整个 repository 的事件. 当然这是自动的, 对于用户而言是不感知的. 随后 [Netlify][] 会要求用户去设置构建的命令以及发布的目录.

<figure>
	<img src="http://gaocegege.com/Blog/images/netlify/start.png" alt="在 Netlify 中启用功能" height="500" width="500">
</figure>

对于我们的博客来说, 因为我们的博客会被编译好放置在 docs/ 目录下, 因此不需要 [Netlify][] 为我们进行构建, 如果你的项目并不是这样操作的, 比如只是有源文件而没有提交构建后的静态网站, 那你可以利用它的这一功能进行远端的构建. [Netlify][] 默认支持 [Jekyll](https://jekyllrb.com/) 等等静态博客生成工具的命令, 因此可以满足绝大多数的应用场景.

<figure>
	<img src="http://gaocegege.com/Blog/images/netlify/netlify.png" alt="使用" height="500" width="500">
</figure>

在配置结束后, 就可以利用 [Netlify][] 来进行持续集成了. 在大多数情况下, 用户甚至不需要像 [Travis CI][] 那样在 repository 里放置配置文件, 直接通过网页操作来搭建起对一个 repository 的持续集成.

每当一个新的 Pull Request 被创建的时候, [Netlify][] 会为这个请求运行一个构建任务, 这个任务最终会生成一个预览, 通过 URL 可以访问到基于这一 Pull Request 的构建结果.

<figure>
	<img src="http://gaocegege.com/Blog/images/netlify/github.png" alt="使用" height="500" width="500">
</figure>

而 URL 是可以自定义的, 比如 [https://deploy-preview-26--blog-dongyueweb.netlify.com](https://deploy-preview-26--blog-dongyueweb.netlify.com/%E5%B0%8F%E8%AE%AE%E5%88%86%E5%B8%83%E5%BC%8F%E7%B3%BB%E7%BB%9F%E7%9A%84%E4%B8%80%E8%87%B4%E6%80%A7%E6%A8%A1%E5%9E%8B). 不同 Pull Request 会有不同的 URL, 因此基于此还可以去做 Split Testing. 目前 [Netlify][] 支持两个 branch 之间的 Split Testing, 但还是 beta 阶段, 我们没有进行过尝试.

如此以来, 我们可以利用 [Netlify][] 的预览功能, 来对 Pull Request 进行内容和格式的审核. [Netlify][] 本身有更多的功能, 它的愿景是为前端引入持续集成. 限于篇幅, 停笔于此.

## 附录

目前我们知道的使用 [Netlify][] 服务的网站有:

- [统计之都](https://github.com/cosname/cosx.org)
- [东岳团队博客](http://blog.dongyueweb.com/)
- [Processing.R 网站](https://github.com/processing-r/processing-r.github.io)
- [headlesscms.org](https://github.com/netlify/headlesscms.org)

PS: 这是一篇免费的安利文, 我们与 [Netlify][] 利益不相关

欢迎关注我们的 [GitHub](https://github.com/dyweb) 以及[博客](http://blog.dongyueweb.com/) :)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
