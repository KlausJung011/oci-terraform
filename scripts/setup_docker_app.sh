#!/bin/bash
# Script de configuracion: Docker + mi-app-vite desde Docker Hub
# Imagen: klausjung011/mi-app-vite
set -ex

# -----------------------------------------------
# 1. Actualizar paquetes del sistema
# -----------------------------------------------
apt-get update -y
apt-get upgrade -y

# -----------------------------------------------
# 2. Instalar dependencias para Docker
# -----------------------------------------------
apt-get install -y \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

# -----------------------------------------------
# 3. Agregar clave GPG oficial de Docker
# -----------------------------------------------
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# -----------------------------------------------
# 4. Agregar repositorio de Docker
# -----------------------------------------------
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# -----------------------------------------------
# 5. Instalar Docker Engine
# -----------------------------------------------
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# -----------------------------------------------
# 6. Habilitar e iniciar Docker
# -----------------------------------------------
systemctl enable docker
systemctl start docker

# -----------------------------------------------
# 7. Abrir puertos en el firewall
#    - Puerto 80 para la app (mapeado desde 5173 del contenedor)
# -----------------------------------------------
ufw allow 80/tcp || true
ufw allow 5173/tcp || true
iptables -I INPUT -p tcp --dport 80 -j ACCEPT || true
iptables -I INPUT -p tcp --dport 5173 -j ACCEPT || true

# -----------------------------------------------
# 8. Descargar y correr el contenedor mi-app-vite
#    - Se mapea el puerto 80 del host al 80 del contenedor
#    - Ajustar el puerto interno segun lo que exponga tu imagen
# -----------------------------------------------
docker pull klausjung011/mi-app-vite:latest
docker run -d \
  --name mi-app-vite \
  --restart unless-stopped \
  -p 80:80 \
  klausjung011/mi-app-vite:latest

# -----------------------------------------------
# 9. Verificar que el contenedor este corriendo
# -----------------------------------------------
docker ps
