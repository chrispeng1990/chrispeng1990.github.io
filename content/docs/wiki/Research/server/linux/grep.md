---
weight: 200
title: "grep"
---

## 简介
全称：Global Regular Expression Print  

格式:
```bash
grep [option] pattern file
```

参数: 
```bash
   -a   --text   #不要忽略二进制的数据。   
   -A<显示行数>   --after-context=<显示行数>   #除了显示符合范本样式的那一列之外，并显示该行之后的内容。   
   -b   --byte-offset   #在显示符合样式的那一行之前，标示出该行第一个字符的编号。   
   -B<显示行数>   --before-context=<显示行数>   #除了显示符合样式的那一行之外，并显示该行之前的内容。   
   -c    --count   #计算符合样式的列数。   
   -C<显示行数>    --context=<显示行数>或-<显示行数>   #除了显示符合样式的那一行之外，并显示该行之前后的内容。   
   -d <动作>      --directories=<动作>   #当指定要查找的是目录而非文件时，必须使用这项参数，否则grep指令将回报信息并停止动作。   
   -e<范本样式>  --regexp=<范本样式>   #指定字符串做为查找文件内容的样式。   
   -E      --extended-regexp   #将样式为延伸的普通表示法来使用。   
   -f<规则文件>  --file=<规则文件>   #指定规则文件，其内容含有一个或多个规则样式，让grep查找符合规则条件的文件内容，格式为每行一个规则样式。   
   -F   --fixed-regexp   #将样式视为固定字符串的列表。   
   -G   --basic-regexp   #将样式视为普通的表示法来使用。   
   -h   --no-filename   #在显示符合样式的那一行之前，不标示该行所属的文件名称。   
   -H   --with-filename   #在显示符合样式的那一行之前，表示该行所属的文件名称。   
   -i    --ignore-case   #忽略字符大小写的差别。   
   -l    --file-with-matches   #列出文件内容符合指定的样式的文件名称。   
   -L   --files-without-match   #列出文件内容不符合指定的样式的文件名称。   
   -n   --line-number   #在显示符合样式的那一行之前，标示出该行的列数编号。   
   -q   --quiet或--silent   #不显示任何信息。   
   -r   --recursive   #此参数的效果和指定“-d recurse”参数相同。   
   -s   --no-messages   #不显示错误信息。   
   -v   --revert-match   #显示不包含匹配文本的所有行。   
   -V   --version   #显示版本信息。   
   -w   --word-regexp   #只显示全字符合的列。   
   -x    --line-regexp   #只显示全列符合的列。   
   -y   #此参数的效果和指定“-i”参数相同。
```

规则表达式:
```bash
   ^  #锚定行的开始 如：'^grep'匹配所有以grep开头的行。    
   $  #锚定行的结束 如：'grep$'匹配所有以grep结尾的行。    
   .  #匹配一个非换行符的字符 如：'gr.p'匹配gr后接一个任意字符，然后是p。    
   *  #匹配零个或多个先前字符 如：'*grep'匹配所有一个或多个空格后紧跟grep的行。    
   .*   #一起用代表任意字符。   
   []   #匹配一个指定范围内的字符，如'[Gg]rep'匹配Grep和grep。    
   [^]  #匹配一个不在指定范围内的字符，如：'[^A-FH-Z]rep'匹配不包含A-R和T-Z的一个字母开头，紧跟rep的行。    
   \(..\)  #标记匹配字符，如'\(love\)'，love被标记为1。    
   \<      #锚定单词的开始，如:'\<grep'匹配包含以grep开头的单词的行。    
   \>      #锚定单词的结束，如'grep\>'匹配包含以grep结尾的单词的行。    
   x\{m\}  #重复字符x，m次，如：'0\{5\}'匹配包含5个o的行。    
   x\{m,\}  #重复字符x,至少m次，如：'o\{5,\}'匹配至少有5个o的行。    
   x\{m,n\}  #重复字符x，至少m次，不多于n次，如：'o\{5,10\}'匹配5--10个o的行。   
   \w    #匹配文字和数字字符，也就是[A-Za-z0-9]，如：'G\w*p'匹配以G后跟零个或多个文字或数字字符，然后是p。   
   \W    #\w的反置形式，匹配一个或多个非单词字符，如点号句号等。   
   \b    #单词锁定符，如: '\bgrep\b'只匹配grep。  
```


## 常用命令
### 带行号的递归查找
```bash
grep -rn 'searchme' /path/to/file
```

### 忽略大小写
```bash
grep -rni 'searCHme' /path/to/file
```

### 向后多显示几行
```bash
# -A1: 除了搜索到的当前行外, 额外包含后一行, A1...n
grep -rniA1 'searchme' /path/to/file
# 同理向前就是 -Bn
grep -rniB1 'searchme' /path/to/file
# 前后都需要 -Cn
grep -rniC1 'searchme' /path/to/file
# A: after, B: before, C: context
```

### 排除某个单词
```bash
ps -ef | grep java | grep -v 'grep'
```

### 多条件或
```bash
# 查找包含'a'或'b'的行
grep -E 'a|b' /path/to/file
# 也可以使用 -e
grep -e 'a' -e 'b' /path/to/file
```

### 多条件且
```bash
# 查找包含'a'和'b'的行, a和b有先后顺序
grep -E 'a.*b' /path/to/file
# 无先后顺序使用或实现
grep -E 'a.*b|b.*a' /path/to/file
```


## References
[linux命令-grep](https://cloud.tencent.com/developer/article/1635047?from=15425)  
[Linux grep多个关键字“与”和“或”使用详解](https://blog.csdn.net/qq_25123887/article/details/126748655)  

