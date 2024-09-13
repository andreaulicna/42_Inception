FROM alpine:3.19

RUN apk update && apk upgrade && apk add --no-cache \
    php \
	php-mysqli \
	php-session \
    wget

WORKDIR /var/www

RUN wget https://www.adminer.org/latest.php && \
    mv latest.php index.php && chmod -R 644 /var/www

EXPOSE 8081

CMD	[ "php", "-S", "[::]:8081", "-t", "/var/www" ]