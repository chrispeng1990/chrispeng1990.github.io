---
weight: 200
title: "Alfred"
---

## 1. 基础配置

### 1.1. Web Search
Afred Preferences → Features → Web Search  
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191525609.png)  
  
#### 1.1.1. 添加 baidu  
```
https://www.baidu.com/s?wd={query}
```
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191526396.png)  
  
#### 1.1.2. 添加 mvnrepository
```
https://mvnrepository.com/search?q={query}
```
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191527264.png)  
  
#### 1.1.3. 添加 unpkg
```
https://unpkg.com/browse/{query}/
```
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191528690.png)  
  
### 1.2. Clipboard History
文本保留时间修改为 3 Months, 图片保留时间修改为 7 Days, 文件保留 24 Hours  
打开剪切板历史关键字修改为 cp  
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191530878.png)  
  

## 2. 集成 iTerm
Afred Preferences → Features → Terminal → Application  
Terminal 修改为 Custom  
![](https://raw.githubusercontent.com/nctsc/resources/master/images/202304191531007.png)  
  
插入以下代码:  
```bash
on alfred_script(q)
    if application "iTerm2" is running or application "iTerm" is running then
        run script "
            on run {q}
                tell application \"iTerm\"
                    activate
                    try
                        select first window
                        set onlywindow to true
                    on error
                        create window with default profile
                        select first window
                        set onlywindow to true
                    end try
                    tell the first window
                        create tab with default profile
                        tell current session to write text q
                    end tell
                end tell
            end run
        " with parameters {q}
    else
        run script "
            on run {q}
                tell application \"iTerm\"
                    activate
                    try
                        select first window
                    on error
                        create window with default profile
                        select first window
                    end try
                    tell the first window
                        tell current session to write text q
                    end tell
                end tell
            end run
        " with parameters {q}
    end if
end alfred_script
```
  

## 3. workflow
[Github/AlfredWorkflows](https://github.com/nctsc/AlfredWorkflows)  
  

## References
