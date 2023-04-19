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

## 常见错误
### 1. git RPC failed; HTTP 413 curl 22 The requested URL returned error: 413 Request Entity Too Large
```bash
git config http.postBuffer 524288000
```

## References
[修改git所有commit中的用户名和email](https://www.cnblogs.com/fb010001/p/16785452.html)  


