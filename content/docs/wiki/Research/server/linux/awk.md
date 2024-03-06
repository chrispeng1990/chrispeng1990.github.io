---
weight: 200
title: "awk"
---

## 常用操作

### 按冒号或逗号分隔, 取第2，4，6位置的值
```bash
awk -F ':|,' '{print $2, $4, $6}' log
```

## References
[awk 命令快速入门](https://zhuanlan.zhihu.com/p/186289624)

