---
weight: 100
title: "Spring Express Language"
---

## 语法
### 静态方法调用
`"T(System).currentTimeMillis()"`

### Bean实例方法调用
`"@beanName.method()"`

### List
`"list[0].property"`  
`"T(com.google.common.collect.Lists).partition({'a', 'b', 'c'}, 1)"`  

### Map
`"map[key].property"`  
`"T(com.google.common.collect.Maps).newHashMap({'k': 'v'})"`  

## 使用方式
### 注解使用
```java
public class Test {
    
    @Value("'Hello World'.concat('!')")
    private String value;
    
}
```

### 代码调用
```java
public class Test {
    
    public static void main(String[] args) {
        // 1 定义解析器
        SpelExpressionParser parser = new SpelExpressionParser();
        // 2 使用解析器解析表达式
        Expression exp = parser.parseExpression("'Hello World'.concat('!')");
        // 3 获取解析结果
        String value = (String) exp.getValue();
        System.out.println(value);
    }
    
}
```

## References
[Spring系列19：SpEL详解](https://blog.csdn.net/m0_67394006/article/details/126117176)  

