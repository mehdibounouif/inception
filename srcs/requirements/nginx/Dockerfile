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

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
