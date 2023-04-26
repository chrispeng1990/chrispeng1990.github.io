---
weight: 200
title: "使用Github作为Maven库"
---

## 1. 创建Github Maven Repository
[https://www.github.com](https://www.github.com)  


## 2. 创建Github免密token
Settings -> Development Settings  
![](/images/DX-20230425@2x.png)  


## 3. 配置Maven Github链接
```bash
vim ~/.m2/settings.xml
```
两种方式:  
1. 通过账号密码的形式  
```xml
<server>
   <id>github</id>
    <username>YOUR_USERNAME</username>
    <password>YOUR_PASSWORD</password>
</server>
```
2. 通过免密token  
```xml
<server>
    <id>github</id>
    <password>OAUTH2TOKEN</password>
</server>
```

## 4. 创建待上传的库项目
eg: org.test:testrepo


## 5. 配置Maven插件生成依赖包格式输出到本地
```bash
vim testrepo/pom.xml
```
```xml
<project>
  <distributionManagement>
    <repository>
      <id>maven.repo</id>
      <name>Local Staging Repository</name>
      <!-- 生成到${project}/target/mvn-repo目录下 -->
      <url>file://${project.build.directory}/mvn-repo</url>
    </repository>
  </distributionManagement>
  
  <build>
    <plugins>
      <plugin>
        <artifactId>maven-deploy-plugin</artifactId>
        <version>2.8.1</version>
        <configuration>
          <altDeploymentRepository>maven.repo::default::file://${project.build.directory}/mvn-repo</altDeploymentRepository>
        </configuration>
      </plugin>
    </plugins>
  </build>
        
</project>
```

## 6. 配置Maven插件将本地输出上传到Github
```bash
vim testrepo/pom.xml
```
```xml
<project>
  <properties>
    <!-- 引用settings.xml中的配置 -->
    <github.global.server>github</github.global.server>
  </properties>
  
  <build>
    <plugins>
      <plugin>
        <groupId>com.github.github</groupId>
        <artifactId>site-maven-plugin</artifactId>
        <version >0.12</version>
        <configuration>
          <!-- 提交依赖库的commit message -->
          <message>Maven artifacts for ${project.version}</message>
          <noJekyll>true</noJekyll>
          <!-- 本地jar地址 -->
          <outputDirectory>${project.build.directory}/mvn-repo</outputDirectory>
          <!-- 分支的名称 -->
          <branch>refs/heads/master</branch>
          <merge>true</merge>
          <includes>
            <include>**/*</include>
          </includes>
          <!-- github 仓库所有者即登录用户名或组织名 -->
          <repositoryOwner>nctsc</repositoryOwner>
          <!-- 对应github上创建的仓库名称 name -->
          <repositoryName>maven-repository</repositoryName>
        </configuration>
        <executions>
          <execution>
            <goals>
              <goal>site</goal>
            </goals>
            <phase>deploy</phase>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
```


## 7. 打包部署
```bash
mvn deploy
```


## 8. 使用方式
```xml
<project>
  <dependencies>
    <dependency>
      <groupId>cp.mvnrepo</groupId>
      <artifactId>testmvnrepo</artifactId>
      <version>1.0-SNAPSHOT</version>
    </dependency>
  </dependencies>
  
  <repositories>
    <repository>
      <id>nctsc</id>
      <url>https://raw.github.com/nctsc/maven-repository/</url>
    </repository>
  </repositories>
</project>
```


## References
[Github/nstsc/maven-repository](https://github.com/nctsc/maven-repository)  
[使用site-maven-plugin在github上搭建公有仓库](https://developer.aliyun.com/article/899375)  
[GitHub上创建自己的Maven仓库并引用](https://blog.csdn.net/sunxiaoju/article/details/85331265#commentsedit)  

