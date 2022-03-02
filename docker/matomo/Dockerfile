# FROM matomo:4.5.0-fpm-alpine
FROM  cr.zbxsoft.com/3rd/matomo:4.5.0-fpm-alpine

# 复制配置文件
COPY config.ini.php /var/www/html/config/config.ini.php

# 引入 IP 地址库，用于显示 IP 对应的城市
COPY mmdb/GeoLite2-ASN.mmdb /var/www/html/misc/GeoLite2-ASN.mmdb
COPY mmdb/GeoLite2-City.mmdb /var/www/html/misc/GeoLite2-City.mmdb
COPY mmdb/GeoLite2-Country.mmdb /var/www/html/misc/GeoLite2-Country.mmdb
