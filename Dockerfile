FROM alpine
MAINTAINER  yagosys@gmail.com
ENV TELEGRAF_VERSION 1.5.2
ENV CPE_VERSION flow-cpe-x86-0.4.25.20180202035658.tar.gz
ENV ROOT_PASSWORD root
ENV CANALBOX_SN 000010
ENV CIDR 172.17.0.0/16
ENV CORE 127.0.0.1
ENV FRP_POLIPO_PORT 6310
ENV FRP_SSH_PORT 6210

RUN apk --update --no-cache add openssh \
		&& sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config \
		&& echo "root:${ROOT_PASSWORD}" | chpasswd \
		&& rm -rf /var/cache/apk/* /tmp/*

COPY entrypoint.sh /usr/local/bin/

ENV LANG=C.UTF-8

# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.

RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.27-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    apk add --no-cache --virtual=.build-dependencies wget ca-certificates && \
    wget \
        "https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add --no-cache \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true && \
    echo "export LANG=$LANG" > /etc/profile.d/locale.sh && \
    \
    apk del glibc-i18n && \
    \
    rm "/root/.wget-hsts" && \
    apk del .build-dependencies && \
    rm \
        "$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" \
        "$ALPINE_GLIBC_I18N_PACKAGE_FILENAME"


COPY supervisord.conf /etc
COPY polipo /usr/local/bin
COPY ${CPE_VERSION} /tmp
COPY telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz /tmp
#COPY glibc-2.27-r0.apk /tmp
COPY polipo.conf /etc
COPY canalbox.conf /etc
COPY frpc-amd64-linux /usr/local/bin/frpc
COPY frpc.ini /etc

#RUN apk add --no-cache /tmp/glibc-2.27-r0.apk --allow-untrusted && \
#rm /tmp/glibc-2.27-r0.apk

RUN apk add --no-cache \
 supervisor \
 strongswan

RUN mkdir /etc/supervisord.d && \
mkdir /vagrant && \
tar xvf /tmp/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz -C /usr/local/bin/ --strip-components 1 && \
tar xvf /tmp/${CPE_VERSION} -C /usr/local/bin/ --strip-components 1 && \
rm /tmp/${CPE_VERSION} && \
rm /tmp/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz && \
echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf && \
mkdir -p /var/log/vnet/ && \
chmod 777 /var/log/vnet && \
mkdir -p /usr/local/etc/vnet && \
chmod 777 /usr/local/etc/vnet && \ 
mkdir -p /home/ubnt/vnet && \ 
chmod 777 /home/ubnt/vnet && \ 
mkdir -p /usr/local/etc/vnet/link.d && \ 
chmod 777 /usr/local/etc/vnet/link.d && \ 
mkdir -p /etc/telegraf/telegraf.d && \
touch /etc/telegraf/telegraf.d/policystatus.conf && \ 
touch /etc/telegraf/telegraf.d/policylatency.conf &&  \ 
touch /etc/canalbox.conf && \ 
chmod 777 /etc/telegraf/telegraf.d/policystatus.conf && \
chmod 777 /etc/telegraf/telegraf.d/policylatency.conf && \ 
chmod 777 /etc/canalbox.conf && \
mkdir -p /etc/supervisor/conf.d

RUN /bin/su -c "echo 'include /etc/ipsec.d/*.conf' >> /etc/ipsec.conf" && \
/bin/su -c "echo 'include /etc/ipsec.d/*.secrets' >> /etc/ipsec.secrets" && \
/bin/su -c "echo 'files = /etc/supervisor/conf.d/*.conf' >> /etc/supervisord.conf" && \
/bin/su -c "echo [program:vcpe-getconf] > /etc/supervisor/conf.d/getconf.conf" && \
/bin/su -c "echo command=/usr/local/bin/getconf -ip core >>  /etc/supervisor/conf.d/getconf.conf" && \ 
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/getconf.conf" && \
/bin/su -c "echo startsecs=5 >>  /etc/supervisor/conf.d/getconf.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/getconf.conf" && \
/bin/su -c "echo [program:vcpe-ipsecping] > /etc/supervisor/conf.d/ipsecping.conf" && \
/bin/su -c "echo command=/usr/local/bin/ipsecPing >>  /etc/supervisor/conf.d/ipsecping.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/ipsecping.conf" && \
/bin/su -c "echo startsecs=5 >>  /etc/supervisor/conf.d/ipsecping.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/ipsecping.conf" && \
/bin/su -c "echo [program:vcpe-cpe-policy-latecy] > /etc/supervisor/conf.d/policylatency.conf" && \
/bin/su -c "echo command=/usr/local/bin/policylatency >>  /etc/supervisor/conf.d/policylatency.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/policylatency.conf" && \
/bin/su -c "echo startsecs=5 >>  /etc/supervisor/conf.d/policylatency.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/policylatency.conf" && \
/bin/su -c "echo [program:vcpe-cpepolicyupdate] > /etc/supervisor/conf.d/policyupdate.conf" && \
/bin/su -c "echo command=/usr/local/bin/policyUpdate >>  /etc/supervisor/conf.d/policyupdate.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/policyupdate.conf" && \
/bin/su -c "echo startsecs=5 >>  /etc/supervisor/conf.d/policyupdate.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/policyupdate.conf" && \
/bin/su -c "echo [program:vcpe-cperecovery] > /etc/supervisor/conf.d/vcpe-cperecovery.conf" && \
/bin/su -c "echo command=/usr/local/bin/cpeRecovery >>  /etc/supervisor/conf.d/vcpe-cperecovery.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/vcpe-cperecovery.conf" && \
/bin/su -c "echo startsecs=10 >>  /etc/supervisor/conf.d/vcpe-cperecovery.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/vcpe-cperecovery.conf" && \
/bin/su -c "echo [program:vcpe-polipo] > /etc/supervisor/conf.d/vcpe-polipo.conf" && \
/bin/su -c "echo command=/usr/local/bin/polipo -c /etc/polipo.conf >>  /etc/supervisor/conf.d/vcpe-polipo.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/vcpe-polipo.conf" && \
/bin/su -c "echo startsecs=10 >>  /etc/supervisor/conf.d/vcpe-polipo.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/vcpe-polipo.conf" && \
/bin/su -c "echo [program:vcpe-frpc] > /etc/supervisor/conf.d/vcpe-frpc.conf" && \
/bin/su -c "echo command=/usr/local/bin/frpc -c /etc/frpc.ini >>  /etc/supervisor/conf.d/vcpe-frpc.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/vcpe-frpc.conf" && \
/bin/su -c "echo startsecs=10 >>  /etc/supervisor/conf.d/vcpe-frpc.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/vcpe-frpc.conf" && \
/bin/su -c "echo [program:vcpe-ipsec] > /etc/supervisor/conf.d/vcpe-ipsec.conf" && \
/bin/su -c "echo command=/usr/sbin/ipsec start --nofork >> /etc/supervisor/conf.d/vcpe-ipsec.conf" && \
/bin/su -c "echo autostart=true >>  /etc/supervisor/conf.d/vcpe-ipsec.conf" && \
/bin/su -c "echo startsecs=10 >>  /etc/supervisor/conf.d/vcpe-ipsec.conf" && \
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/vcpe-ipsec.conf"

EXPOSE 8123/tcp
EXPOSE 22

ENTRYPOINT ["entrypoint.sh"]
