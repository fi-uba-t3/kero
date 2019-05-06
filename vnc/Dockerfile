FROM consol/centos-xfce-vnc

# Switch to root user to install additional software
USER 0

RUN yum install -y openldap-clients nss-pam-ldapd authconfig \
    && yum clean all

COPY nslcd.conf /etc/nslcd.conf

RUN authconfig --updateall --enableldap --enableldapauth --enablemkhomedir

COPY vnc_wrapper.sh /dockerstartup/vnc_wrapper.sh

## switch back to default user
# USER 1000

ENTRYPOINT ["/dockerstartup/vnc_wrapper.sh"]
