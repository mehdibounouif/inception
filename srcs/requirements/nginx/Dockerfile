#FROM debian:bullseye
#
## Install NGINX and OpenSSL
#RUN apt-get update && apt-get install -y \
#    nginx \
#    openssl \
#    && rm -rf /var/lib/apt/lists/*
#
## Copy NGINX configuration
#COPY conf/nginx.conf /etc/nginx/nginx.conf
#
## Copy SSL certificate generation script
#COPY tools/generate-ssl.sh /usr/local/bin/generate-ssl.sh
#RUN chmod +x /usr/local/bin/generate-ssl.sh
#
## Create SSL directory and generate certificate
#RUN mkdir -p /etc/nginx/ssl && \
#    /usr/local/bin/generate-ssl.sh
#
#EXPOSE 443
#
#CMD ["nginx", "-g", "daemon off;"]

FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf.template
COPY tools/generate-ssl.sh /usr/local/bin/generate-ssl.sh
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/generate-ssl.sh \
    && chmod +x /usr/local/bin/entrypoint.sh \
    && mkdir -p /etc/nginx/ssl

EXPOSE 443

CMD ["/usr/local/bin/entrypoint.sh"]
