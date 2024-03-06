---
weight: 100
title: "常用SQL"
---

## 常用SQL

### 复制表和数据并清空原表
```sql
CREATE TABLE newTable LIKE oldTable;
INSERT INTO newTable SELECT * FROM oldTable;
DELETE FROM oldTable; # 效率较慢且不会重置主键自增序列, 可以使用 TRUNCATE TABLE 替代
```


## References


