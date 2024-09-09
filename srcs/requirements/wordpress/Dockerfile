FROM alpine:3.18
ARG PHP_VERSION=8 \
	PHP_SUBVERSION=1 \
    DB_NAME \
    DB_USER \
    DB_PASS
RUN apk update && apk upgrade && apk add --no-cache \
    php${PHP_VERSION}${PHP_SUBVERSION} \
    php${PHP_VERSION}${PHP_SUBVERSION}-fpm \
    php${PHP_VERSION}${PHP_SUBVERSION}-mysqli \
    php${PHP_VERSION}${PHP_SUBVERSION}-json \
    php${PHP_VERSION}${PHP_SUBVERSION}-curl \
    php${PHP_VERSION}${PHP_SUBVERSION}-dom \
    php${PHP_VERSION}${PHP_SUBVERSION}-exif \
    php${PHP_VERSION}${PHP_SUBVERSION}-fileinfo \
    php${PHP_VERSION}${PHP_SUBVERSION}-mbstring \
    php${PHP_VERSION}${PHP_SUBVERSION}-openssl \
    php${PHP_VERSION}${PHP_SUBVERSION}-xml \
    php${PHP_VERSION}${PHP_SUBVERSION}-zip \
    php${PHP_VERSION}${PHP_SUBVERSION}-redis \
	wget \
	unzip && \
    sed -i "s|listen = 127.0.0.1:9000|listen = 9000|g" \
		/etc/php81/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner = nobody|listen.owner = nobody|g" \
		/etc/php81/php-fpm.d/www.conf && \
    sed -i "s|;listen.group = nobody|listen.group = nobody|g" \
		/etc/php81/php-fpm.d/www.conf && \
    rm -f /var/cache/apk/*
WORKDIR /var/www
RUN wget https://wordpress.org/latest.zip && \
    unzip latest.zip && \
    cp -rf wordpress/* . && \
    rm -rf wordpress latest.zip
COPY ./requirements/wordpress/conf/wp-config-create.sh .
RUN sh wp-config-create.sh && rm wp-config-create.sh && \
    chmod -R 0777 wp-content/
CMD ["php-fpm81", "-F"]