#!/bin/bash
# Script de configuracion: Nginx con pagina web estatica
# Extraido del metadata de main.tf para modularizacion
set -ex

# actualizar paquetes e instalar Nginx
apt-get update
apt-get install nginx -y

# asegurar directorio
mkdir -p /var/www/html

# copiar el archivo index.html local hacia el servidor
cat << 'HTML' > /var/www/html/index.html
${index_html_content}
HTML

# asignar permisos
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# abrir puertos
ufw allow 80/tcp || true
iptables -I INPUT -p tcp --dport 80 -j ACCEPT || true

# asegurar que nginx este iniciado y habilitado
systemctl enable nginx
systemctl restart nginx
