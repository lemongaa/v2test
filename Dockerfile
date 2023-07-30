# 使用官方 PHP 7.4 Apache 镜像作为基础镜像
FROM php:7.4-apache

# 安装 MySQLi 扩展，v2board 需要此扩展来连接 MySQL 数据库
RUN docker-php-ext-install mysqli pdo pdo_mysql

# 安装 Git，用于下载 v2board 项目
RUN apt-get update && apt-get install -y git

# 切换到 /var/www 目录，并克隆 v2board 项目
WORKDIR /var/www
RUN git clone https://github.com/v2board/v2board.git .

# 安装 Composer，v2board 项目需要它来管理 PHP 依赖
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# 默认环境变量定义
ENV DB_CONNECTION=default_value
ENV DB_HOST=default_value
ENV DB_PORT=default_value
ENV DB_DATABASE=default_value
ENV DB_USERNAME=default_value
ENV DB_PASSWORD=default_value

# 根据环境变量修改 .env 文件
RUN sed -i "s/DB_CONNECTION/$DB_CONNECTION/" .env
RUN sed -i "s/DB_HOST/$DB_HOST/" .env
RUN sed -i "s/DB_PORT/$DB_PORT/" .env
RUN sed -i "s/DB_DATABASE/$DB_DATABASE/" .env
RUN sed -i "s/DB_USERNAME/$DB_USERNAME/" .env
RUN sed -i "s/DB_PASSWORD/$DB_PASSWORD/" .env

# 设置 Apache 的文档根目录为 v2board 的 public 目录
ENV APACHE_DOCUMENT_ROOT /var/www/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf

# 修改文件权限，使得 Apache 可以读写 v2board 的 storage 和 bootstrap/cache 目录
RUN chown -R www-data:www-data storage bootstrap/cache
