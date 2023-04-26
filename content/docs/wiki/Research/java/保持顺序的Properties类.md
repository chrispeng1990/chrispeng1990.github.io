---
weight: 200
title: "保持顺序的Properties类"
---

## 保持顺序的Properties类
&ensp;&ensp;&ensp;&ensp;Java 的 Properties 加载属性文件后是无法保证输出的顺序与文件中一致的，因为 Properties 是继承自 Hashtable 的， key/value 都是直接存在 Hashtable 中的，而 Hashtable 是不保证进出顺序的。  
&ensp;&ensp;&ensp;&ensp;总有时候会有关心顺序一致的需求，恰如有 org.apache.commons.collections.OrderdMap（其实用 LinkedHashMap 就是保证顺序） 一样，我们也想要有个 OrderdProperties。  
&ensp;&ensp;&ensp;&ensp;只要继承自 Properties，覆盖原来的 put/keys,keySet,stringPropertyNames 即可，其中用一个 LinkedHashSet 来保存它的所有 key。完整代码如下:   

```java
import java.util.Collections;
import java.util.Enumeration;
import java.util.LinkedHashSet;
import java.util.Properties;
import java.util.Set;

public class OrderedProperties extends Properties {

    private static final long serialVersionUID = -4627607243846121965L;
    private final LinkedHashSet<Object> keys = new LinkedHashSet<Object>();

    public Enumeration<Object> keys() {
        return Collections.<Object> enumeration(keys);
    }

    public Object put(Object key, Object value) {
        keys.add(key);
        return super.put(key, value);
    }

    public Set<Object> keySet() {
        return keys;
    }

    public Set<String> stringPropertyNames() {
        Set<String> set = new LinkedHashSet<>();
        for (Object key : this.keys) {
            set.add((String) key);
        }
        return set;
    }
}
```
  

## References
[http://gflei.iteye.com/blog/1851875](http://gflei.iteye.com/blog/1851875)  

