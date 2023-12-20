---
weight: 100
title: "启用本地http服务"
---

## python2方式一
```bash
python -m SimpltHTTPServer 8080
```

## python2方式二
```bash
python -c "import socket,SocketServer,CGIHTTPServer;SocketServer.TCPServer.address_family=socket.AF_INET6;CGIHTTPServer.test()" 8080
```

## References


