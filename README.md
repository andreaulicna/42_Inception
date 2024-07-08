# 42_Inception

 This project is a System Administration related exercise.

### Creating a virtual machine
- save in `sgoinfre > goinfre` (network storage)
- 4 GB should more than do for the project given its requirements
- create a virtual hard disk and keep the default setting (VDI) in the next step as it won't be used with other virtualization software
- dynamically allocated storage on a physical hard disk as it allocates only what is needed (and performance isn't necessarily that important)
- virtual hard disk size left to default (8 GB)

### Installation of Debian and necessary software
- `sudo`: This package provides the `sudo` command, which allows users to run programs with the security privileges of another user (normally the superuser, or root).
- `ufw`: Uncomplicated Firewall (ufw) is a frontend for iptables and is particularly well-suited for host-based firewalls.
- `docker`: Docker is a platform that allows you to develop, ship, and run applications inside containers. It's used for isolating your applications in separate containers to have them run independently.
- `docker-compose`: Docker Compose is a tool for defining and running multi-container Docker applications. It uses YAML files to configure the application's services and performs the creation and start-up process of all the containers with a single command.
- `make`: The `make` utility helps in managing and maintaining groups of programs (including but not limited to compiling and linking). It's often used in software development to compile and build applications.
- `openbox`: Openbox is a lightweight and highly configurable window manager with extensive standards support. 
- `xinit`: The `xinit` program allows a user to manually start an Xorg display server. The x-server is responsible for graphics in Linux and can be launched via `startx`.
- `firefox-esr`: Firefox ESR (Extended Support Release) is a version of Firefox for organizations and other groups that need extended support for mass deployments. It's more stable and receives security updates longer than the standard version of Firefox.

### Port forwarding
- needs to be done on the guest machine (VM via `ufw allow`) and also redirecting traffic from host to the guest (in VM Settings > Network > Advanced > Port forwarding)

#### Ports overview:
- **Port 4241:42**: SSH
- **Port 80:80**: This is the default port for HTTP (Hypertext Transfer Protocol). When you visit a website using http://, your web browser communicates with the web server over this port unless specified otherwise.

- **Port 443:443**: This is the default port for HTTPS (HTTP Secure), which is HTTP over SSL/TLS. When you visit a website using https://, your web browser communicates with the web server over this port. HTTPS encrypts the data for secure transmission, preventing data from being read in transit.


#### SSH
- `/etc/ssh/sshd_config`
  - Port: 42
  - PermitRootLogin: prohibit-password
  - PubkeyAuthentication: yes
  - PasswordAuthentication: yes
<br>
- apply changes via restart:
  - `service ssh restart`
  - `service sshd restart`
  - `service ssh status`
<br>
- SSH, or Secure Shell, is a protocol used to securely connect to a remote server/system. It provides a secure channel over an unsecured network in a client-server architecture, allowing you to run commands on a remote machine, transfer files, and more.
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
  
  - `listen 80; listen 443 ssl;`: Listen for connections on ports 80 (HTTP) and 443 (HTTPS). In practice, the server will be accessible via both HTTP and HTTPS.
  
  - `server_name aulicna.42.fr www.aulicna.42.fr;`: Sets the server name to `aulicna.42.fr` and `www.aulicna.42.fr`. Nginx will respond to requests that are made to these domain names.
  
  - `root /var/www/public/html;`: Sets the root directory for requests to `/var/www/public/html`. This is the directory where Nginx will look for files to serve when it receives a request.
  
  - `ssl_certificate /etc/nginx/ssl/aulicna.42.fr.crt;`: Sets the path to the SSL certificate. This certificate is used to establish a secure connection with the client.
  
  - `ssl_certificate_key /etc/nginx/ssl/aulicna.42.fr.key;`: Sets the path to the SSL certificate key. This key is used in conjunction with the certificate to establish a secure connection.
  
  - `ssl_protocols TLSv1.2 TLSv1.3;`: Specifies the TLS protocols that Nginx should use for SSL. These protocols are used to secure the connection between the client and the server.
  
  - `ssl_session_timeout 10m;`: Sets the SSL session timeout to 10 minutes. This means that the secure connection will be kept alive for 10 minutes without activity before it's closed.
  
  - `keepalive_timeout 70;`: Sets the keep-alive timeout to 70 seconds. This means that the connection will be kept open for 70 seconds without activity before it's closed. This can help improve performance for clients that make multiple requests.
  
  - `location / { ... }`: Defines how to respond to requests for the root URL (`/`). The `try_files $uri /index.html;` line tells Nginx to try to serve the requested URI, and if that fails, to serve `/index.html`. This is useful for single-page applications where you want to serve the same HTML file for all routes.
  
  - `if ($scheme = 'http') {...}`: Redirects HTTP traffic to HTTPS. This is a common practice to ensure that all traffic is encrypted.

### Docker containers
- NGINX: Proxy web server, port: 443
- PHP: Scripting language for the web
- Php-Fpm: A set of libraries for the FastCGI API, port: 9000
- Wordpress: Content Management System
- MariaDB: Relational database, port: 3306

#### Docker container: NGINX

**Dockerfile**
```
FROM alpine:3.20											# specify image to deploy the container from
RUN apk update && apk upgrade && apk add --no-cache nginx	# creates a new image layer resulting from the called command (similar to a VM snapshot)
EXPOSE 443													# open port for the container to exchange traffic
CMD ["nginx", "-g", "daemon off;"]							# run the installed configuration
```