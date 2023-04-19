---
weight: 100
title: "iTerm"
---

## 1. 安装iTerm2
[https://www.macwk.com/soft/iterm2](https://www.macwk.com/soft/iterm2)  

## 2. 安装oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

## 3. 修改默认sh
```bash
chsh -s /bin/zsh
```
恢复bash: `chsh -s /bin/bash`  

## 4. 修改主题
[ohmyzsh主题列表](https://github.com/ohmyzsh/ohmyzsh/wiki/themes)  
```bash
vim ~/.zshrc
```
`ZSH_THEME=”robbyrussell”    # gallois macovsky eastwood`  
![](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/6c8468d6-8770-47fe-b850-7cfaafed6cb3/Untitled.png)  

## 5. 解决乱码问题
```bash
pip install powerline-status
git clone https://github.com/powerline/fonts.git --depth=1
cd fonts
./install.sh
cd ..
rm -rf fonts
```
iTerm2 -> Preferences -> Profiles -> Text, 在 Font 区域选中 Change Font, 选择后缀”For Powerline” 的字体来解决乱码问题  
  
## References
[https://zhuanlan.zhihu.com/p/290737828](https://zhuanlan.zhihu.com/p/290737828)  
[Downloads - iTerm2 - macOS Terminal Replacement](http://iterm2.com/downloads.html)  
[Oh My Zsh - a delightful & open source framework for Zsh](https://ohmyz.sh/)  

