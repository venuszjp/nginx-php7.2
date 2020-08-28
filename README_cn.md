# Nginx and PHP7.4 for Docker

English | [简体中文](./README_CN.md)

# Last Version
NGINX: **1.19.1**   
PHP:   **7.2.32**

# Docker 镜像
**Nginx-PHP7:** [https://hub.docker.com/r/zjpvenus/nginx-php7](https://hub.docker.com/r/zjpvenus/nginx-php7)   

**[Documents](https://github.com/AugustSunshine/nginx-php7)**

# 构建
```sh
git clone https://github.com/AugustSunshine/nginx-php7.git
cd nginx-php7
docker build -t zjpvenus/nginx-php7:<tag> .
```

# 安装使用
从 Docker 拉取镜像。这样可以防止你每次都要构建。

```sh   
docker pull zjpvenus/nginx-php7:latest
```

# 运行
使用镜像启动基础容器

```sh
docker run --name nginx -p 80:80 -d zjpvenus/nginx-php7
```
你可以通过浏览器访问 ```http://<docker_host>``` 查看 PHP 配置信息。

# 添加自定义目录
如果你想自定义网站目录，你可以使用以下方式启动。

```sh
docker run --name nginx -p 80:80 -v /your_code_directory:/data/wwwroot -d zjpvenus/nginx-php7
```

<details>
    <summary><mark>More</mark></summary>

```
docker run --name nginx -p 80:80 \
-v /your_code_directory:/data/wwwroot \
-v /your_nginx_log_path:/data/wwwlogs \
-v /your_nginx_conf_path:/data/server/nginx \
-v /your_php_extension_ini:/data/server/php/ini \
-v /your_php_extension_file:/data/server/php/extension \
-d zjpvenus/nginx-php7
```

# 添加 PHP 扩展
添加 **ext-xxx.ini** 到你的自定义配置目录 ```/your_php_extension_ini```, 相应的扩展文件代码到你的 ```/your_php_extension_file```. 运行以下命令运行你的容器:
```sh
docker run --name nginx \
-p 80:80 -d \
-v /your_php_extension_ini:/data/server/php/ini \
-v /your_php_extension_file:/data/server/php/extension \
zjpvenus/nginx-php7
```

**/your_php_extension_ini/ext-xxx.ini** 文件示例:   
```
extension=redis
```

**/your_php_extension_file/extension.sh** 文件示例:   
```
curl -Lk https://github.com/swoole/swoole-src/archive/v4.4.14.tar.gz | gunzip | tar x -C /home/extension && \
cd /home/extension/swoole-src-4.4.14 && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install
```

</details>

# 许可证
This project is licensed under the [MIT license](https://github.com/skiy/nginx-php7/blob/master/LICENSE).   

# 感谢
<a href="https://www.jetbrains.com/?from=nginx-php7" target="_blank"><img src="https://camo.githubusercontent.com/d4143cfccf26532a30c578a2689bafcc5aa41572/68747470733a2f2f676f6672616d652e6f72672f696d616765732f6a6574627261696e732e706e67" width="100" alt="JetBrains"/></a>