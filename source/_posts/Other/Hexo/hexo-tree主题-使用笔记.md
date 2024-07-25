---
title: hexo-tree主题-使用笔记
date: 2021-02-28 13:59:30
tags:
---

## 先说坑点

- 刷新才可查看最新内容

可能是由于浏览器有缓存，每次打开页面都要刷新才能显示最新内容，浏览器居然不会自动把旧的内容覆盖掉？？？firefox和chrome都是这样。只好每次更新了内容就清理浏览器缓存了。firefox和chrome清理缓存的快捷键是`ctrl+shift+del`，firefox勾选`Cache`即可，chrome勾选`缓存的图片和文件`即可。如果有更方便的方式欢迎评论区发言/狗头

- gitee.io每次部署后都需要手动update才能生效。

## 使用hexo+代码托管平台搭建博客的优劣

优势：

- 可以灵活选择主题
- 博客内容本地云端同时备份，不用担心某个公司倒闭导致博客丢失

劣势：

- 代码托管平台（如gitee）可能有容量限制，导致不能随心所欲放图片
- 手机写博客及其不方便（甚至不可能？）
- 并非所见即所得，有时在编辑器里写好的markdown文档放到博客上就有点不太一样了。

## 新建代码仓库

最好建立两个代码仓库，一个存放网站，一个存放生成网站的博客源码。存放网站的代码仓库可以自动同时push到gitee和github上。博客源码的代码仓库只能手动push，所以最好只放到一个代码托管平台上（非得写脚本一起push当我没说）。由于gitee国内访问比较稳定，所以我选择把博客源码放到gitee上。

### gitee

新建一个名字同自己的用户名的仓库用来存放网站。新建一个任意名字（我的叫blog）的代码仓库用来放博客源码。

### github

新建名字为`自己用户名.github.io`的仓库。

## 安装hexo

可以用npm安装：

```shell
npm install hexo-cli -g
```

## 初始化博客

在本地新建一个`blog`空文件夹（不要clone），然后执行

```shell
hexo init
```

就初始化了目录结构。然后才能`git init`，把gitee上的remote加上去。

## 预览

```shell
hexo s -g
```

就会编译并且在本地`4000`端口开一个网站

```text
INFO  Validating config
INFO  Start processing
INFO  Hexo is running at http://localhost:4000 . Press Ctrl+C to stop.
```

在浏览器地址栏输入`http://localhost:4000`或者在终端`ctrl+左键`这个链接（如果终端支持的话）就可以预览博客了。当本地的文件改变之后，预览的博客会自动更新。

## 修改配置

在blog根目录下的`_config.yml`里可以修改title、author等配置，然后在文档的最后更改`Deployment`设置，把之前创建的gitee和github的代码仓库放上去，我的设置如下：

```yml
deploy:
  type: 'git'
  repository:
    gitee: git@gitee.com:searchstar/searchstar.git,master
    github: git@github.com:seekstar/seekstar.github.io.git,master
```

新版本github中master可能要改成main。

## 部署

先生成博客网站并部署到代码托管平台：

```shell
hexo d -g
```

会自动推送到gitee和github。

然后到github的网站仓库`用户名.github.io`里开启github pages：进入仓库设置，`Options`里往下划，可以看到`GitHub Pages`，选择branch为master（或main），然后`Save`就好了。进入`https://用户名.github.io`即可查看。

然后到gitee的网站仓库`用户名`里开启gitee pages：进入仓库，点击`Service`，然后点击里面的`Gitee Pages`，同样选择branch为master，并勾选`Enforce HTTPS`，然后点击`Update`，等一段时间即可。进入`https://用户名.gitee.io`即可查看。

`github.io`部署后等一段时间会自动更新，但是`gitee.io`每次部署都必须手动`Update`才能生效，有点恶心。

## 选择主题

默认主题不好用。<https://hexo.io/themes/>可以浏览各种主题，点击图片可以预览，点击名字可以进入主题的代码仓库。

建议使用`tree`主题，它有如下优点：

- 可以把博客以文件夹的形式组织
- 左边的索引可以收起来，防止占用屏幕空间
- 上部有`标签`和`分类`的入口，进入网站即可点击
- header随着页面往下翻可以收起来，防止占用屏幕空间

缺点也很明显：

- 手机版上`标签`和`分类`入口所在的header过短，不能智能收成一个目录，所以header不能放太多东西。
- 访问量和评论的key是博客url，若url改变则访问量和评论全部会清空。

## 更换主题

这里选择tree主题。在`themes`下执行

```shell
git clone https://github.com/wujun234/hexo-theme-tree tree
cd tree
```

然后再在`_config.yml`里把默认的

```yml
theme: landscape
```

改成

```yml
theme: tree
```

然后预览一下就可以看到主题换了。

在blog根目录新建`_config.tree.yml`，放tree theme的配置文件。主题的配置说明详见`themes/tree/README.md`。下面介绍一些常用的。

## 修改header

通过`_config.tree.yml`里的`links`配置：

```yaml
links:
  # 改成自己的github链接
  github: https://github.com/wujun234
  # 自定义链接
  custom:
    - name: UidGenerator
      URL: https://github.com/wujun234/uid-generator-spring-boot-starter
```

默认有一个作者自己的项目`UidGenerator`，删掉它或者换成自己的项目。项目链接可以多放几个，但是由于手机上header长度有限，不宜过多。实际上我觉得一个都不放比较好，可以全部塞进后面提到的about页。

## 开启标签

在`_config.tree.yml`开启标签：

```yml
tags: true
```

在`source`目录下执行

```shell
hexo new page "tags"
```

然后编辑`source/tags/index.md`，在`date`后面加上

```yml
type: "tags"
layout: "tags"
```

如

```md
---
title: tags
date: 2021-02-26 16:36:55
type: "tags"
layout: "tags"
---
```

然后预览一下，就能看到右上角多了`标签`或者`Tags`。

分类就不开了，因为tree主题的文件夹自带了分类功能。不开分类有助于节约header的空间。

## 开启评论，统计访问量

已经默认开启了“不蒜子”，可以统计PV(Page View)和UV(Unique Visitor)并在页面下方显示，但是评论和单篇文章访问量却不适合用“不蒜子”。tree主题使用`leancloud`来存储评论以及访问量。

注册一下`leancloud`：<https://www.leancloud.cn/>
点击免费试用，然后注册就好了。有一定的免费额度。

登陆进去之后可以切换中文，然后`创建应用`，应用名称随便，我的是`blog`，类别选`开发版`，创建好了之后点进去，点击左边`设置`里的`应用keys`，把AppID和AppKey放到`_config.tree.yml`里，并且把`enableComment`和`enableCounter`都设置成`true`

```yml
# valine 
valine:
    # 评论
    enableComment: true 
    # 阅读量
    enableCounter: true
    # valine appID
    appID: xxxxxxxxxxxxxxxxxxxxxxxx-xxxxxxxx
    # valine appKey
    appKey: xxxxxxxxxxxxxxxxxxxxxxxx
    placeholder: 请输入评论
    avatar: retro
```

然后预览一下，可以看到每篇文章下面多出了评论输入框，文章开头多了访问量

注意，评论和访问量都是以博客的url作为key的，所以如果博客的url变了（如重命名），那评论和访问量都会清空。要是可以在创建博文的时候生成一个类似uuid的东西，然后以uuid作为key就好了（我为什么这么菜）。

## 邮件提醒

官方文档：<https://valine.js.org/notify.html>

但是官方文档里推荐的<https://github.com/zhaojun1998/Valine-Admin>看起来已经无人维护了，部署会出错：

```text
build failed: npm WARN deprecated request@2.88.2: request has been deprecated, see https://github.com/request/request/issues/3142 npm WARN deprecated superagent@3.8.3: Please upgrade to v9.0.0+ as we have fixed a public vulnerability with formidable dependency. Note that v9.0.0+ requires Node.js v14.18.0+. See https://github.com/ladjs/superagent/pull/1800 for insight. This project is supported and maintained by the team at Forward Email @ https://forwardemail.net npm WARN deprecated formidable@1
```

而且这个repo连issue都没有。

修复方法：<https://github.com/DesertsP/Valine-Admin/issues/151>

也可以直接用这个：<https://github.com/Druadach/Valine-Admin>

按照readme里的步骤部署即可。

环境变量里可以指定`TO_EMAIL`，提醒邮件就会发送给这个邮箱。如果不指定`TO_EMAIL`，提醒邮件是发送给`SMTP_USER`。

## 修改底部版权开始年份

`_config.tree.yml`里的`siteStartYear: 2019`修改成你想要的年份。结束年份会自己计算出来。

## 更改网站图标

将自己的网站图标（文件名不要跟默认的`favicon.ico`相同）放进`source`文件夹里。假如文件名是`seekstar.ico`，那么就可以通过`https://博客网站/seekstar.ico`访问到这个图标。然后更改`_config.tree.yml`：

```yaml
# 改成自己的图标文件名，比如 /seekstar.ico
favicon: /favicon.ico
```

即可让网站使用新的网站图标。

## 将渲染器更换为[hexo-renderer-pandoc](https://github.com/hexojs/hexo-renderer-pandoc)

默认的渲染器是`hexo-renderer-marked`，没有语法高亮，而且有BUG，行内代码有时候会被处理成行间代码，然后全乱了。所以需要更换渲染器。[hexo-renderer-markdown-it](https://github.com/hexojs/hexo-renderer-markdown-it)比较流行，但是不支持Latex风格的数学公式。所以这里把渲染器换成[hexo-renderer-pandoc](https://github.com/hexojs/hexo-renderer-pandoc)：

```shell
sudo apt install -y pandoc

npm uninstall hexo-renderer-marked
npm install hexo-renderer-pandoc --save
```

更换渲染器之后要在`_config.yml`中把默认的highlight关掉，才能使用新的渲染器提供的highlight：

```yml
highlight:
  enable: false
```

注意这里要把之前的预览`ctrl+c`关掉，然后重新`hexo g && hexo s`才能生效。

然后就可以开启对Latex风格的公式的支持了：{% post_link Other/Hexo/'Hexo支持Latex风格的公式编辑' %}

## 写博客

在项目根目录执行

```shell
hexo new '博客标题'
```

会在`source/_posts`下生成`博客标题.md`。
用你喜欢的工具编辑之（例如vscode），然后预览一下，如果没什么问题的话就`hexo d -g`把它部署到gitee和github上。

最后记得还要`git push`博客源码到代码仓库里，不然换了一台机器博客源码就丢失了。

## 换一台机器写博客

先安装依赖：

```shell
sudo apt install -y pandoc
npm install hexo-cli -g
pip3 install panflute
```

然后把gitee上的博客源码仓库clone下来，再把网站的仓库clone到源码仓库的`.deploy_git`下。然后`npm install`，然后就可以正常`hexo g && hexo s`预览和`hexo d -g`部署了。比如我的：

```shell
# 源码
git clone --recursive git@gitee.com:searchstar/blog.git
cd blog
# 网站
git clone git@github.com:seekstar/seekstar.github.io.git .deploy_git
npm install
```

## 上传图片

<https://seekstar.github.io/2021/11/16/hexo%E6%8F%92%E5%85%A5%E5%9B%BE%E7%89%87/>

## 让文章的URL中不含目录

<https://seekstar.github.io/2021/11/16/hexo-tree%E4%B8%BB%E9%A2%98%E8%AE%A9%E6%96%87%E7%AB%A0%E7%9A%84url%E4%B8%AD%E4%B8%8D%E5%90%AB%E7%9B%AE%E5%BD%95/>

## 升级

### 升级某个包的版本

以hexo为例：

```shell
npm i hexo@latest
hexo --version
```

### 检查更新

```shell
npm outdated
```

或者用`npm-check-updates`:

```shell
npm i -g npm-check-updates
ncu
```

### 升级全部

```shell
npm i -g npm-check-updates
ncu -u
npm i
```

来源：<https://www.freecodecamp.org/news/how-to-update-npm-dependencies/>

## 其他

### 折叠部分文字

[Hexo+Github博客：如何折叠(显示/隐藏)部分文字](https://blog.csdn.net/qq_36408085/article/details/104323711)

<https://github.com/fletchto99/hexo-sliding-spoiler>

### 保留代码块中的tab

```yaml
pandoc:
  extra:
    - preserve-tabs:  # note this colon!!
```

然后`hexo clean && hexo g`使其生效。

默认tab宽度是8。可以在`themes/tree/source/css/main.css`里改成4：

```css
pre{
	tab-size: 4;
}
```

来源：<https://matrix4f.com/Web/FrontEnd/tabsize/>

如果发现即使清了cache tab宽度仍然是4的话，检查`public/css/main.css`是不是新版本，如果不是的话把`public`文件夹删了重新生成：

```shell
rm -r public
hexo d -g
```

### 标题锚点

<https://github.com/seekstar/hexo-pandoc-header-anchor>

通过锚点可以得到指向标题的URL，例如：<https://seekstar.github.io/2022/03/10/a-collection-of-matrix-groups/#matrix>

### 脚注

<https://github.com/kchen0x/hexo-reference>
