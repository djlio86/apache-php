# syntax=docker/dockerfile:1

# Definir argumentos para build-time
ARG PHP_VERSION="8.3"
ARG BASE_IMAGE="php:${PHP_VERSION}-apache"

FROM ${BASE_IMAGE}

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libldap2-dev \
    libsasl2-dev \
    git \
 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
 && docker-php-ext-install ldap \
 && a2enmod rewrite

# Configurar SSH
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Clonar el repo en el primer arranque
WORKDIR /var/www/html
CMD echo "$RSA_KEY" | base64 -d > /root/.ssh/id_rsa && \
    echo "$RSA_PUB_KEY" | base64 -d > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/id_rsa.pub && \
    ssh-keyscan bitbucket.desigual.com >> /root/.ssh/known_hosts && \
    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone "$GIT_URL" . && \
    apache2-foreground