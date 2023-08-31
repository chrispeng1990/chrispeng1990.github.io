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
public class RepeatableStreamHttpServletRequest extends HttpServletRequestWrapper {

    private final byte[] bytes;

    public RepeatableStreamHttpServletRequest(HttpServletRequest request) throws IOException {
        super(request);
        bytes = IOUtils.toByteArray(request.getInputStream());
    }

    @Override
    public ServletInputStream getInputStream() throws IOException {
        return new ServletInputStream() {
            private int lastIndexRetrieved = -1;
            private ReadListener readListener = null;

            @Override
            public boolean isFinished() {
                return (lastIndexRetrieved == bytes.length - 1);
            }

            @Override
            public boolean isReady() {
                // This implementation will never block
                // We also never need to call the readListener from this method, as this method will never return false
                return isFinished();
            }

            @Override
            public void setReadListener(ReadListener readListener) {
                this.readListener = readListener;
                if (!isFinished()) {
                    try {
                        readListener.onDataAvailable();
                    } catch (IOException e) {
                        readListener.onError(e);
                    }
                } else {
                    try {
                        readListener.onAllDataRead();
                    } catch (IOException e) {
                        readListener.onError(e);
                    }
                }
            }

            @Override
            public int read() throws IOException {
                int i;
                if (!isFinished()) {
                    i = bytes[lastIndexRetrieved + 1];
                    lastIndexRetrieved++;
                    if (isFinished() && (readListener != null)) {
                        try {
                            readListener.onAllDataRead();
                        } catch (IOException e) {
                            readListener.onError(e);
                            throw e;
                        }
                    }
                    return i;
                } else {
                    return -1;
                }
            }
        };
    }

    @Override
    public BufferedReader getReader() throws IOException {
        ByteArrayInputStream is = new ByteArrayInputStream(bytes);
        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        return reader;
    }
}
```
> 创建HttpRequest时缓存InputStream为bytes, 重写 getInputStream() 和 getReader() 方法从bytes中读取生成新的流.

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
