FROM alpine:3.19

RUN apk update && apk upgrade && apk add --no-cache \
	wget
RUN wget https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 && \
    mv cadvisor-v0.49.1-linux-amd64 cadvisor && \ 
    chmod +x cadvisor

CMD ["./cadvisor", ""]