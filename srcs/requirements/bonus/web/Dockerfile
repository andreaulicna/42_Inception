FROM alpine:3.19

RUN apk update && apk upgrade && apk add --no-cache \
	nginx

RUN echo "server {" > /etc/nginx/http.d/default.conf && \
	echo "listen 4242;" >> /etc/nginx/http.d/default.conf && \
	echo "root /var/www;" >> /etc/nginx/http.d/default.conf && \
	echo "location / {" >> /etc/nginx/http.d/default.conf && \
	echo "	try_files \$uri /index.html;" >> /etc/nginx/http.d/default.conf && \
	echo "	}}" >> /etc/nginx/http.d/default.conf

COPY requirements/bonus/web/conf/* /var/www/ 

EXPOSE 4242

CMD ["nginx", "-g", "daemon off;"]