---
weight: 100
title: "Linux Cmd"
---
## CPU

### 查看进程cpu使用清空
```bash
top
```

## 内存

### 查看内存  
```bash
free -m
```
```bash
             total       used       free     shared    buffers     cached
Mem:         22528      21781        746          0          0       6403
-/+ buffers/cache:      15377       7150
Swap:         2048       1648        399
```
  

### 查看进程内存占用占比
```bash
ps -eo pid,cmd,%mem,%cpu --sort=-%mem
```
```bash
   PID CMD                         %MEM %CPU
     1 /usr/bin/container-init -st  0.0  0.0
  1191 /data/webapps/waimai_servic  0.2  0.3
  4688 /opt/meituan/apps/cplugin/c  0.0  0.3
  4752 octo_proxy_real -c /opt/mei  0.0  0.6
  4774 [sh] <defunct>               0.0  0.0
  5165 sg_agent                     0.5  9.8
  9021 ./falcon-agent               0.0  2.7
  9329 /opt/meituan/apps/kms_agent  0.1  0.3
 77103 /opt/meituan/apps/direwolf/  0.0  0.3
147582 /usr/local/java11/bin/java  99.9  422
147886 /data/webapps/waimai_servic  0.1  0.5
154263 /opt/meituan/apps/direwolf/  0.0  0.3
171644 bash                         0.0  0.0
171782 ps -eo pid,cmd,%mem,%cpu --  0.0  0.0
```

  
### 查看swap占用  
```bash
for file in /proc/*/status ; do awk '/VmSwap|Name/{printf $2 " " $3}END{ print ""}' $file; done | sort -k 2 -n -r
```
```bash
java 1122636 kB
sg_agent 477700 kB
log_agent 24656 kB
octo-proxy 9560 kB
supervisord 8684 kB
mls-agent 4708 kB
dw_1011 3996 kB
jumper-agent 3960 kB
```

## 磁盘
### 查看某目录下最大的文件夹列表
```bash
du -h --max-depth=2 /opt | sort -hr | head -10
```
```bash
61G	/opt/logs
22G	/opt/logs/com.sankuai.wmadsvc.dsa
16G	/opt/logs/dsa_pvlog/com.sankuai.wmadsvc.dsa
16G	/opt/logs/dsa_pvlog
9.5G	/opt/logs/com.sankuai.inf.sg_agent
6.0G	/opt/logs/logs
4.8G	/opt/logs/roma_backtrack/com.sankuai.wmadsvc.dsa
4.8G	/opt/logs/roma_backtrack
1.3G	/opt/logs/logs/inf
1.2G	/opt/logs/log_agent_file/logs
```

### 清空某个文件
```bash
echo -n '' > /logs/test.log
# rm 大文件可能导致磁盘占用不释放
# echo '' > /logs/test.log 删除不掉时, 加 -n 参数尝试
```

## docker
### 宿主机上以root进入容器
```bash
docker exec --privileged -ti <容器ID> bash
```

## atop
### 查看指定容器的进程
```bash
atop
J
# 输入CID
```

### 查看指定进程ID
```bash
atop
I
# 输入PID
```


### 读取历史日志
```bash
atop -r /path/to/file
# t键向前翻页，T键向后翻页
# b键跳转到指定时间，时间格式为hh:mm
```


## References
[Linux系统监控工具atop](https://baijiahao.baidu.com/s?id=1658884324200587364&wfr=spider&for=pc)  


