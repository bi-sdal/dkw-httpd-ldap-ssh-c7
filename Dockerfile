FROM dads2busy/c7-ssh-ldap-httpd
MAINTAINER Aaron D. Schroeder <dads2busy@gmail.com>

## Install Prerequisites (php-ldap only needed if you're using LDAP authentication)
RUN yum -y install yum-cron php php-gd php-ldap openssl mod_ssl wget unzip
## Enable mod_rewrite
RUN echo "LoadModule rewrite_module modules/mod_rewrite.so" >> /etc/httpd/conf/httpd.conf
## Download and Install DokuWiki
RUN wget http://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz  
# unpack the tar
RUN tar -xzf dokuwiki-stable.tgz  
# remove the tar
RUN rm -f dokuwiki-stable.tgz  
# move the dokuwiki folder to the web server (the * is why we removed the tar)
RUN mv dokuwiki-* /var/www/html/dokuwiki  

COPY acl.auth.php /var/www/html/dokuwiki/conf
COPY local.php /var/www/html/dokuwiki/conf
COPY plugins.local.php /var/www/html/dokuwiki/conf
COPY users.auth.php /var/www/html/dokuwiki/conf

# set permissions for dokuwiki
RUN chown -R apache:root /var/www/html/dokuwiki  
RUN chmod -R 664 /var/www/html/dokuwiki/  
RUN find /var/www/html/dokuwiki/ -type d -exec chmod 775 {} \;
COPY httpd.conf /etc/httpd/conf

RUN curl -O -L "https://github.com/samuelet/indexmenu/archive/master.zip" && \
unzip master.zip -d /var/www/html/dokuwiki/lib/plugins/ && \
mv /var/www/html/dokuwiki/lib/plugins/indexmenu-master /var/www/html/dokuwiki/lib/plugins/indexmenu && \
rm -rf master.zip

RUN curl -O -L "https://github.com/LotarProject/dokuwiki-template-bootstrap3/zipball/master" && \
unzip master -d /var/www/html/dokuwiki/lib/tpl/ && \
mv /var/www/html/dokuwiki/lib/tpl/LotarProject-dokuwiki-template-bootstrap3-fef63cb /var/www/html/dokuwiki/lib/tpl/bootstrap3 && \
rm -rf master

# Allow auto-creation of roles
RUN groupadd shadow
RUN chown root:shadow /etc/shadow
RUN chown root:shadow /sbin/unix_chkpwd
RUN chmod g+s /sbin/unix_chkpwd

# Attempt PAM
RUN wget http://lastweekend.com.au/ggauth.5.zip && unzip ggauth.5.zip -d /var/www/html/dokuwiki

EXPOSE 80
CMD ["/lib/systemd/systemd"]
