---
weight: 300
title: "Bilibili去标题和广告"
---

```javascript
// ==UserScript==
// @name         BilibiliHeaderHidden
// @namespace    https://www.bilibili.com/
// @version      0.1
// @description  hidden Bilibili Header.
// @author       Chris
// @match        https://www.bilibili.com/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=bilibili.com
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    // Your code here...
    setTimeout(function() {
    document.querySelector('.fixed-top-header').hidden = true;
    document.querySelector('.mini-header').hidden = true;
    }, 1000);
})();
```
