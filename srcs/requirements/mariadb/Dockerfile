FROM alpine:3.19

ARG DB_NAME \
    DB_USER 

RUN apk update && apk add --no-cache mariadb mariadb-client

RUN mkdir /var/run/mysqld; \
    chmod 777 /var/run/mysqld; \
    { echo '[mysqld]'; \
      echo 'skip-host-cache'; \
      echo 'skip-name-resolve'; \
      echo 'bind-address=0.0.0.0'; \
    } | tee  /etc/my.cnf.d/docker.cnf; \
    sed -i "s|skip-networking|skip-networking=0|g" \
      /etc/my.cnf.d/mariadb-server.cnf

RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql

EXPOSE 3306

COPY requirements/mariadb/conf/create_db.sh .
RUN --mount=type=secret,id=db_root_password \
    --mount=type=secret,id=db_password \
	export DB_ROOT=$(cat /run/secrets/db_root_password) && \
	export DB_PASS=$(cat /run/secrets/db_password) && \
#	echo $DB_ROOT >> test.txt && \
#	echo $DB_PASS >> test.txt && \
	sh create_db.sh

USER mysql
CMD ["/usr/bin/mysqld", "--skip-log-error"]
