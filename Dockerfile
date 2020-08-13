FROM centos:7
MAINTAINER Venus http://www/zhujp.net

# set environments
ENV NGINX_VERSION 1.19.1
ENV PHP_VERSION 7.2.32

ENV PRO_SERVER_PATH=/data/server
ENV NGX_WWW_ROOT=/data/wwwroot
ENV NGX_LOG_ROOT=/data/wwwlogs
ENV PHP_EXTENSION_INI_PATH=/data/server/php/ini

WORKDIR $NGX_WWW_ROOT

## mkdir folders
RUN mkdir -p /data/{wwwroot,wwwlogs,server/php/ini,}

# 自定义PHP扩展配置文件
ADD extension.ini $PHP_EXTENSION_INI_PATH/

RUN yum install -y epel-release

## install libraries
RUN set -x && \
yum clean all && \
rm -rf /var/cache/yum/* && \
yum install -y gcc \
gcc-c++ \
autoconf \
automake \
libtool \
make \
cmake \
#
# install PHP libraries
zlib \
zlib-devel \
openssl \
openssl-devel \
pcre-devel \
sqlite-devel \
libxml2 \
libxml2-devel \
libcurl \
libcurl-devel \
libpng-devel \
libjpeg-devel \
freetype-devel \
libmcrypt-devel \
oniguruma oniguruma-devel \
openssh-server \
vim && \
#
# make folder
mkdir -p /home/nginx-php && \
# install nginx
curl -Lk https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
cd /home/nginx-php/nginx-$NGINX_VERSION && \
./configure --prefix=/usr/local/nginx \
--user=www --group=www \
--error-log-path=${NGX_LOG_ROOT}/nginx_error.log \
--http-log-path=${NGX_LOG_ROOT}/nginx_access.log \
--pid-path=/var/run/nginx.pid \
--with-pcre \
--with-http_ssl_module \
--with-http_v2_module \
--without-mail_pop3_module \
--without-mail_imap_module \
--with-http_gzip_static_module && \
make && make install && \
# add user
useradd -r -s /sbin/nologin -d ${NGX_WWW_ROOT} -m -k no www
#
# install php
# 下载PHP很慢的话可以考虑用ADD的方式
RUN set -x && \
curl -Lk https://php.net/distributions/php-$PHP_VERSION.tar.gz | gunzip | tar x -C /home/nginx-php && \
# ADD php-$PHP_VERSION.tar.gz /home/nginx-php
cd /home/nginx-php/php-$PHP_VERSION && \
./configure --prefix=/usr/local/php \
--with-config-file-path=/usr/local/php/etc \
--with-config-file-scan-dir=${PHP_EXTENSION_INI_PATH} \
--with-fpm-user=www \
--with-fpm-group=www \
--with-mysqli \
--with-pdo-mysql \
--with-openssl \
--with-iconv \
--with-zlib \
--with-gettext \
--with-curl \
--with-xmlrpc \
--with-mhash \
--enable-fpm \
--enable-xml \
--enable-shmop \
--enable-sysvsem \
--enable-inline-optimization \
--enable-mbregex \
--enable-mbstring \
--enable-ftp \
--enable-mysqlnd \
--enable-pcntl \
--enable-sockets \
--enable-soap \
--enable-session \
--enable-opcache \
--enable-bcmath \
--enable-exif \
--enable-fileinfo \
--disable-rpath \
--enable-ipv6 \
--disable-debug \
--without-pear && \
make && make install && \
#
# install php-fpm
cp php.ini-development /usr/local/php/etc/php.ini && \
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf && \
cp /usr/local/php/etc/php-fpm.d/www.conf.default /usr/local/php/etc/php-fpm.d/www.conf && \
#
# mkdir php extension dir
mkdir -p /usr/src/php/ext && \
#
# install gd freetype
curl -Lk http://ftp.twaren.net/Unix/NonGNU/freetype/freetype-2.10.2.tar.gz | gunzip | tar x -C /home/nginx-php && \
mv /home/nginx-php/freetype-2.10.2 /usr/src/php/ext/freetype && \
cd /usr/src/php/ext/freetype && \
./configure --prefix=/usr/local/freetype && \
make && make install && \
cd /home/nginx-php/php-$PHP_VERSION/ext/gd && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config --with-freetype-dir=/usr/local/freetype && \
make && make install && \
#
# install redis
curl -Lk https://github.com/phpredis/phpredis/archive/3.1.6.tar.gz | gunzip | tar x -C /home/nginx-php && \
mv /home/nginx-php/phpredis-3.1.6 /usr/src/php/ext/redis && \
cd /usr/src/php/ext/redis && \
/usr/local/php/bin/phpize && \
./configure --with-php-config=/usr/local/php/bin/php-config && \
make && make install && \
# php command support
ln -s /usr/local/php/bin/* /bin/
#
# remove temp folder
# rm -rf /home/nginx-php && \
#
# clean os
# RUN yum remove -y gcc \
# gcc-c++ \
# autoconf \
# automake \
# libtool \
# make \
# cmake && \

VOLUME ["/data/wwwroot", "/data/wwwlogs", "/data/server/php/ini", "/data/server/nginx"]

# NGINX
ADD nginx.conf /usr/local/nginx/conf/
ADD vhost /usr/local/nginx/conf/vhost

ADD www ${NGX_WWW_ROOT}

# Start
# ！注意 entrypoint.sh 文件换行符要用Unix line (LF)
# 不然执行会报以下错误（反正我是遇到了）
# Docker error: standard_init_linux.go:185: exec user process caused “no such file or directory”
ADD entrypoint.sh /
RUN chown -R www:www ${NGX_WWW_ROOT} && \
chmod +x /entrypoint.sh && \
yum clean all && \
rm -rf /tmp/* /var/cache/{yum,ldconfig} /etc/my.cnf{,.d} && \
mkdir -p --mode=0755 /var/cache/{yum,ldconfig} && \
find /var/log -type f -delete

# Set port
EXPOSE 80 443

# CMD ["/usr/local/php/sbin/php-fpm", "-F", "daemon off;"]
# CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]

# Start it
ENTRYPOINT ["/entrypoint.sh"]