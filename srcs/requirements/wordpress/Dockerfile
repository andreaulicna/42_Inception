FROM alpine:3.19

ARG DB_NAME \
    DB_USER \
    DB_PASS \
	DB_HOST

RUN apk update && apk upgrade && apk add --no-cache \
	php \
	php-fpm \
	php-mysqli \
	wget \
	unzip && \
    sed -i "s|127.0.0.1|0.0.0.0|g" /etc/php82/php-fpm.d/www.conf && \
    sed -i "s|nobody|root|g" /etc/php82/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*

RUN wget https://wordpress.org/latest.tar.gz && \
	tar xvf latest.tar.gz && \
	mkdir -p /var/www/html/wordpress && \
	cp -r /wordpress/* /var/www/html/wordpress/

COPY ./conf/wp-config-create.sh .

RUN sh wp-config-create.sh && \
	rm wp-config-create.sh && \
	chmod -R 0777 /var/www/html/wordpress/wp-content/ && \
	rm -rf /wordpress /latest.tar.gz

CMD ["php-fpm82", "-FR"]