# syntax=docker/dockerfile:1

ARG PHP_VERSION="8.3"
FROM php:${PHP_VERSION}-apache

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y \
    libldap2-dev \
    libsasl2-dev \
    git \
    openssh-client \
 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
 && docker-php-ext-install ldap \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Configurar SSH
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Establecer el directorio de trabajo
WORKDIR /var/www/html

# Definir variables de entorno para evitar fallos si no están definidas
ENV RSA_KEY=""
ENV RSA_PUB_KEY=""
ENV GIT_URL=""

# Ejecutar configuración en el primer arranque
CMD set -e && \
    echo "$RSA_KEY" | base64 -d > /root/.ssh/id_rsa && \
    echo "$RSA_PUB_KEY" | base64 -d > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && chmod 644 /root/.ssh/id_rsa.pub && \
    ssh-keyscan bitbucket.desigual.com >> /root/.ssh/known_hosts && \
    echo "Probando acceso SSH a Bitbucket..." && \
    ssh -T git@bitbucket.desigual.com || exit 1 && \
    echo "Clonando repositorio: $GIT_URL" && \
    GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone "$GIT_URL" . && \
    echo "Repositorio clonado con éxito." && \
    exec apache2-foreground
