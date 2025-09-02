# CORS 问题解决方案

## 问题描述
Flutter Web应用访问 `http://localhost:8081` 时遇到CORS错误：
```
Cross-Origin Resource Sharing error: MissingAllowOriginHeader
```

## 后端解决方案（推荐）

### 如果使用Spring Boot
在你的后端服务器添加CORS配置：

```java
@Configuration
public class CorsConfig {
    
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
```

或者在Controller上添加注解：
```java
@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
public class ProductCategoryController {
    // ... your endpoints
}
```

### 如果使用Express.js
```javascript
const cors = require('cors');
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));
```

### 如果使用其他框架
确保在响应头中添加：
```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization, Accept
```

## 临时客户端解决方案

### 方案1：Chrome 禁用安全策略（仅开发环境）
启动Chrome时添加参数：
```bash
chrome --disable-web-security --user-data-dir="/tmp/chrome_dev"
```

### 方案2：使用代理服务器
在 `web/index.html` 中添加代理配置，或使用nginx反向代理。

## 验证方法
1. 启动后端服务器
2. 在浏览器中直接访问：`http://localhost:8081/api/products/product-categories?current=1&pageSize=10`
3. 检查响应头是否包含CORS相关字段

## 当前Flutter配置
已经优化了客户端请求配置，但CORS问题必须在服务器端解决。
