---
weight: 300
title: "Jar包操作"
---

## 解压
```bash
jar -xvf xxx.jar
```

## 压缩
```bash
jar -cvf0m xxx.jar ./META-INF/MANIFEST.INF .
```

## 修改
```bash
# 待修改的文件必须和jar包内目录一致
# 只能修改类, 如果修改lib包则会导致hash不一致
jar -uvf xxx.jar path/to/file.class
```

## References



