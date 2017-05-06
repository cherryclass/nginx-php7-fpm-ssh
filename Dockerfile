FROM debian:stretch-slim

MAINTAINER Luc Frébourg

ENV NGINX_VERSION 1.13.0-1~stretch
ENV NJS_VERSION   1.13.0.0.1.10-1~stretch
ENV DEBIAN_FRONTEND noninteractive


RUN echo 'starting' 
RUN (apt-get update && apt-get upgrade -y -q && apt-get dist-upgrade -y -q && apt-get -y -q autoclean && apt-get -y -q autoremove)

RUN echo 'aptitude' 
RUN apt-get install --no-install-recommends --no-install-suggests -y \
    aptitude \
    apt-utils
  
RUN echo 'package' 
RUN aptitude install -y\
	sudo \
    nano \
    ssh \
    supervisor \
    nginx \
php7.0-fpm
	

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# configure NGINX as non-daemon
RUN echo "daemon off;" >> /etc/nginx/nginx.conf

RUN useradd -ms /bin/bash luc && adduser luc sudo
ADD index.php /home/luc/www/

EXPOSE 80 443 110 137 138 143 145 22 23 25 53
EXPOSE 139/udp 445/udp

ENTRYPOINT service ssh restart && bash
STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]

