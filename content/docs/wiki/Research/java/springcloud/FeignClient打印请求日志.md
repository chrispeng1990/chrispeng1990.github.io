---
weight: 100
title: "FeignClient打印请求日志"
---

## 使用方式
### 自定义 FeignLogger
```java
import feign.Request;
import feign.Response;
import feign.Util;
import feign.slf4j.Slf4jLogger;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;

import static feign.Util.*;

@Slf4j
public class FeignLogger extends Slf4jLogger {

    @Override
    @SuppressWarnings("deprecation")
    protected void logRequest(String configKey, Level logLevel, Request request) {
        String method = request.httpMethod().name();
        String url = request.url();
        String requestBody = "";

        // log(configKey, "---> %s %s HTTP/1.1", request.httpMethod().name(), request.url());

        if (logLevel.ordinal() >= Level.HEADERS.ordinal()) {

            for (String field : request.headers().keySet()) {
                for (String value : valuesOrEmpty(request.headers(), field)) {
                    // log(configKey, "%s: %s", field, value);
                }
            }

            int bodyLength = 0;
            if (request.requestBody().asBytes() != null) {
                bodyLength = request.requestBody().asBytes().length;
                if (logLevel.ordinal() >= Level.FULL.ordinal()) {
                    String bodyText =
                            request.charset() != null
                                    ? new String(request.requestBody().asBytes(), request.charset())
                                    : null;
                    // log(configKey, ""); // CRLF
                    // log(configKey, "%s", bodyText != null ? bodyText : "Binary data");
                    requestBody = bodyText != null ? bodyText : "Binary data";
                }
            }
            // log(configKey, "---> END HTTP (%s-byte body)", bodyLength);
        }

        log(configKey, "%s %s : requestBody = %s", method, url, requestBody);
    }

    @Override
    protected Response logAndRebufferResponse(String configKey, Level logLevel, Response response, long elapsedTime) throws IOException {
        String method = response.request().httpMethod().name();
        String url = response.request().url();
        String responseBody = "";

        String reason =
                response.reason() != null && logLevel.compareTo(Level.NONE) > 0 ? " " + response.reason()
                        : "";
        int status = response.status();
//        log(configKey, "<--- HTTP/1.1 %s%s (%sms)", status, reason, elapsedTime);
        if (logLevel.ordinal() >= Level.HEADERS.ordinal()) {

            for (String field : response.headers().keySet()) {
                for (String value : valuesOrEmpty(response.headers(), field)) {
//                    log(configKey, "%s: %s", field, value);
                }
            }

            int bodyLength = 0;
            if (response.body() != null && !(status == 204 || status == 205)) {
                // HTTP 204 No Content "...response MUST NOT include a message-body"
                // HTTP 205 Reset Content "...response MUST NOT include an entity"
                if (logLevel.ordinal() >= Level.FULL.ordinal()) {
                    // log(configKey, ""); // CRLF
                }
                byte[] bodyData = Util.toByteArray(response.body().asInputStream());
                bodyLength = bodyData.length;
                if (logLevel.ordinal() >= Level.FULL.ordinal() && bodyLength > 0) {
                    // log(configKey, "%s", decodeOrDefault(bodyData, UTF_8, "Binary data"));
                }
//                log(configKey, "<--- END HTTP (%s-byte body)", bodyLength);

                responseBody = decodeOrDefault(bodyData, UTF_8, "Binary data");
                log(configKey, "%s %s : responseBody = %s", method, url, responseBody);
                return response.toBuilder().body(bodyData).build();
            } else {
//                log(configKey, "<--- END HTTP (%s-byte body)", bodyLength);
            }
        }

        log(configKey, "%s %s : no data", method, url);
        return response;
    }

    @Override
    protected void log(String configKey, String format, Object... args) {
        log.info(String.format(methodTag(configKey) + format, args));
    }
}
```

### 注册Spring Bean
```java
@Configuration
public class FeignLogConfiguration {

    @Bean
    public Logger logger() {
        return new FeignLogger();
    }

}
```

## References
