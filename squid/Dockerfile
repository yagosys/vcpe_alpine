FROM centos:7
MAINTAINER steven
RUN  rpm -Uvh https://mirrors.tuna.tsinghua.edu.cn/epel/epel-release-latest-7.noarch.rpm
RUN  rpm -Uvh https://sp.repo.webtatic.com/yum/el7/webtatic-release.rpm
RUN yum install -y wget
RUN yum install -y sed
RUN yum install -y vim
RUN yum install -y gcc
RUN yum install -y gcc-c++
RUN yum install -y gd
RUN yum install -y gd-devel
RUN yum install -y gmp-devel
RUN yum install -y epel-release
RUN yum install -y net-tools
RUN yum install -y ntpdate
RUN yum install -y ntp
RUN yum install -y openssh-clients
RUN yum install -y curl
RUN yum install -y crontabs
RUN yum install -y git
RUN yum install -y nginx
RUN yum install -y httpd
RUN yum install -y squid
RUN yum install -y php71w \
                   php71w-fpm \
                   php71w-gd \
                   php71w-redis \
                   php71w-soap \
                   php71w-intl \
                   php71w-pdo \
                   php71w-pdo_mysql \
                   php71w-pdo_pgsql \
                   php71w-pear \
                   php71w-devel \
                   php71w-mysql.x86_64  --skip-broken \
                   php71w-mbstring
RUN sed -i 's/http_access deny all/#http_access deny all/g' /etc/squid/squid.conf
RUN cd /tmp && wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py \
    && python get-pip.py
RUN pip install supervisor
EXPOSE 80 443 3128
WORKDIR /data/work/code
