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
- **Port 42**: SSH
- **Port 80**: This is the default port for HTTP (Hypertext Transfer Protocol). When you visit a website using http://, your web browser communicates with the web server over this port unless specified otherwise.

- **Port 443**: This is the default port for HTTPS (HTTP Secure), which is HTTP over SSL/TLS. When you visit a website using https://, your web browser communicates with the web server over this port. HTTPS encrypts the data for secure transmission, preventing data from being read in transit.


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


