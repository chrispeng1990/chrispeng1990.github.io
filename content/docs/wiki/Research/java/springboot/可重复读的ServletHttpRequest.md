---
weight: 200
title: "可重复读的ServletHttpRequest"
---

## 1. 定义可重复读输入数据流的 HttpRequest
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

## 2. 定义转换可重复读Request的Filter
```java
public class RepeatableRequestStreamFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {

    }

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest httpServletRequest = new RepeatableStreamHttpServletRequest((HttpServletRequest) servletRequest);
        HttpServletResponse httpServletResponse = (HttpServletResponse) servletResponse;
        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }

    @Override
    public void destroy() {

    }

}
```

## 3. Filter Bean定义和注册
```java
@Configuration
public class WebAutoConfiguration {
    /**
     * 可重复读的Request输入流Filter
     */
    @Bean
    public RepeatableRequestStreamFilter repeatableRequestStreamFilter() {
        return new RepeatableRequestStreamFilter();
    }

    /**
     * 可重复读的Request输入流Filter注册
     */
    @Bean
    public FilterRegistrationBean repeatableRequestStreamFilterRegister() {
        FilterRegistrationBean<DelegatingFilterProxy> registration = new FilterRegistrationBean<>();
        registration.setFilter(new DelegatingFilterProxy("repeatableRequestStreamFilter"));
        registration.addUrlPatterns("/*");
        registration.setName("repeatableRequestStreamFilter");
        Map<String, String> initParameters = new HashMap<>();
        registration.setInitParameters(initParameters);
        registration.setOrder(Ordered.HIGHEST_PRECEDENCE);  // 优先级最高, 首先转成可重复读输入流request
        return registration;
    }
}
```
> filter需要优先级最高执行, 避免stream被其他业务解析, Ordered.HIGHEST_PRECEDENCE = Integer.MIN_VALUE = -2147483647

## References
[如何重复读取HttpServletRequest的HTTP请求体数据](https://cloud.tencent.com/developer/article/1398795)  
