FROM alpine

MAINTAINER  yagosys@gmail.com

#RUN apk add --no-cache sudo openrc iputils ca-certificates net-snmp-tools procps && \
    #update-ca-certificates

ENV TELEGRAF_VERSION 1.5.2
#ENV CPE_VERSION flow-cpe-x86-0.4.19.20180112035727.tar.gz
ENV CPE_VERSION flow-cpe-x86-0.4.25.20180202035658.tar.gz


#RUN apk add --update openrc

#ADD https://gist.githubusercontent.com/chamunks/38c807435ffed53583f0/raw/ec868d1b45e248eb517a134b84474133c3e7dc66/gistfile1.txt /data/.ssh/authorized_keys

#RUN apk add --update openssh  && \
    #rc-update add sshd && \
    #rc-status && \
    #touch /run/openrc/softlevel && \
    #/etc/init.d/sshd start && \
    #/etc/init.d/sshd stop && \
    #adduser -D user -h /data/
#VOLUME ["/data/"]





RUN apk add --no-cache \
        supervisor \
        strongswan && \
#        binutils \
#        wget && \
#        wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
        mkdir /etc/supervisord.d && \
        mkdir /vagrant 


COPY supervisord.conf /etc
COPY polipo /usr/local/bin
COPY ${CPE_VERSION} /vagrant
COPY telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz /vagrant/
COPY glibc-2.27-r0.apk /vagrant
#COPY vcpe_conf.conf /vagrant
COPY polipo.conf /etc
#COPY run.sh /vagrant
COPY canalbox.conf /etc
COPY frpc-amd64-linux /usr/local/bin/frpc
COPY frpc.ini /etc

RUN tar xvf /vagrant/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz -C /usr/local/bin/ --strip-components 1 && \
tar xvf /vagrant/${CPE_VERSION} -C /usr/local/bin/ --strip-components 1 && \
rm /vagrant/${CPE_VERSION} && \
rm /vagrant/telegraf-${TELEGRAF_VERSION}-static_linux_amd64.tar.gz

RUN echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
#RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.27-r0/glibc-2.27-r0.apk
#RUN apk add ./glibc-2.27-r0.apk 
RUN apk add /vagrant/glibc-2.27-r0.apk --allow-untrusted

RUN mkdir -p /var/log/vnet/ && \
chmod 777 /var/log/vnet && \
mkdir -p /usr/local/etc/vnet && \
chmod 777 /usr/local/etc/vnet && \ 
mkdir -p /home/ubnt/vnet && \ 
chmod 777 /home/ubnt/vnet && \ 
mkdir -p /usr/local/etc/vnet/link.d && \ 
chmod 777 /usr/local/etc/vnet/link.d  



RUN mkdir -p /etc/telegraf/telegraf.d && \
touch /etc/telegraf/telegraf.d/policystatus.conf && \ 
touch /etc/telegraf/telegraf.d/policylatency.conf &&  \ 
touch /etc/canalbox.conf && \ 
chmod 777 /etc/telegraf/telegraf.d/policystatus.conf && \
chmod 777 /etc/telegraf/telegraf.d/policylatency.conf && \ 
chmod 777 /etc/canalbox.conf && \
mkdir -p /etc/supervisor/conf.d

RUN /bin/su -c "echo 'include /etc/ipsec.d/*.conf' >> /etc/ipsec.conf" && \
    /bin/su -c "echo 'include /etc/ipsec.d/*.secrets' >> /etc/ipsec.secrets" && \
    /bin/su -c "echo 'files = /etc/supervisor/conf.d/*.conf' >> /etc/supervisord.conf"

RUN /bin/su -c "echo [program:vcpe-getconf] > /etc/supervisor/conf.d/getconf.conf" && \
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
/bin/su -c "echo user=root >>  /etc/supervisor/conf.d/vcpe-frpc.conf"






EXPOSE 8123/tcp

#ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
#ENTRYPOINT ["/vagrant/run.sh"]


