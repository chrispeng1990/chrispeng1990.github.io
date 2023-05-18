---
weight: 2
title: "macosx"
bookFlatSection: false
bookCollapseSection: true
---

## 1. 信任第三方源软件
```bash
#!/bin/bash

# MacOSX 系统默认不能打开第三方软件，
# 使用此命令在【安全性与隐私】-【通用】中开启：
#   允许从以下位置下载的应用：
#       [ ] App Store
#       [ ] App Store 和被认可的开发者
#       [*] 任何来源

sudo spctl --master-disable
```

## 2. 查看端口占用进程
```bash
sudo lsof -i:{port}
```

## 3. 开启80端口并设置代理
```bash
vim /usr/local/etc/nginx/nginx.conf
```
```
# 将本地 80 端口代理到 8086 端口
    server {
        listen 80;
        server_name www.test.com;
        location / {
            proxy_pass http://www.test.com:8086;
            proxy_set_header Host $host:$server_port;
        }
    }
```
```bash
sudo nginx -c /usr/local/etc/nginx/nginx.conf
sudo nginx -s reload
```

## References
