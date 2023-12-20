---
weight: 100
title: "Hugo Wiki Example"
---

## 1. GitHub Pages
### 1.1. 创建Pages仓库
仓库名必须为 ${username}.github.io  
如果设置为其他名称, 最终访问URL为 https://${username}.github.io/${otherName}.github.io  
![](/images/202304171015304.png)  

### 1.2. 设置Github Pages
分支仅允许选择根分支;  
根目录可以设置为 / 或 /docs, 默认URL会访问根目录中的 index.html  
![](/images/202304171033187.png)  

## 2. Hugo
流行的静态站点框架有以下几个:  
Jekyll (基于 Ruby 容易上手) https://www.jekyll.com.cn/docs/home/  
Hexo (基于 Node.js 容易上手) https://hexo.io/docs/  
Hugo (基于 Go) https://gohugo.io/documentation/  

### 2.1. 安装hogo
MacOSX:  
```bash
brew install hugo
hugo version
```
输出 `v0.111.3+extended darwin/amd64 BuildDate=unknown` 证明安装成功.  
[其他系统安装方式参考](https://gohugo.io/installation/)  
### 2.2. 创建Hugo项目
```bash
hugo new site wikis
cd wikis
```
生成的项目结构如下:  
```
├── archetypes      使用Hugo New命令创建Hugo中的新文件会按照里面的模版生成
│   └── default.md
├── config.toml     主要配置文件
├── content         存放文章的位置
├── data    
├── layouts         模版文件
├── static          静态文件
└── theme           主题文件
└── public          生成的部署文件目录
```

### 2.3. Hugo Theme - hugo-book
在Hugo主题仓库中选取合适的样式, [Hugo Theme](https://themes.gohugo.io/)  
本文以hugo-book为例, [Hugo Theme hugo-book](https://themes.gohugo.io/themes/hugo-book/), [Github/hugo-book](https://github.com/alex-shpak/hugo-book)  

#### 2.3.1. 安装 hogo-book 主题
```bash
cd ${username}.github.io/theme
git clone https://github.com/alex-shpak/hugo-book.git
```
#### 2.3.2. 配置默认主题
```bash
vim ./config.toml
```
```
theme = ["hugo-book"]
```

### 2.4. 本地测试
配置了默认主题后, 也可不指定 --theme 参数.  
```bash
hugo server --theme=hugo-book
```

### 2.5. 编译
生成的静态网页在 ./public 目录下.  
```bash
hugo -t hugo-book
```

### 2.6. 部署至Github Pages
将 ./public 目录下文件拷贝至 ./docs 中.  
> 若 1.2. 中将 Github Pages 设置为根目录, 需要将 ./public 下文件拷贝到根目录下.
```bash
git add .
git commit -m "deploy"
git push origin master
```

## 3. Github 图床工具
需要vpn才可访问 raw.githubusercontent.com, jsdelivr CDN也已被屏蔽  
使用hugo本地目录作为资源目录, /static  
  
## 其他主题
### 1. 改版hugobook
https://github.com/idealvin/hugo-book/  
eg: https://coostdocs.gitee.io/cn/about/co/  
  

## 常见问题
1. [hugo-book 同时支持中英文搜索](https://blog.csdn.net/weixin_42425959/article/details/126849231)  


## 其他产品
### 1. hexo
[Github Page 个人主页——Hexo博客](https://blog.csdn.net/m0_47520749/article/details/124897399)  
[Hexo Theme Lib](https://hexo.io/themes/)  
[Hexo Theme Fluid](https://hexo.fluid-dev.com/posts/hexo-nodeppt/)  


## References
[Hugo](https://gohugo.io/)  
[Hugo Theme](https://themes.gohugo.io/)  
[Hugo Theme hugo-book](https://themes.gohugo.io/themes/hugo-book/)  
[如何使用Hugo+Github搭建一个博客](https://zhuanlan.zhihu.com/p/454369465)  
[使用PicGo上传图片到自己的图床](https://zhuanlan.zhihu.com/p/582263572)  
