FROM alpine:3.19

ARG DB_NAME \
    DB_USER \ 
	DB_HOST

RUN apk update && apk upgrade && apk add --no-cache \
	php \
	php-fpm \
	php-mysqli \
	php-ctype \
	php-redis \
	wget \
	unzip && \
    sed -i "s|127.0.0.1|0.0.0.0|g" /etc/php82/php-fpm.d/www.conf && \
    sed -i "s|nobody|root|g" /etc/php82/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*

RUN wget https://wordpress.org/latest.tar.gz && \
	tar xvf latest.tar.gz && \
	mkdir -p /var/www/html/wordpress && \
	cp -r /wordpress/* /var/www/html/wordpress/

COPY ./requirements/wordpress/conf/wp-config-create.sh .

RUN --mount=type=secret,id=db_password \
	export DB_PASS=$(cat /run/secrets/db_password) && \
	sh wp-config-create.sh && \
	rm wp-config-create.sh && \
	chmod -R 0777 /var/www/html/wordpress/wp-content/ && \
	rm -rf /wordpress /latest.tar.gz

CMD ["php-fpm82", "-FR"]