---
weight: 400
title: "split"
---

## 常用操作

### 将文件按行分隔
```bash
# 查看文件总行数
wc -l filename
# 将文件分割成多个文件, 每个文件100行, 分割文件以filenameprefix_为前缀, 序号部分为aa、ab、ac..依次
split -l 100 filename filenameprefix_
```
```bash
> ls -l
总用量 36K
-rw-r--r-- 1 root root  10K 9月  30 11:46 filename
-rw-r--r-- 1 root root 2.0K 9月  30 11:54 filenameprefix_aa
-rw-r--r-- 1 root root 2.0K 9月  30 11:54 filenameprefix_ab
-rw-r--r-- 1 root root 2.0K 9月  30 11:54 filenameprefix_ac
-rw-r--r-- 1 root root 2.0K 9月  30 11:54 filenameprefix_ad
```

## References
[Linux下如何切割与合并大文件](https://zhuanlan.zhihu.com/p/453640810)  

