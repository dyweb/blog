title: "安利时间: Processing + R = ?"
date: 2017-09-10 14:07:05 +0000
update: 2017-09-10 14:07:05 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "Processing"
    - "R 语言"
    - "Google Summer of Code"
preview: "Processing.R 是我在 Jeremy Douglass 指导下，为 Processing 实现的一个 R 语言模式，这是一个 Google Summer of Code 2017 项目。这篇文章会讲一讲它的应用，以及实现。"

---

[Processing.R](https://github.com/gaocegege/Processing.R) 是我在 [Jeremy Douglass](http://jeremydouglass.com/) 指导下，为 [Processing](https://processing.org/) 实现的一个 R 语言模式，这是一个 [Google Summer of Code 2017](https://summerofcode.withgoogle.com/projects/) 项目。这篇文章会讲一讲它的应用，以及实现。

至于这篇文章的受众，我也不是很清楚 ┑(￣Д ￣)┍ 爱看就看看吧 =。=

## Processing 是什么

这里有一篇文章：[Processing是干嘛的？艺术家学编程能做什么？](https://zhuanlan.zhihu.com/p/25432507)，我个人觉得介绍的很到位。我这里就再稍微说一下，我对 Processing 的看法。

Processing 从功能上而言，是一个做 creative coding 的编程语言，Processing 的 IDE 也直接被称作 Processing Development Environment（缩写 PDE）。

从一个软件工程师的角度来讲，Processing 跟传统的编程语言最大的不同在于，一个完整的 Processing 程序（在 Processing 的语境中，完整的程序被称作 Sketch），一定会有一个图形化的输出。这个输出可以是 2D 图形，3D 图形，也可以是动画，等等。Processing 本身是用 Java 实现了一个编译器，其本身的语法也是跟 Java 几乎一致，因此可以把它当做 Java 的一个 DSL（对语言学不是很懂啦）。Processing 为了使得用户能够更好地进行图形化编程，实现了很多简练的函数，使得寥寥数行就可以实现一个非常简单的图形化应用。

从一个艺术家的角度来讲，因为我不是一个艺术家，我也不知道怎么讲，所以就随便讲讲。绝大多数艺术家，在我看来，在写代码的能力上可能稍微有所欠缺（希望没有冒犯到你）。因此，Processing 对于他们而言，最吸引人的点应该是在于其简单易用。

### 一个简单的例子

这里以一个非常简单的例子介绍 Processing 可以做的事情。

```
void setup() {
  size(640, 360);
  background(102);
}

void draw() {
  // Call the variableEllipse() method and send it the
  // parameters for the current mouse position
  // and the previous mouse position
  variableEllipse(mouseX, mouseY, pmouseX, pmouseY);
}


// The simple method variableEllipse() was created specifically 
// for this program. It calculates the speed of the mouse
// and draws a small ellipse if the mouse is moving slowly
// and draws a large ellipse if the mouse is moving quickly 

void variableEllipse(int x, int y, int px, int py) {
  float speed = abs(x-px) + abs(y-py);
  stroke(speed);
  ellipse(x, y, speed, speed);
}
```

先讲效果，这段代码会根据鼠标的位置和鼠标移动的速度在画布上不停的画圆。

在代码中可以看到三个函数，其中 `setup` 和 `draw` 是内置函数，就像是传统编程语言中的 main 函数一样，是整个程序的入口。`setup` 会进行一些设定，比如画布的大小，以及背景颜色。而每当需要绘制新的一帧时，Processing 就会调用 `draw` 函数。因此如果 `draw` 函数每次调用结果都一样，那就是一个静态的图形，如果是不一样的，得到的就是动态的效果。`variableEllipse` 是负责绘制圆形的函数。其参数是鼠标的当前坐标和上一帧的坐标，它会根据坐标计算速度，随后去绘制圆形。如果你感兴趣的话，可以去 [Examples - Pattern](https://processing.org/examples/pattern.html) 亲自试试效果 :)

## Processing.R 是什么

之前提到 Processing 是基于 Java 的 DSL，而且是运行在 JVM 上的。而诸如 Python, Ruby, R 等等语言，也都有在 JVM 上的实现，因此 Processing 也可以通过切换模式的方式来使用其他语言来写 Sketch 的逻辑。

而 [Processing.R](https://github.com/gaocegege/Processing.R)，就是利用 [renjin](http://www.renjin.org/) 实现的 Processing 在 R 语言上的支持。

<figure>
	<img src="https://github.com/gaocegege/Processing.R/raw/master/raw-docs/img/editor.png" alt="Processing.R" width="500">
</figure>

<figure>
	<img src="https://github.com/gaocegege/Processing.R/raw/master/raw-docs/img/demo.gif" alt="Processing.R Demo" width="200">
</figure>

Processing 在 R 语言上的实现，依赖了一个 JVM 上的 R 解释器，每当 Processing 需要调用 draw 等等函数时，都会转而执行 R 代码中相对的定义。目前，Processing.R 支持了绝大多数 Processing 的语法，与此同时支持 Processing 自身众多的库以及 R 语言的包（两者只测试了部分）。这使得 Processing.R 能够在拥有便捷的图形化能力的同时，使用 R 语言中各种方便的包。

## 下载与安装

Processing 本身下载和安装都特别简单，而且是多平台的，在[此处](https://processing.org/download/)即可找到适合你的版本。而在 Processing 的 Contribution Manager 中的 Modes 一栏中，可以下载 Processing.R。随后在主界面右上角的下拉框中选择 R 即可。

<figure>
	<img src="https://user-images.githubusercontent.com/5100735/29493417-df2b614e-85c7-11e7-98c5-d9f20cf780a4.PNG" alt="下载与使用" width="500">
</figure>

目前 Processing.R 仍然会积极地进行维护，如果你感兴趣，可以与我联系，还有很多坑等着呢，而且也可以以这个项目为蓝本，拿去申请下一年的 Google Summer of Code，总而言之欢迎各种形式的贡献。原本想做个标题党，发现自己没有 UC 小编的能力，只好找了这么一个不明所以的标题，谢谢你还不辞辛劳地点进来看看 :)

## 许可协议

- 本文遵守[创作共享CC BY-NC-SA 3.0协议](https://creativecommons.org/licenses/by-nc-sa/3.0/cn/)
- 网络平台转载请联系 <marketing@dongyue.io>
