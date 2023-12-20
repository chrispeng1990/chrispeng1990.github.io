---
weight: 200
title: "SpringSecurityOauth认证过程"
---

## 涉及的地址
+ OAuth服务提供商中配置的回调地址
+ 后端服务中配置的redirectTemplate地址
+ 前端地址
+ 后端地址


## 实现方式
### oauth认证完成后无需中间redirect.html页面
需要前后端保持同域, 这样小窗和主页面使用相同的session  
即上述四个地址需要同域  
实现方式: 小窗完成认证后在 OauthAuthenticationSuccessHandler 中将登录信息写入session, 前端页面打开小窗口后一直轮询是否登录成功即可  


### 前后端分离项目且不同域
前端域名无需与oauth有关  
通过中间页面redirect.html实现  
参考下面请求过程  


## 请求过程
```bash
    用户        前端地址(主页面)                   小窗                 后端地址           Oauth提供方
browser   ->    页面点击按钮            ->     打开小窗         ->    解析请求
                                                                   跳转到提供方    ->    解析请求
                                             页面        <-------------------------     展示授权页面
                                             输入账密     ------------------------->     认证完成
                                                                   解析oauth_token <-   跳转回调地址
                                                                   生成认证用户存储缓存
                                             登录中页面   <-        带缓存的key值跳转
                获取key             <-       将key传播到主页面并关闭小窗
                登录            ----------------------------->     查询key的缓存
                登录成功         <-----------------------------     认证完成
  end     <-    跳转首页
```


## 处理逻辑
http.and().oauth2Login().authorizationEndpoint().baseUri(securitySettings.getLogin().getProcessor())  // 点击跳转oauth服务器的链接地址 /{baseUri}/{registrationId}  

  -> GenericOAuth2UserService.loadUser()  
       按各个厂商定义取值,并自动生成用户信息  
  -> OauthAuthenticationSuccessHandler.onAuthenticationSuccess()  
       将用户信息(OAuth2User)存储在缓存(session(也可使用redis))中, 并将小窗请求重定向  
  -> OAuth2Controller.redirect()  
       将小窗sessionId信息(不使用session的话可以自己生成token作为key存入redis)写入到页面  
  -> security/oauthRedirect.html  
       将token信息通过 window.opener.postMessage(token, "*") 传递给开启小窗的父窗口  
  -> front/src/login.vue  
       通过 window.addEventListener('message', function (e) {...} 获取小窗传递的token信息  
  -> OAuth2Controller.authorize()  
       接收主窗口的token调用信息  
  -> GenericOAuth2UserService..authorize()  
       通过token(sessionId)从指定session中取出用户信息(OAuth2User)  
       将用户信息刷入当前session中  


## 新增一类CLIENT
io.celery.arch.web.starter.security.configuration.OauthAutoConfiguration 中添加对应的 ClientRegistration 并放在 clientRegistrationRepository 中  
io.celery.arch.web.starter.security.beans.oauth.service.GenericOAuth2UserService 中添加 loadUser() 解析oauth_token  


## References
[前后端分离下的第三方登陆处理](https://www.jianshu.com/p/da54bad42b30)  
