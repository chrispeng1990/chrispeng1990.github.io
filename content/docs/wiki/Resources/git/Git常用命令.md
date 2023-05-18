---
weight: 100
title: "Git常用命令"
---

## 1. git proxy
```bash
git config --global http.proxy http://10.95.26.17:8888/
git clone http://user:pass@10.88.88.100:8088/morii/morii-core.git
git config --local http.proxy http://10.95.26.17:8888/
git config --global --unset http.proxy
```

## 2.git mirror(克隆远程库，推送到本地服务器)
```bash
git clone --bare ${远程仓库URL}
git push --mirror git@${另一个仓库域名}:${group}/${repository}
```

## 3. git统计user的代码量
```bash
git log --author="username" --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -
```

## 4. 回滚已merge的master代码
```bash
git log
git reset --soft 43dc0de914173a1a8793a7eac31dbb26057bbee4
git push origin master --force
```

## 5. 修改仓库所有commit的用户名和email
```bash
git clone --bare https://github.com/user/repo.git
cd repo.git
```
  
修改OLD_EMAIL、CORRECT_NAME、CORRECT_EMAIL三个变量的值并执行如下脚本:  
```bash
#!/bin/sh
git filter-branch --env-filter '
OLD_EMAIL="your-old-email@example.com"
CORRECT_NAME="Your Correct Name"
CORRECT_EMAIL="your-correct-email@example.com"
if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi
if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]
then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi
' --tag-name-filter cat -- --branches --tags
```
  
把变更 push 到 Github  
```bash
git push --force --tags origin 'refs/heads/*'
```

## 6. 修改历史commit信息
1. 查看历史提交记录  
```bash
git log
```
![](/images/v2-5c863a404dcf6facf17906e9e36f4dc0_b.webp)  

2. 找到要修改的commit的上一条commit id  
```bash
git rebase -i {prevCommitId}
```
![](/images/v2-447b53202cdf075fff6fefc84273f57d_b.webp)  

3. 按 'O' 键进入编辑模式, 将要修改的commit前标记改为 reword  
![](/images/v2-f1952404459f8ae3e9818d7c8de76a1e_b.webp)  
- pick：保留该 commit  
- reword：保留该 commit，但我需要修改该commit的 Message  
- edit：保留该 commit, 但我要停下来修改该提交(包括修改文件)  
- squash：将该 commit 和前一个 commit 合并  
- fixup：将该 commit 和前一个 commit 合并，但我不要保留该提交的注释信息  
- exec：执行 shell 命令  
- drop：丢弃这个 commit  

4. 修改完成后按 'Esc' 后输入 ':wq' 退出commit历史界面, 进入对应commit编辑界面  
![](/images/v2-a08c6c4adff59d4917987defc6f8a2e4_b.webp)  
![](/images/v2-ee98a4f8a6399a24aebb77fe28a81e47_b.webp)  

5. 输入 ':wq' 保存变更  
![](/images/v2-6b58d564d49be4d3c8b2d027f3c070d5_b.png)  

6. 查看修改记录  
```bash
git log
```
![](/images/v2-37513327a616454e79cd9b0f8eb6a018_b.webp)  

7. 修改提交到远程  
```bash
git push origin {branchName} -f 
```

## 常见错误
### 1. git RPC failed; HTTP 413 curl 22 The requested URL returned error: 413 Request Entity Too Large
```bash
git config http.postBuffer 524288000
```

## References
[修改git所有commit中的用户名和email](https://www.cnblogs.com/fb010001/p/16785452.html)  
[Git 如何修改历史 Commit message](https://www.zhihu.com/tardis/bd/art/401811121?source_id=1001)  

