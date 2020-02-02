FROM debian:buster-slim

ARG OCS_VERSION=2.6 
ARG TIMEZONE=Europe/Zagreb

LABEL maintainer="jsosic@gmail.com"
LABEL version="${OCS_VERSION}"
LABEL description="OCS (Open Computers and Software Inventory Next Generation)"

WORKDIR /tmp/ocs

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get -y --no-install-recommends install apt-utils \
 && apt-get -y --no-install-recommends upgrade \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get -y --no-install-recommends install \
       apache2 apache2-doc libapache2-mod-php7.3 libapache2-mod-perl2 \
       php7.3 php7.3-gd php7.3-mysql php7.3-cgi php7.3-curl php7.3-ldap php7.3-mbstring php7.3-soap php7.3-xml \
       php-pclzip \
       perl \
       libxml-simple-perl libxml-libxml-perl libnet-ip-perl libdbi-perl \
       libapache-dbi-perl libdbd-mysql-perl libio-compress-perl libswitch-perl \
       libxml-simple-perl libsoap-lite-perl libarchive-zip-perl \
       libnet-ip-perl libsoap-lite-perl libarchive-zip-perl libmodule-build-perl \
       libxml2 libc6-dev \
       build-essential make tar curl \
 && rm -rf /var/lib/apt/lists/* \
 && cpan -i XML::Entities \
 && echo 'ServerName ocs' >> /etc/apache2/conf-available/servername.conf \
 && /usr/sbin/a2dissite 000-default \
 && /usr/sbin/a2disconf apache2-doc localized-error-pages \
 && /usr/sbin/a2enconf servername \
 && /usr/sbin/a2enmod rewrite authz_user

RUN cp /usr/share/zoneinfo/$TIMEZONE /etc/localtime

RUN mkdir -p /etc/ocsinventory-server/plugins \
 && mkdir -p /etc/ocsinventory-server/perl \
 && mkdir -p /usr/share/ocsinventory-reports/ocsreports \
 && bash -c 'mkdir -p /var/lib/ocsinventory-reports/{download,ipd,logs,scripts,snmp}' \
 && chmod -R +w /var/lib/ocsinventory-reports \
 && chown www-data: -R /var/lib/ocsinventory-reports \
 && mkdir -p /var/log/ocsinventory-server/ \
 && chmod +w /var/log/ocsinventory-server/ \
 && chown -R www-data: /var/log/ocsinventory-server \
 && chown -R www-data: /usr/share/ocsinventory-reports/

RUN curl -sS -OL https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/${OCS_VERSION}/OCSNG_UNIX_SERVER_${OCS_VERSION}.tar.gz \
 && tar -xzf OCSNG_UNIX_SERVER_${OCS_VERSION}.tar.gz \
 && rm OCSNG_UNIX_SERVER_${OCS_VERSION}.tar.gz \
 && cd OCSNG_UNIX_SERVER_${OCS_VERSION}/Apache \
 && perl Makefile.PL && make && make install \
 && cp -R blib/lib/Apache /usr/local/share/perl/5.20.2/ \
 && cp -R Ocsinventory /usr/local/share/perl/5.20.2/ \
 && cd .. \
 && cp -R ocsreports /usr/share/ocsinventory-reports \
 && cp etc/logrotate.d/ocsinventory-server /etc/logrotate.d/ \
 && cp binutils/ipdiscover-util.pl /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl \
 && chown www-data: /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl \
 && chmod 0755 /usr/share/ocsinventory-reports/ocsreports/ipdiscover-util.pl \
 && rm /usr/share/ocsinventory-reports/ocsreports/install.php \
 && sed -i 's|^$list_methode = array(0 => "local.php");|$list_methode = array(0 => "ldap.php", 1 => "local.php");|' /usr/share/ocsinventory-reports/ocsreports/backend/AUTH/auth.php \
 && sed -i 's|^$list_methode = array(0 => "local.php");|$list_methode = array(0 => "ldap.php", 1 => "local.php");|' /usr/share/ocsinventory-reports/ocsreports/backend/identity/identity.php \
 && rm -rf /tmp/ocs/*

COPY --chown=www-data:www-data dbconfig.inc.php /usr/share/ocsinventory-reports/ocsreports/

COPY conf/* /etc/apache2/conf-available/
RUN /usr/sbin/a2enconf ocsinventory-reports z-ocsinventory-server

EXPOSE 80

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
