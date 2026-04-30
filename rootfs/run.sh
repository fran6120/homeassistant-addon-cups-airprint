#!/usr/bin/with-contenv bashio

ulimit -n 524288

# --- ESTO ES LO ÚNICO NUEVO QUE REALMENTE NECESITAS ---
# 1. Creamos el permiso para que tu red pueda entrar al escáner
echo "192.168.1.0/24" > /etc/sane.d/saned.conf

# 2. Arrancamos el servidor de escáner en segundo plano (&)
# Usamos 'root' para no pelearnos con permisos del USB
/usr/sbin/saned -a root &
# ------------------------------------------------------

# (Lo que ya estaba) Espera a que el sistema de red esté listo
until [ -e /var/run/avahi-daemon/socket ]; do
  sleep 1s
done

bashio::log.info "Preparing directories"
if [ ! -d /config/cups ]; then cp -v -R /etc/cups /config; fi
rm -v -fR /etc/cups
ln -v -s /config/cups /etc/cups

bashio::log.info "Starting CUPS server"

# (Lo que ya estaba) Arranca CUPS y se queda bloqueado aquí (es el proceso principal)
cupsd -f
