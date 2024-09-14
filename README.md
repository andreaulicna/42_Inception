# 42_Inception

 This project is a System Administration related exercise.

### Creating a virtual machine
- save in `sgoinfre > goinfre` (network storage)
- create a virtual hard disk and keep the default setting (VDI) in the next step as it won't be used with other virtualization software
- dynamically allocated storage on a physical hard disk as it allocates only what is needed (and performance isn't necessarily that important)
- increase virtual hard disk size if planning on downloading GUI

### Installation of Debian and necessary software
- `sudo`: This package provides the `sudo` command, which allows users to run programs with the security privileges of another user (normally the superuser, or root).
- `ufw`: Uncomplicated Firewall (ufw) is a frontend for iptables and is particularly well-suited for host-based firewalls.
- `docker`: Docker is a platform that allows to develop, ship, and run applications inside containers. It's used for isolating applications in separate containers to have them run independently.
- `docker-compose`: Docker Compose is a tool for defining and running multi-container Docker applications. It uses YAML files to configure the application's services and performs the creation and start-up process of all the containers with a single command.
- `make`: The `make` utility helps in managing and maintaining groups of programs (including but not limited to compiling and linking). It's often used in software development to compile and build applications.
- `firefox-esr`: Firefox ESR (Extended Support Release) is a version of Firefox for organizations and other groups that need extended support for mass deployments. It's more stable and receives security updates longer than the standard version of Firefox.

### Port forwarding
- needs to be done on the guest machine (VM via `ufw allow`) and also redirecting traffic from host to the guest (in VM Settings > Network > Advanced > Port forwarding)
- alternatively, the 'Network' option 'Attached to' could be changed from 'NAT' to 'Bridge Adapter' to use the IP address of the VM for access

#### Ports overview:
- **Port 4241:4241**: SSH
- **Port 80:80**: This is the default port for HTTP (Hypertext Transfer Protocol). When visiting a website using http://, web browser communicates with the web server over this port unless specified otherwise.
- **Port 443:443**: This is the default port for HTTPS (HTTP Secure), which is HTTP over SSL/TLS. When visiting a website using https://, web browser communicates with the web server over this port. HTTPS encrypts the data for secure transmission, preventing data from being read in transit.


#### SSH
- `/etc/ssh/sshd_config`
  - Port: 4241
  - PermitRootLogin: prohibit-password
  - PubkeyAuthentication: yes
  - PasswordAuthentication: yes
<br>
- apply changes via restart:
  - `service ssh restart`
  - `service sshd restart`
  - `service ssh status`
<br>
- SSH, or Secure Shell, is a protocol used to securely connect to a remote server/system. It provides a secure channel over an unsecured network in a client-server architecture, allowing to run commands on a remote machine, transfer files, and more.
  - `ssh`: This is the client side of the protocol. When you use the `ssh` command in a terminal, you're using the SSH client to connect to an SSH server on a remote machine.
  - `sshd`: This stands for SSH daemon, and it's the server side of the protocol. The SSH daemon runs on the server and listens for connections from SSH clients. 

#### Ufw
- launch: `ufw enable`
- to open ports: `ufw allow [PORT]`
- check status: `ufw status`

### Docker
- show groups a user is in: `groups [USER]`
- add user to a group: `sudo usermod -aG [GROUP] [USER]`

### Certificates
- using utility `mkcert`
- changing local domain: adding `aulicna.42.fr` into `/etc/hosts` as a name for `127.0.0.1`
- generate certificates: run `mkcert aulicna.42.fr`in `srcs/requirements/tools/`
- change the file extension so that nginx can work with them:
  - `-key.pem` to `.key`
  - `.pem` to `.crt`
- edit `docker-compose.yml`:
  - add a new `volume`that maps the location of the generated certificate and key to where NGINX looks for it: `- /home/${USER}/42_Inception/srcs/requirements/tools:/etc/nginx/ssl`
  - have both `80:80` and `443:443` ports open
<br>
- **NGINX config**:
  
  - `listen 80; listen 443 ssl;`: Listen for connections on ports 80 (HTTP) and 443 (HTTPS). The server would be accessible via both HTTP and HTTPS with this setting, but 80 shoudl be commented out to allow only secure connection.
  
  - `server_name aulicna.42.fr www.aulicna.42.fr;`: Sets the server name to `aulicna.42.fr` and `www.aulicna.42.fr`. Nginx will respond to requests that are made to these domain names.
  
  - `root /var/www/html/wordpress;`: Sets the root directory for requests to `/var/www/html/wordpress`. This is the directory where Nginx will look for files to serve when it receives a request.
  
  - `ssl_certificate /etc/nginx/ssl/aulicna.42.fr.crt;`: Sets the path to the SSL certificate. This certificate is used to establish a secure connection with the client.
  
  - `ssl_certificate_key /etc/nginx/ssl/aulicna.42.fr.key;`: Sets the path to the SSL certificate key. This key is used in conjunction with the certificate to establish a secure connection.
  
  - `ssl_protocols TLSv1.2 TLSv1.3;`: Specifies the TLS protocols that Nginx should use for SSL. These protocols are used to secure the connection between the client and the server.
  
  - `ssl_session_timeout 10m;`: Sets the SSL session timeout to 10 minutes. This means that the secure connection will be kept alive for 10 minutes without activity before it's closed.
  
  - `keepalive_timeout 70;`: Sets the keep-alive timeout to 70 seconds. This means that the connection will be kept open for 70 seconds without activity before it's closed. This can help improve performance for clients that make multiple requests.
  
  - `location / { ... }`: Defines how to respond to requests for the root URL (`/`). The `try_files $uri /index.html;` line tells Nginx to try to serve the requested URI, and if that fails, to serve `/index.html`. This is useful for single-page applications where you want to serve the same HTML file for all routes.
  
### Docker containers
- NGINX: Proxy web server, port: 443
- PHP: Scripting language for the web
- Php-Fpm: A set of libraries for the FastCGI API, port: 9000
- Wordpress: Content Management System
- MariaDB: Relational database, port: 3306

<br>

**Docker containers vs Docker images**

A Docker image is a lightweight, standalone, and executable software package that includes everything needed to run a piece of software, including the code, runtime, libraries, environment variables, and configuration files. Docker images are used to create Docker containers, which are instances of these images running as isolated processes on a host operating system.

<br>

**Key characteristics of Docker images:**
- **Immutable**: Once created, a Docker image does not change. Any modifications result in the creation of a new image.
- **Layered**: Docker images are built in layers. Each layer represents a set of file changes or additions. Layers are cached and reused, making image builds efficient.
- **Portable**: Docker images can be shared and run on any system that supports Docker, ensuring consistency across different environments.

<br>

**Comands**:
- start: `docker-compose up -d` (The `-d` flag stands for "detached" mode - it starts the containers in the background. This means that the Docker containers start up and run without attaching to the current terminal session, allowing one to continue using the terminal for other commands while the containers are running. Without the `-d` flag, the container logs would be output to the terminal, and stopping the containers would require opening a new terminal session or stopping the containers with CTRL+C in the current session.)
- stop: `docker-compose down`


#### Docker container: NGINX

**Dockerfile**
```
FROM alpine:3.19											# specify the base image - penultimate stable version

RUN apk update && apk upgrade && apk add --no-cache nginx	# creates a new image layer resulting from the called command (similar to a VM snapshot)

EXPOSE 443													# open port for the container to exchange web traffic

CMD ["nginx", "-g", "daemon off;"]							# run the installed configuration
```

#### Docker container: MariaDB

**Dockerfile**
```
FROM alpine:3.19											# specify the base image - penultimate stable version

ARG DB_NAME \												# pass env variables saved in .env file
	DB_USER 

RUN apk update && apk add --no-cache mariadb mariadb-client # create a new image layer resulting from the called command (similar to a VM snapshot)

RUN mkdir /var/run/mysqld; \								# create directory for MariaDB's runtime data
    chmod 777 /var/run/mysqld; \							# change permission so that the directory is writable
    { echo '[mysqld]'; \									
      echo 'skip-host-cache'; \								# disable host cache
      echo 'skip-name-resolve'; \							# disable name resolution
      echo 'bind-address=0.0.0.0'; \						# listen on all network interfaces
    } | tee  /etc/my.cnf.d/docker.cnf; \					# create new config file with the above settings
    sed -i "s|skip-networking|skip-networking=0|g" \		# modify the config file to enable networking by adding "=0" to skip-networking
      /etc/my.cnf.d/mariadb-server.cnf

RUN mysql_install_db --user=mysql --datadir=/var/lib/mysql	# as user "mysql" initialize MariaDB database system tables in /var/lib/mysql using mysql_install_db

EXPOSE 3306													# open the default port for MariaDB/MySQL

COPY requirements/mariadb/conf/create_db.sh .				# copy a database initialization script from the host's tool directory to the current one inside the image

RUN --mount=type=secret,id=db_root_password \				# mount (attach storage) the secrets to the build process = way of passing sensitive information to the container during the build process
    --mount=type=secret,id=db_password \
	export DB_ROOT=$(cat /run/secrets/db_root_password) && \# export the secrets as environment variables for the subsequent script to have access to them - it is safe because the secrets will disappear along with the shell session that the building is happening in once it's done
	export DB_PASS=$(cat /run/secrets/db_password) && \
	sh create_db.sh && rm create_db.sh						# run the database initialization script and remove it afterward

USER mysql													# set running user for running subsequent commands and the container itself - security best practise not to run as root

CMD ["/usr/bin/mysqld", "--skip-log-error"]					# specify the default command to run once the container starts
```
<br>

**Dockerfile - further explanation**:
- **Why disable host cache and name resolution?**
  - Host Cache Disabling (`skip-host-cache`): The host cache in MariaDB/MySQL caches information about client connections. While this can speed up connection times for repeated connections from the same host, it can also introduce overhead and complexity, especially in environments where clients frequently connect and disconnect, or where connections come from a large number of distinct hosts. Disabling the host cache can reduce this overhead.
  - Name Resolution Disabling (`skip-name-resolve`): By default, MariaDB/MySQL performs reverse DNS lookups on client IP addresses to get hostnames, which are then used for permissions checks and possibly other operations. This can significantly slow down the connection process, especially if the DNS system is slow or misconfigured. Disabling name resolution forces MariaDB/MySQL to use IP addresses for client identification and permission checks, which can speed up connection times.
- **Why listen on all network interfaces?**
  - Container accessibility
  - Development and production flexibility 
- **Why enable networking?**
  - Container Communication: Essential for inter-container TCP/IP communication, allowing connections to MariaDB on port 3306.
  - Accessibility: Enables MariaDB server access from both within the Docker network and from external systems, crucial for management and backups.
  - Flexibility and Scalability: Allows for the MariaDB service to be scaled and relocated without configuration changes, supporting cloud-native principles.
  - Remote Management Compatibility: Ensures MariaDB can be managed using external tools, which require network connectivity to function.
- **Why to copy the initialization script?**
  - Automation: Automates the setup process of the MariaDB database when the container is started, ensuring that the database is ready to use without manual intervention.
  - Consistency: Ensures that every instance of the container starts with the same database configuration and data, which is crucial for consistency across different environments (development, testing, production).
  - Security: Allows for the configuration of security settings and user permissions in a controlled manner, reducing the risk of misconfiguration.
  - Customization: Provides a way to apply specific settings or tweaks required by the application that uses the database, which might not be possible through standard MariaDB configuration files alone.
<br>

**Script to create database**
```
#!bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]; then													# Check if the MySQL "mysql" system database directory does not exist
		chown -R mysql:mysql /var/lib/mysql													# Change ownership of the MySQL data directory to the mysql user and group
		mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysqil --rpm			# Initialize the MySQL data directory and create system tables
		tfile=`mktemp`																		# Create a temporary file and store its name in tfile
		if [ ! -f "$tfile" ]; then															# If the temporary file was not created successfully, exit with an error
				return 1
		fi
fi

if [ ! -d "/var/lib/mysql/wordpress" ]; then												# Check if the "wordpress" database does not exist
		cat << EOF > /tmp/create_db.sql														# Create a new SQL script file with commands to configure the MySQL server
USE mysql; 																					# Switch to the mysql system database
FLUSH PRIVILEGES; 																			# Reload the grant tables in memory
DELETE FROM     mysql.user WHERE User=''; 													# Remove anonymous users
DROP DATABASE test; 																		# Drop the default test database
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%'; 										# Remove privileges on test database
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); # Remove remote root access
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT}'; 									# Set the root password
CREATE DATABASE ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci; 						# Create the wordpress database with UTF-8 encoding
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}'; 									# Create a new user for wordpress
GRANT ALL PRIVILEGES ON wordpress.* TO '${DB_USER}'@'%'; 									# Grant all privileges on the wordpress database to the new user
FLUSH PRIVILEGES; 																			# Reload the grant tables in memory
EOF
		/usr/bin/mysqld --user=mysql --bootstrap < /tmp/create_db.sql						# Execute the SQL script using mysqld with bootstrap option for initial setup
		rm -f /tmp/create_db.sql															# Remove the temporary SQL script file
fi
```

The script performs several steps to ensure the MySQL (MariaDB) database is properly initialized and configured for a WordPress application:

1. **Check for the MySQL system database directory**: This step ensures that the database initialization process only runs if the MySQL system database hasn't already been initialized. It prevents re-initialization and potential data loss or corruption.

2. **Change ownership of the MySQL data directory**: This ensures that the directory has the correct permissions for the MySQL service to operate, addressing potential security and access issues.

3. **Initialize the MySQL data directory**: This creates the necessary system tables and other initial setup requirements for MySQL to function. It's a crucial step for a new database environment.

4. **Create a temporary file**: This is likely used as a flag or for temporary storage during the initialization process. The script checks for its successful creation to ensure the environment is writable and functioning as expected.

5. **Create a new SQL script file with configuration commands**: This step involves setting up the MySQL server with specific configurations for the WordPress application, including security settings (like removing anonymous users and test databases) and creating the WordPress database with appropriate character encoding.

6. **Execute the SQL script**: This applies the configurations and setups defined in the SQL script. It's done using the `mysqld --bootstrap` option, which is intended for initial setup and configuration tasks.

7. **Remove the temporary SQL script file**: Cleans up the temporary file to maintain a clean environment and ensure that sensitive information (like passwords) isn't left accessible on the filesystem.

#### Docker container: Wordpress
**Dockerfile**
- What is needed:
  - PHP with plugins for Wordpress
  - php-fpm for communication with NGINX
  - Wordpress itself

```
FROM alpine:3.19
    DB_NAME \												# specify arguments saved in .env (ARG instruction)
    DB_USER \
	DB_HOST

RUN apk update && apk upgrade && apk add --no-cache \		# the usual + list of components:
    php \													# php which wordpress runs on
    php-fpm \												# php-fpm manages interaction with nginx
    php-mysqli \											# required php extension: manages interaction with mariadb (alternative: mysqlnd)
	php-ctype \
    php-redis \												# needed for bonus: interface with Redis
    wget \													# needed to download wordpress itself
    unzip \													# unzip the archive with downloaded wordpress
	sed -i "s|127.0.0.1|0.0.0.0|g" \						# set www.conf, so that the fastCGI listens to all connections on port 9000
    /etc/php82/php-fpm.d/www.conf \
    sed -i "s|nobody|root|g" \
    /etc/php82/php-fpm.d/www.conf \
    && rm -f /var/cache/apk/*								# clear cache of installed modules

RUN wget https://wordpress.org/latest.tar.gz && \
	tar xvf latest.tar.gz && \
	mkdir -p /var/www/html/wordpress && \
	cp -r /wordpress/* /var/www/html/wordpress/
	
COPY ./conf/wp-config-create.sh .							# copy configuration file

RUN --mount=type=secret,id=db_password \					# mount (attach storage) the secrets to the build process = way of passing sensitive information to the container during the build process
	export DB_PASS=$(cat /run/secrets/db_password) && \		# export the secrets as environment variables for the subsequent script to have access to them - it is safe because the secrets will disappear along with the shell session that the building is happening in once it's done
	sh wp-config-create.sh && \								# run wordpress initialization script and delete it afterwards
	rm wp-config-create.sh && \
	chmod -R 0777 /var/www/html/wordpress/wp-content/ && \	# give all users rights to the wp-content folder - management of themes, plugins, and other files
	rm -rf /wordpress /latest.tar.gz						
CMD ["php-fpm82", "-F"]										# launch installed php-fpm
```

**Dockerfile - further explanation**:
- **Why to install these PHP extensions?**
  - The list of extensions is from the Wordpress documentation. Really just the ones needed to get things working are installed.

**Tests to check that Wordpress works**
- `docker exec -it wordpress ps aux | grep 'php'`: lists the processes related to PHP running inside the container
  - there should be 3 processes (one master and one worker) running and the output is going to have the following format:
  ```
  [PID] [user running the process] [CPU time used by the process] [the commnad executed to run the process] [description of whether it is a master or worker process] 
  ```
  - `nobody` is an actual user on Unix-like operating systems:
    - <ins>minimal privileges</ins>: The `nobody` user has very limited permissions and is not allowed to perform administrative tasks or access sensitive files.
    - <ins>security</ins>: Running processes as `nobody` helps to contain the impact of security vulnerabilities. If a process running as `nobody` is compromised, the attacker gains very limited access to the system.
    - <ins>common usage</ins>: It is commonly used for running web servers, network services, and other applications that do not require elevated privileges.
  - master process: manages worker processes and has higher privileges (e.g., `root`).
    - starts, stops, and monitors worker processes
    - reads configuration files
	- handles system signals
  - worker process: handles actual workload (e.g., processing requests) and has lower privileges (e.g. `nobody`)
    - executes tasks assigned by the master process
    - processes incoming requests
    - performs computations or data retrieval

<br>

### BONUS
#### Redis cache
**Dockerfile**
```
FROM alpine:3.19															# specify the base image - penultimate stable version

RUN apk update && apk upgrade && \											# update package list
    apk add --no-cache redis && \											# install without caching the package index to save space
    sed -i "s|bind 127.0.0.1|#bind 127.0.0.1|g"  /etc/redis.conf && \		# comments out the `bind 127.0.0.1` line in the Redis config file to allow connection from any IP address
    sed -i "s|# maxmemory <bytes>|maxmemory 20mb|g"  /etc/redis.conf && \	# set maximum memory usage for Redis to 20MB
    sed -i "s|protected-mode yes|protected-mode no|g"  /etc/redis.conf && \	# disabling protected mode is necessary to allow Wordpress caching plugin to access Redis server (which is now open to be accessed from external source)
    echo "maxmemory-policy allkeys-lru" >> /etc/redis.conf					# append the `maxmemory-policy allkeys-lru` setting to the Redis configuration file, which specifies that Redis should remove the least recently used keys when the maximum memory is reached

EXPOSE 6379																	# expose port 6379 which is the default port for Redis

CMD [ "redis-server" , "/etc/redis.conf" ]									# specify the command to run when the container starts -> runs the Redis server using modified configuration file located at /etc/redis.conf
```

**Dockerfile - further explanation**:
- **Why install with `--no-cache`?**
  - Smaller image size, so faster to build, pull and deploy.
  - By not caching, the package list will always stay up-to-date.
  - Cleaner image as unnecessary files that are needed only during the build process are not included.
- **Why comment out the 127 bind?**
  - Useful when needed assess from a different machine, e.g. web server or another application server
  - Other containers can connect to the Redis container
- **Why is the max. memory size set to 20MB?**
  - We're in an environment with limited resources - VM.
  - More space is realistically not needed for this project.
- **How is Redis secure if we dissable protected mode to allow access from external sources to the Redis server?**
  - When the setting is disables, Redis could be secured by other means, such as firewall rules, authentication, or running in a trusted network environment. 


#### FTP server
```
FROM alpine:3.19																				# specify the base image - penultimate stable version

ARG FTP_USER																					# specify arguments saved in .env (ARG instruction)

RUN apk update && apk upgrade && \
    apk add --no-cache vsftpd

RUN --mount=type=secret,id=ftp_password \ 														# mount (attach storage) the secrets to the build process = way of passing sensitive information to the container during the build process
	export FTP_PASS=$(cat /run/secrets/ftp_password) && \										# export the secrets as environment variables for the subsequent script to have access to them - it is safe because the secrets will disappear along with the shell session that the building is happening in once it's done
	adduser -h /var/www -s /bin/false -D ${FTP_USER} && \										# create a new user to connect to the server, no shell acess so that it is purely for FTP access = security measure
    echo "${FTP_USER}:${FTP_PASS}" | /usr/sbin/chpasswd && \									# set the password for the user based on the provided argument
    adduser ${FTP_USER} root																	# add user to the root group so that they have access to process the wordpress directory	

RUN sed -i "s|#chroot_local_user=YES|chroot_local_user=YES|g"  /etc/vsftpd/vsftpd.conf && \		# configuration change: enable chroot for local users = security measure where each user is limited to their own home directory
    sed -i "s|#local_enable=YES|local_enable=YES|g"  /etc/vsftpd/vsftpd.conf && \				# configuration change: enable local user login = security measure where only users with valid credentials can access the FTP server (no anonymous users)
    sed -i "s|#write_enable=YES|write_enable=YES|g"  /etc/vsftpd/vsftpd.conf && \				# configuration change: allow write permissions for local users
    sed -i "s|#local_umask=022|local_umask=007|g"  /etc/vsftpd/vsftpd.conf						# configuration change: set local file mask to 007, meaning that new files will have permissions 770 (owner, group, others)

RUN echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf &&\							# additional configuration: allow writable chroot directories - default is that chroot directories (the home directory the users are restricted to) are not writable, but we want them to be (e.g. uploading a file to home directory)
    echo 'seccomp_sandbox=NO' >> /etc/vsftpd/vsftpd.conf && \									# additional configuration: disable seccomp sandboxing - could cause issues if enabled as it is a Linux kernal feature that rescricts the system calls a process can make
    echo 'pasv_enable=YES' >> /etc/vsftpd/vsftpd.conf											# additional configuration: enable passive mode - improves compatibility with clients behind firewalls as it allows them to establish connection (both control and data connection)

WORKDIR /var/www																				# set working directory

EXPOSE 21																						# expose port 21 which is the default port for FTP	

CMD [ "/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf" ]											# specify command to run when container starts -> runs vsftpd with the specified configuration file
```

#### Adminer
Adminer is a full-featured database management tool written in PHP. It is a lightweight alternative to tools like phpMyAdmin and provides a web-based interface to manage databases. 

**Key Features:**
- **Single File**: Adminer is distributed as a single PHP file, making it easy to deploy and use.
- **Lightweight**: It is designed to be lightweight and fast, with a minimal footprint.
- **Security**: Adminer includes several security features to protect against common web vulnerabilities.
- **User-Friendly Interface**: It provides an intuitive and user-friendly interface for managing databases.

**Common Use Cases:**
- **Database Management**: Adminer allows users to perform various database management tasks such as creating, modifying, and deleting databases, tables, and records.
- **SQL Execution**: Users can execute SQL queries directly through the Adminer interface.
- **Backup and Restore**: Adminer provides options to export and import database data, making it useful for backup and restore operations

```
FROM alpine:3.19 										# specify the base image - penultimate stable version

RUN apk update && apk upgrade && apk add --no-cache \
	php \           									# PHP interpreter: Required to run PHP scripts.
	php-mysqli \    									# PHP extension for MySQL: Enables PHP to interact with MySQL databases.
	php-session \   									# allows PHP to manage user sessions
	wget            									# Utility to download files from the web: Used to download the Adminer script.

WORKDIR /var/www

RUN wget https://www.adminer.org/latest.php && \		# download adminer
    mv latest.php index.php && chmod -R 644 /var/www	# rename the downloaded file to make it easier to access via a web server as index.php is typically the default file and change permission for the web server to have access

EXPOSE 8081												# container will listen on this port at runtime

CMD [ "php", "-S", "[::]:8081", "-t", "/var/www" ]		# start the built-in web server
```

#### cAdvisor

cAdvisor (Container Advisor) is an open-source tool developed by Google for monitoring and analyzing resource usage and performance characteristics of running containers. It provides real-time monitoring of various metrics such as CPU, memory, network, and disk usage for containers.

**Key Features:**
- **Resource Usage Metrics**: Collects and displays metrics for CPU, memory, network, and disk usage.
- **Container Management**: Supports Docker containers and integrates with Kubernetes.
- **Web Interface**: Provides a web-based interface for visualizing metrics.
- **Historical Data**: Stores historical data for analysis and troubleshooting.
- **API**: Exposes an API for accessing metrics programmatically.

**Common Use Cases:**
- **Performance Monitoring**: Helps in monitoring the performance of containers in real-time.
- **Resource Management**: Assists in managing and optimizing resource allocation for containers.
- **Troubleshooting**: Useful for diagnosing performance issues and bottlenecks in containerized applications.
- **Integration with Monitoring Systems**: Can be integrated with other monitoring and alerting systems like Prometheus and Grafana.

```
FROM alpine:3.19																						# specify the base image - penultimate stable version

RUN apk update && apk upgrade && apk add --no-cache \											
	wget
RUN wget https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 && \	# download, rename and make executable
    mv cadvisor-v0.49.1-linux-amd64 cadvisor && \ 
    chmod +x cadvisor

CMD ["./cadvisor", ""]																					# run the program
```


<br>

### Tests to check that everything works
#### Overall
`docker ps`: show running containers
`docker image ls`: show existing docker images
`docker image history ls`: show how the docker images were built (reveals password passed as arguments)
`docker image history --no-trunc ls`: show how the docker images were built with full message (reveals password passed as arguments)

#### NGINX and Wordpress
- check PHP version inside the container: `docker exec -it wordpress php -v`
- lists all installed modules -> should correspond with what we have in the Dockerfile + dependencies that get installed automatically: `docker exec -it wordpress php -m`
- browse the website

#### MariaDB

**Verify correct translation of passwords for `root` and `wpuser` users passed as secrets:**
```
docker exec -it mariadb mysql			#executes a command inside a running container - run mysql client command-line tool to access the database
show databases;							#show databases that we have in the containers
user mysql;								#switch to the correct database
select user,password,host from user;	#show the list of users in the database
```
<br>

**FAQ**
- **Why is mysql user's password "invalid"?**
  - https://stackoverflow.com/questions/59537896/mysql-user-has-password-invalid-is-this-the-normal-thing
- **.env vs secrets**
  - .env is to store non-sensitive data because with command `docker image history mariadb` we can see the value of passwords if they are passed as ARG in the Dockerfile

#### FTP
- install (filezilla) FTP client: `sudo apt install -y filezilla`
- upload and download files
- shell into the docker to verify the existence of uploaded files: `docker exec -it vsftpd sh`
- downloaded files get saved in the home directory of the host machine

#### Redis
```
docker exec -it redis redis-cli	#enter the Redis command-line interface 
ping							#ping the server -> the answer should be "PONG"
monitor							#should start by saying "OK" and then open an interactive terminal session listing all the commands (e.g. GET requests) being processed by the Redis server in real-time as the user browses the website
```

#### Adminer
- visit `[localhost/ IP address]:8081`
- login with to server `mariadb` with user `wpuser`
- on the left select `DB` `wordpress` (exists only once Wordpress has been installed)
- browse the database

#### cAdvisor
- visit `[localhost/ IP address]:8080`

#### Website
- visit `[localhost/ IP address]:4242`