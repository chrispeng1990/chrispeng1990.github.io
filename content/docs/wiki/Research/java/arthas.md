---
weight: 200
title: "Arthas 使用"
---

## 启动
```bash
java -jar arthas-boot.jar
```


## 运行状态监控
```bash
dashoboard
```
```bash
ID       NAME                      GROUP  PRIORITY   STATE   %CPU  DELTA_TIME    TIME   INTERRUPTED  DAEMON
9008     http-nio-8999-exec-724    main    5        RUNNABLE  0.41   0.020     0:14.071  false       true

Memory                 used   total    max      usage           GC
heap                   5854M  11673M   11673M   50.15%          gc.parnew.count                  45772
par_eden_space         2139M  4915M    4915M    43.54%          gc.parnew.time(ms)               10181844
par_survivor_space     115M   614M     614M     18.73%          gc.concurrentmarksweep.count     43836
cms_old_gen            3599M  6144M    6144M    58.58%          gc.concurrentmarksweep.time(ms)  47318726
nonheap                203M   278M     -1       72.87%
code_cache             56M    128M     128M     44.31%
metaspace              131M   134M     -1       97.32%
compressed_class_space 15M    15M      1024M    1.48%
direct                 1M     1M       -        100.00%
mapped                 1M     1M       -        100.00%

Runtime
os.name                     Linux
os.version                  5.10.0-136.16.0.mt20230627.508.x86_64
java.version                1.8.0_201
java.home                   /usr/local/jdk1.8.0_201/jre
systemload.average          0.10
processors                  8
timestamp/uptime            Thu Oct 19 09:51:53 CST 2023/234199s
```

## 查看线程
```bash
# 查看所有线程
thread

# 查看指定线程调用栈
thread ${threadId}

# 查看cpu使用率前3的线程调用栈
thread -n 3

# 查找阻塞其他线程的线程
thread -b
```

## 反编译代码
```bash
jad --source-only com.xxx.xxx.Xxx
jad --source-only com.xxx.xxx.Xxx > com.xxx.xxx.Xxx.java
# -source-only表示只打印源码
# 如果不加这个参数, 在反编译出的内容头部会携带类加载器的信息, 内容过多
```

## 查看spring bean成员变量
```bash
ognl '@com.xxx.utils.SpringUtils@getBean("beanName").propertyName'

# 若未加载SpringUtils类
# 先查看SpringUtils类hash
sc -d com.xxx.utils.SpringUtils
# 指定hash加载
ognl -c 22f71333 '@com.xxx.utils.SpringUtils@getBean("beanName").propertyName'
```

## 热修改class
```bash
# 注: 不能增减成员变量和方法, 只能修改代码段
redefine /tmp/Xxx.class
```

## 定位代码耗时
```bash
# 监听耗时大于2ms的指定方法的调用
trace com.xxx.api.TestController testMethod '#cost > 2'

# 监听之后请求对应的接口
curl -XGET http://xxx:xxx/xxx/xxx
```
```bash
Press Q or Ctrl+C to abort.
Affect(class count: 1 , method count: 1) cost in 153 ms, listenerId: 2
`---ts=2023-10-19 10:56:11;thread_name=http-nio-8999-exec-716;id=2328;is_daemon=true;priority=5;TCCL=org.springframework.boot.context.embedded.tomcat.TomcatEmbeddedWebappClassLoader@2a1fdce
    `---[38.102122ms] com.xxx.api.TestController:testMethod()
        +---[97.94% 37.317399ms ] com.xxx.service.TestService:testServiceMethod() #34
        +---[0.68% 0.259464ms ] org.slf4j.Logger:info() #35
        +---[0.02% 0.009237ms ] com.xxx.constant.ResponseEnum:getIndex() #40
        +---[0.03% 0.00963ms ] com.xxx.constant.ResponseEnum:getName() #40
        `---[0.03% 0.012309ms ] com.xxx.model.response.CommonResponse:<init>() #40
```

## 监控方法的调用情况(参数和返回值)
```bash
watch com.xxx.api.TestController testMethod "{params,returnObj}" -x 3 -b -s
# -x 3是指定输出结果的属性遍历深度, 默认为 1
# -b方法调用前观察, 用于返回方法入参
# -s方法调用后观察, 用于返回方法返回值

# 监听之后请求对应的接口
curl -XGET http://xxx:xxx/xxx/xxx
```
```bash
method=com.xxx.api.TestController testMethod location=AtEnter
ts=2023-10-19 11:25:19; [cost=0.052685ms] result=@ArrayList[
    @Object[][isEmpty=true;size=0],
    null,
]
method=com.xxx.api.TestController testMethod location=AtExit
ts=2023-10-19 11:25:19; [cost=8.009234875327387E9ms] result=@ArrayList[
    @Object[][isEmpty=true;size=0],
    @CommonResponse[
        code=@Integer[0],
        message=@String[],
        data=@ArrayList[
            @String[xxxxx],
        ],
        OK=@CommonResponse[
            code=@Integer[0],
            message=@String[],
            data=null,
            OK=@CommonResponse[CommonResponse{code=0, message='', data=null}],
        ],
    ],
]
```

## 监控方法被调用栈
```bash
stack com.xxx.service.TestService testServiceMethod
```
```bash
ts=2023-10-19 11:31:00;thread_name=http-nio-8999-exec-710;id=2322;is_daemon=true;priority=5;TCCL=org.springframework.boot.context.embedded.tomcat.TomcatEmbeddedWebappClassLoader@2a1fdce
    @com.xxx.service.TestService.testServiceMethod()
        at com.xxx.api.TestController.testMethod(TestController.java:34)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(NativeMethodAccessorImpl.java:-2)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:209)
        at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:136)
        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
        at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61)
        at java.lang.Thread.run(Thread.java:748)
```


## References
[如何使用Arthas查看类变量值](https://blog.csdn.net/zhuqiuhui/article/details/122381125)  
[Arthas不停机热修改代码](https://blog.csdn.net/qq_41419769/article/details/122847521)  
[arthas 执行ognl表达式ClassNotFoundException](https://blog.csdn.net/w605283073/article/details/106535170/)  
[性能调优必备：Arthas安装及常用命令教程](https://zhuanlan.zhihu.com/p/466098235?utm_id=0)

