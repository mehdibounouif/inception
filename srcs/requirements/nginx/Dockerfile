FROM debian:bullseye

# Install NGINX and OpenSSL
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy NGINX configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy SSL certificate generation script
COPY tools/generate-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-ssl.sh && \
    /usr/local/bin/generate-ssl.sh

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
