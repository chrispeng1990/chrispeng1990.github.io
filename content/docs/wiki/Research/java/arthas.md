---
weight: 200
title: "Arthas 使用"
---

`java -jar arthas-boot.jar`


```bash
# 反编译代码
jad --source-only com.xxx.xxx.Xxx
jad --source-only com.xxx.xxx.Xxx > com.xxx.xxx.Xxx.java


# 查看bean成员变量
ognl '@com.xxx.utils.SpringUtils@getBean("beanName").propertyName'
# 若未加载SpringUtils类
# 先查看SpringUtils类hash
sc -d com.xxx.utils.SpringUtils
# 指定hash加载
ognl -c 22f71333 '@com.xxx.utils.SpringUtils@getBean("beanName").propertyName'


## 热修改class
# 注: 不能增减成员变量和方法, 只能修改代码段
redefine /tmp/Xxx.class

```



## References
[如何使用Arthas查看类变量值](https://blog.csdn.net/zhuqiuhui/article/details/122381125)  
[Arthas不停机热修改代码](https://blog.csdn.net/qq_41419769/article/details/122847521)  
[arthas 执行ognl表达式ClassNotFoundException](https://blog.csdn.net/w605283073/article/details/106535170/)  


