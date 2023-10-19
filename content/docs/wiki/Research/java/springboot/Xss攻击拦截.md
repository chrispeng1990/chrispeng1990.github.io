---
weight: 300
title: "Xss攻击拦截"
---

## 1. 引入 jsonp
```xml
<project>
    <dependencies>
        <dependency>
            <groupId>org.jsoup</groupId>
            <artifactId>jsoup</artifactId>
        </dependency>
    </dependencies>
</project>
```

## 2. 拦截工具类
```java
public class XssUtils {

    private XssUtils() {}

    /**
     * 使用自带的basicWithImages 白名单
     * 允许的便签有a,b,blockquote,br,cite,code,dd,dl,dt,em,i,li,ol,p,pre,q,small,span,
     * strike,strong,sub,sup,u,ul,img
     * 以及a标签的href,img标签的src,align,alt,height,width,title属性
     */
    private static final Whitelist whitelist = Whitelist.basicWithImages();
    /*
     * 配置过滤化参数,不对代码进行格式化
     */
    private static final Document.OutputSettings outputSettings = new Document.OutputSettings().prettyPrint(false);
    static {
        /*
         * 富文本编辑时一些样式是使用style来进行实现的 比如红色字体 style="color:red;" 所以需要给所有标签添加style属性
         */
        whitelist.addAttributes(":all", "style");
    }

    public static String clean(String content) {
        return Jsoup.clean(content, "", whitelist, outputSettings);
    }
}
```

## 3. 定义 HttpServletRequest 包装类
```java
public class XssHttpServletRequest extends HttpServletRequestWrapper {

    public XssHttpServletRequest(HttpServletRequest request) {
        super(request);
    }

    /**
     * 覆盖getParameter方法，将参数名和参数值都做xss过滤
     * 如果需要获得原始的值，则通过super.getParameterValues(name)来获取
     * getParameterNames,getParameterValues和getParameterMap也可能需要覆盖
     */
    @Override
    public String getParameter(String name) {
        if (("content".equals(name) || name.endsWith("WithHtml"))) {
            return super.getParameter(name);
        }
        name = XssUtils.clean(name);
        String value = super.getParameter(name);
        if (StringUtils.isNotBlank(value)) {
            value = XssUtils.clean(value);
        }
        return value;
    }

    @Override
    public String[] getParameterValues(String name) {
        String[] arr = super.getParameterValues(name);
        if (arr != null) {
            IntStream.range(0, arr.length).forEach(i -> arr[i] = XssUtils.clean(arr[i]));
        }
        return arr;
    }

    /**
     * 覆盖getHeader方法，将参数名和参数值都做xss过滤
     * 如果需要获得原始的值，则通过super.getHeaders(name)来获取
     * getHeaderNames 也可能需要覆盖
     */
    @Override
    public String getHeader(String name) {
        name = XssUtils.clean(name);
        String value = super.getHeader(name);
        if (StringUtils.isNotBlank(value)) {
            value = XssUtils.clean(value);
        }
        return value;
    }

}
```
> 重写 getParameter()、getParameterValues()、getHeader() 过滤xss代码

## 4. 定义拦截的Filter
```java
public class XssFilter implements Filter {

    private List<String> excludes = new ArrayList<>();

    private AntPathMatcher pathMatcher;

    @Override
    public void init(FilterConfig filterConfig) {
        pathMatcher = new AntPathMatcher();
        String parameter = filterConfig.getInitParameter("excludes");
        excludes = ListUtils.splitToList(parameter, BaseConstants.COMMA);
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest servletRequest = (HttpServletRequest) request;
        if (inExcludes(servletRequest)) {
            chain.doFilter(request, response);
            return;
        }

        XssHttpServletRequest xssRequest = new XssHttpServletRequest(servletRequest);
        chain.doFilter(xssRequest, response);
    }

    @Override
    public void destroy() {
        // do nothing
    }

    private boolean inExcludes(HttpServletRequest request) {
        if (CollectionUtils.isEmpty(excludes)) {
            return false;
        }

        String url = request.getServletPath();
        return excludes.stream().anyMatch(e -> pathMatcher.match(e, url));
    }
}
```

## 5. Filter Bean定义和注册
```java
@Configuration
public class WebAutoConfiguration {
    /**
     * xss攻击拦截Filter
     */
    @Bean
    @ConditionalOnProperty(name = {"celery.web.xss.enable"}, havingValue = "true", matchIfMissing = false)
    public XssFilter xssFilter() {
        return new XssFilter();
    }

    /**
     * xss攻击拦截Filter注册
     */
    @Bean
    @ConditionalOnProperty(name = {"celery.web.xss.enable"}, havingValue = "true", matchIfMissing = false)
    public FilterRegistrationBean xssFilterRegister() {
        FilterRegistrationBean<DelegatingFilterProxy> registration = new FilterRegistrationBean<>();
        registration.setFilter(new DelegatingFilterProxy("xssFilter"));
        registration.addUrlPatterns("/*");
        registration.setName("xssFilter");
        Map<String, String> initParameters = new HashMap<>();
        initParameters.put("excludes", "/favicon.ico,/img/**,/js/**,/css/**,/statics/**,/h2/**,/docs/**,/druid/**");
        registration.setInitParameters(initParameters);
        registration.setOrder(100);
        return registration;
    }
}
```

## References
