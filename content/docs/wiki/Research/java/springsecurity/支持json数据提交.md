---
weight: 100
title: "支持json数据提交"
---

## 1. 替换UsernamePasswordAuthenticationFilter
```java
public class PrincipalsCredentialsAuthenticationFilter extends UsernamePasswordAuthenticationFilter {

    public PrincipalsCredentialsAuthenticationFilter() {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        super.doFilter(req, res, chain);
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request, HttpServletResponse response) throws AuthenticationException {
        if (request.getContentType().equals(MediaType.APPLICATION_JSON_UTF8_VALUE)
                || request.getContentType().equals(MediaType.APPLICATION_JSON_VALUE)) {
            Tuple2<String, String> tuple = obtainPrincipalsAndCredentials(request);
            String principals = tuple.getField(0);
            String credentials = tuple.getField(1);

            if (principals == null) {
                principals = "";
            }

            if (credentials == null) {
                credentials = "";
            }

            principals = principals.trim();

            PrincipalsCredentialsAuthenticationToken authRequest = new PrincipalsCredentialsAuthenticationToken(
                    principals, credentials);

            // Allow subclasses to set the "details" property
            setDetails(request, authRequest);

            return this.getAuthenticationManager().authenticate(authRequest);
        } else {
            return super.attemptAuthentication(request, response);
        }
    }

    private Tuple2<String, String> obtainPrincipalsAndCredentials(HttpServletRequest request) {
        String principalsParameterName = this.getUsernameParameter();
        String credentialsParameterName = this.getPasswordParameter();

        Tuple2<String, String> tuple = new Tuple2<>();

        try {
            String json = IOUtils.copyToString(request.getReader());
            Map<String, Object> requestBody = JsonUtils.convertJsonToMap(json, String.class, Object.class);
            String principals = String.valueOf(requestBody.getOrDefault(principalsParameterName, ""));
            String credentials = String.valueOf(requestBody.getOrDefault(credentialsParameterName, ""));
            tuple.setFields(principals, credentials);
        } catch (Exception e) {
            tuple.setFields(StringUtils.EMPTY, StringUtils.EMPTY);
        }

        return tuple;
    }
}
```
> 注意: 由于涉及request的input stream读取操作, 为不影响后续操作继续读取输入流, 需要提前将ServletHttpRequest转换成可重复读形式  
> 参考: [可重复读的ServletHttpRequest](/docs/wiki/research/java/springboot/可重复读的servlethttprequest/index.html)
  
## 2. 注册 Filter
```java
public class WebSecurityConfigurer extends WebSecurityConfigurerAdapter {
    
    private PrincipalsCredentialsAuthenticationFilter principalsCredentialsAuthenticationFilter() throws Exception {
        PrincipalsCredentialsAuthenticationFilter filter = new PrincipalsCredentialsAuthenticationFilter();
        filter.setAuthenticationManager(authenticationManagerBean());

        filter.setUsernameParameter(securitySettings.getLogin().getPrincipalsParameter());
        filter.setPasswordParameter(securitySettings.getLogin().getCredentialsParameter());
        filter.setAuthenticationSuccessHandler(authenticationSuccessHandler);
        filter.setAuthenticationFailureHandler(authenticationFailureHandler);
        AntPathRequestMatcher requestMatcher = new AntPathRequestMatcher(securitySettings.getLogin().getProcessor(), "POST");
        filter.setPostOnly(true);
        filter.setRequiresAuthenticationRequestMatcher(requestMatcher);
        filter.setBeanName("principalsCredentialsAuthenticationFilter");
        return filter;
    }
    
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        
        // + ... 
        
        http
//            .httpBasic().and()  // http浏览器认证
            .authorizeRequests()
            .antMatchers(excludes).permitAll()  // 排除部分不需要鉴权的请求, 如 js html ...
            .antMatchers(includes).authenticated()  // 所有请求都需要认证  .anyRequest().authenticated()
            .and()
                .addFilterAt(principalsCredentialsAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class)
                .formLogin()    // 登录表单
                    .loginPage(securitySettings.getLogin().getPage())    // 登录页面url
                    .loginProcessingUrl(securitySettings.getLogin().getProcessor())   // 登录验证url
//                    .defaultSuccessUrl("/index")    // 成功登录跳转，取消配置则跳转至用户输入的页面
                    .successHandler(authenticationSuccessHandler)    // 成功登录处理器
                    .failureHandler(authenticationFailureHandler)    // 失败登录处理器
                    .usernameParameter(securitySettings.getLogin().getPrincipalsParameter())
                    .passwordParameter(securitySettings.getLogin().getCredentialsParameter())
                    .permitAll()    //登录成功后有权限访问所有页面
        ;
        
        // + ...
    }
}
```

1. filter无需注册成bean, 若有需要, 需将 WebSecurityConfigurer 转换成 @Configuration, 再通过 @Bean 注入(由于authenticationManagerBean()非SpringBean)  
2. 由于替换了原生的 UsernamePasswordAuthenticationFilter, 因此配置的 formLogin() 全部失效, 无论 addFilterAt 注册位置.
所以需要在生成 Filter 对象时显示的指定 usernameParameter, passwordParameter, authenticationSuccessHandler, authenticationFailureHandler, requiresAuthenticationRequestMatcher.
其中 requiresAuthenticationRequestMatcher 如果不指定(默认为POST /login), 那么就不会走 filter 的 attemptAuthentication(), 参考:  
```java
public abstract class AbstractAuthenticationProcessingFilter extends GenericFilterBean
        implements ApplicationEventPublisherAware, MessageSourceAware {
    // + ...
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        if (!requiresAuthentication(request, response)) {
            chain.doFilter(request, response);
            return;
        }
        if (logger.isDebugEnabled()) {
            logger.debug("Request is to process authentication");
        }

        Authentication authResult;
        try {
            authResult = attemptAuthentication(request, response);
            if (authResult == null) {
                return;
            }
            sessionStrategy.onAuthentication(authResult, request, response);
        }
        catch (InternalAuthenticationServiceException failed) {
            logger.error("An internal error occurred while trying to authenticate the user.", failed);
            unsuccessfulAuthentication(request, response, failed);
            return;
        }
        catch (AuthenticationException failed) {
            unsuccessfulAuthentication(request, response, failed);
            return;
        }

        if (continueChainBeforeSuccessfulAuthentication) {
            chain.doFilter(request, response);
        }

        successfulAuthentication(request, response, chain, authResult);
    }
    
    // + ...
    protected boolean requiresAuthentication(HttpServletRequest request, HttpServletResponse response) {
        return requiresAuthenticationRequestMatcher.matches(request);
    }
    // + ...
}
```

## 3. 同理修改CaptchaFilter、SmsAuthenticationFilter 以支持json数据格式输入. 
```java
public class CaptchaFilter extends OncePerRequestFilter {
    
    // + ...
    
    protected String obtainCaptcha(HttpServletRequest request, CaptchaType type) {
        String parameterName = StringUtils.EMPTY;
        if (CaptchaType.GRAPH.equals(type)) {
            parameterName = settings.getCaptcha().getGraph().getCaptchaParameter();
        } else if (CaptchaType.SMS.equals(type)) {
            parameterName = settings.getCaptcha().getSms().getSmscaptchaParameter();
        }
        if (StringUtils.isBlank(parameterName)) {
            return StringUtils.EMPTY;
        }

        String captcha = StringUtils.EMPTY;
        if (request.getContentType().equals(MediaType.APPLICATION_JSON_UTF8_VALUE)
                || request.getContentType().equals(MediaType.APPLICATION_JSON_VALUE)) {
            try {
                String json = IOUtils.copyToString(request.getReader());
                Map<String, Object> requestBody = JsonUtils.convertJsonToMap(json, String.class, Object.class);
                captcha = String.valueOf(requestBody.getOrDefault(parameterName, StringUtils.EMPTY));
            } catch (Exception ignore) {
            }
        } else {
            captcha = request.getParameter(parameterName);
        }

        return captcha;
    }
    
    // + ...
}
```
```java
public class SmsAuthenticationFilter extends AbstractAuthenticationProcessingFilter {
    
    // + ...
    
    protected String obtainMobile(HttpServletRequest request) {
        String mobile = StringUtils.EMPTY;
        if (request.getContentType().equals(MediaType.APPLICATION_JSON_UTF8_VALUE)
                || request.getContentType().equals(MediaType.APPLICATION_JSON_VALUE)) {
            try {
                String json = IOUtils.copyToString(request.getReader());
                Map<String, Object> requestBody = JsonUtils.convertJsonToMap(json, String.class, Object.class);
                mobile = String.valueOf(requestBody.getOrDefault(mobileParameter, StringUtils.EMPTY));
            } catch (Exception ignore) {
            }
        } else {
            mobile = request.getParameter(mobileParameter);
        }
    
        return mobile;
    }
    // + ...
}
```

## References
[Spring Boot2 系列教程(三十五)SpringSecurity 使用 JSON 格式登录](https://mp.weixin.qq.com/s?__biz=MzI1NDY0MTkzNQ==&mid=2247487212&idx=2&sn=54d59ea55f7f9df6c7dbd0be3849ae65)  
[Spring Security 前后端分离登录，非法请求直接返回 JSON](http://springboot.javaboy.org/2019/1016/springsecurity-login-json)  
