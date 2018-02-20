#!/bin/sh

# generate host keys if not present
ssh-keygen -A

echo "$CANALBOX_SN" > /usr/local/etc/vnet/sn
echo "$CORE" core >> /etc/hosts
sed -i "s/6210/"$FRP_SSH_PORT"/g" /etc/frpc.ini
sed -i "s/6310/"$FRP_POLIPO_PORT"/g" /etc/frpc.ini
sed -i "s/andy010/"$CANALBOX_SN"/g" etc/frpc.ini
supervisord -c /etc/supervisord.conf 
cat /usr/local/etc/vnet/sn
cat /etc/hosts
docker exec -it lede1 bin/sh -c 'opkg update'
docker exec -it lede1 bin/sh -c 'opkg install strongswan-minimal'

docker exec -it lede1 bin/sh -c 'rm usr/lib/opkg/info/kmod-lib-zlib-deflate.postinst'
docker exec -it lede1 bin/sh -c 'rm usr/lib/opkg/info/kmod-lib-zlib-inflate.postinst'
docker exec -it lede1 bin/sh -c 'rm usr/lib/opkg/info/kmod-ipt-ipsec.postinst'
# check wether a random root-password is provided
#if [ ! -z ${ROOT_PASSWORD} ] && [ "${ROOT_PASSWORD}" != "root" ]; then
#    echo "root:${ROOT_PASSWORD}" | chpasswd
#fi

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
