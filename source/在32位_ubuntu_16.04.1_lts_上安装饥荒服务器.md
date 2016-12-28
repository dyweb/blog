title: "在32位 Ubuntu 16.04.1 LTS 上安装饥荒服务器"
date: 2016-12-28 03:33:15 +0000
update: 2016-12-28 03:33:15 +0000
author: gaocegege
# NOTE: the image locate in `source` folder
# cover: "-/images/posts/example.png"
tags:
    - "饥荒"
    - "Ubuntu"
preview: "今天为东岳搭建了一个饥荒的服务器，并不是特别复杂。"

---

今天为东岳搭建了一个饥荒的服务器，并不是特别复杂。饥荒对于服务器的要求是：

```text
Internet(Upload) = 8Kbytes/player/s
Ram = around 65Mbytes/player
CPU = N/A
VCRedist_2008 (x86)
```

因此选定配置的时候要计算下，服务器的最低配置要求。因为考虑到我们的玩家数最多也就20人左右，长期在线人数能在3-4人就不错了，因此一台1核2G内存的机器就可以满足我们的要求了。

我们中的绝大多数玩家，都是在华东地区的，而只有一个美帝玩家。因此在服务器的选择上，华东节点是最合适的。在考察了包括阿里云、美团云、青云、腾讯云、Hyper.sh 在内的众多云服务提供商后，选择了最便宜的腾讯云。就流量来说，基本所有的服务商都是一个价钱，但是服务器的价格从 85 到 125 不等。Hyper.sh 因为没有华东节点，就没有关注价格。因为 steam 的 cmd 运行需要 32 位的环境，而且服务器的内存没有超过 4G，因此选择了 32位 Ubuntu 16.04.1 LTS。因为选择的云服务提供商和系统都很大众，因此在过程中并没有遇到什么坑。

## 安装 steam 和 饥荒

按照官方的文章，没什么好说的，不过为了简单，在搭建的过程中省略了创建用户的过程，直接在默认的用户目录下进行的。还有就是需要安装两个在官方教程中没有写到的东西：xfonts-75dpi 和 xfonts-100dpi，不然在运行 steamcmd.sh 的时候会报错 `Steam needs to be online to update`。

```bash
sudo apt-get install libgcc1
sudo apt-get install xfonts-75dpi xfonts-100dpi
mkdir ~/steamcmd
cd ~/steamcmd
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz
./steamcmd.sh
login anonymous
# replace <user> with your current user. if you use qcloud, ubuntu is the default username.
force_install_dir /home/<user>/steamapps/DST
app_update 343050 validate
quit
cd /home/steam/steamapps/DST/bin/
```

## 添加配置文件

至此游戏服务器的所有二进制和依赖都安装好了，接下来需要进行配置。在 `/home/<user>/.klei/DoNotStarveTogether/Cluster_1` 目录下需要建立两个文件，cluster.ini 和 cluster_token.txt。前者是对服务器的配置，后者是在饥荒的客户端游戏中生成的一个 token，猜测会用来校验玩家是否在使用正版游戏，等等。

cluster.ini 文件内容很简单：

```text
[network]
cluster_name = <cluster_name>
cluster_intention = cooperative
cluster_description = <cluster_description>
cluster_port = 10999
cluster_password = <passwd>

[misc]
console_enabled = true

[gameplay]
max_players = <max_players_num>
pvp = false
game_mode = endless
pause_when_empty = true
```

cluster_token.txt 文件的内容需要用饥荒的客户端来生成，输入 `~` 打开游戏内置的 console，输入 `TheNet:GenerateClusterToken()`，不同系统会在不同位置生成一个 token：

```text
Windows:
/My Documents/Klei/DoNotStarveTogether/cluster_token.txt

Linux:
 ~/.klei/DoNotStarveTogether/cluster_token.txt

Mac OS X:
~/Documents/Klei/DoNotStarveTogether/cluster_token.txt
```

然后将文件内容拷贝到 `/home/<user>/.klei/DoNotStarveTogether/Cluster_1/cluster_token.txt` 中就行。

## 运行

```bash
/home/<user>/steamapps/DST/bin/dontstarve_dedicated_server_nullrenderer
```

官方推荐使用 screen 来维持服务器在退出 ssh 连接后依然在运行，但你喜欢怎么做就随便了。

## Reference

* [Don’t Starve Together（饥荒）服务器搭建](https://www.nevermoe.com/?p=695)

## License

- This article is licensed under [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).
- Please contact <marketing@dongyue.io> for commerical use.
