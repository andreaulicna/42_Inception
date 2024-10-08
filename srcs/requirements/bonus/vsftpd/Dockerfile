FROM alpine:3.19

ARG FTP_USER

RUN apk update && apk upgrade && \
    apk add --no-cache vsftpd

RUN --mount=type=secret,id=ftp_password \
	export FTP_PASS=$(cat /run/secrets/ftp_password) && \
	adduser -h /var/www -s /bin/false -D ${FTP_USER} && \
    echo "${FTP_USER}:${FTP_PASS}" | /usr/sbin/chpasswd && \
    adduser ${FTP_USER} root

RUN sed -i "s|#chroot_local_user=YES|chroot_local_user=YES|g"  /etc/vsftpd/vsftpd.conf && \
    sed -i "s|#local_enable=YES|local_enable=YES|g"  /etc/vsftpd/vsftpd.conf && \
    sed -i "s|#write_enable=YES|write_enable=YES|g"  /etc/vsftpd/vsftpd.conf && \
    sed -i "s|#local_umask=022|local_umask=007|g"  /etc/vsftpd/vsftpd.conf

RUN echo "allow_writeable_chroot=YES" >> /etc/vsftpd/vsftpd.conf &&\
    echo 'seccomp_sandbox=NO' >> /etc/vsftpd/vsftpd.conf && \
    echo 'pasv_enable=YES' >> /etc/vsftpd/vsftpd.conf

WORKDIR /var/www

EXPOSE 21

CMD [ "/usr/sbin/vsftpd", "/etc/vsftpd/vsftpd.conf" ]
