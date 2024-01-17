### RTPEngine
FROM debian:bullseye-slim 
LABEL  Author="Bayu Krisnawan <krisna@gmail.com>"

ARG TIMEZONE="Asia/Jakarta"
ARG SUPERPATH="/etc/supervisor/conf.d"
ARG YACRON="https://github.com/gjcarneiro/yacron/releases/download/0.19.0/yacron-0.19.0-x86_64-unknown-linux-gnu"
ARG YACFG="/etc/yacron.yaml"
ARG FDLOG="/proc/1/fd/1"
ARG VBCG729="1.1.1"
ARG RTPEVER="mr11.4.1"
# ARG ACLOG="/var/log/nginx/access.log"
# ARG ERLOG="/var/log/nginx/error.log"

RUN apt -y update && apt -y dist-upgrade \
    && apt -y install supervisor wget vim-tiny git \
    # iptables-persistent iptables \
    gnupg gnupg2 git mc \
    # linux-headers-$(uname -r) \
    libopus-dev dpkg-dev default-libmysqlclient-dev gperf libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl \
    libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libcurl4-openssl-dev libdigest-crc-perl libdigest-hmac-perl libevent-dev libglib2.0-dev \
    libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libiptc-dev libjson-glib-dev libjson-perl libmosquitto-dev libnet-interface-perl \
    libpcap0.8-dev libpcre3-dev libsocket6-perl libspandsp-dev libssl-dev libswresample-dev libsystemd-dev libwebsockets-dev libxmlrpc-core-c3-dev \
    libxtables-dev markdown python3-websockets zlib1g-dev debhelper-compat libbcg729-dev


RUN mkdir -p /usr/src && cd /usr/src && git clone https://github.com/sipwise/rtpengine.git -b ${RTPEVER}
RUN apt install -y dh-sequence-dkms libtest2-suite-perl pandoc
RUN cd /usr/src/rtpengine \
    && dpkg-checkbuilddeps \
    && dpkg-buildpackage -d \
    && cd /usr/src/ \
    && ls *.deb \
    && export PATH=$PATH:/sbin 
    # && dpkg -i *.deb

# RUN cd /usr/src/rtpengine && curl https://codeload.github.com/BelledonneCommunications/bcg729/tar.gz/${VBCG729} > bcg729_${VBCG729}.orig.tar.gz \
#     && tar zxf bcg729_${VBCG729}.orig.tar.gz \
#     && cd bcg729-${VBCG729} \
#     && git clone https://github.com/ossobv/bcg729-deb.git debian \
#     && dpkg-buildpackage -us -uc -sa -b -rfakeroot \
#     && cd ../ \
#     && dpkg -i libbcg729-*.deb \
#     # && dpkg-checkbuilddeps \
#     && dpkg-buildpackage  --no-sign 


    ## YaCron Scheduler
RUN wget ${YACRON} -O /usr/sbin/yacron && chmod 755 /usr/sbin/yacron \
    ## Timezone
    && echo "$TIMEZONE" |tee  /etc/timezone \
    && ln -fs /usr/share/zoneinfo/`cat /etc/timezone` /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata  \
    # YaCron Schedule
    && echo "[program:yacron]" >  ${SUPERPATH}/yacron.conf \
    && echo "command=/usr/sbin/yacron -c ${YACFG}" >>  ${SUPERPATH}/yacron.conf \
    && echo "autostart=true" >>  ${SUPERPATH}/yacron.conf \
    && echo "autorestart=true" >>  ${SUPERPATH}/yacron.conf \
    && echo "stopsignal=TERM" >> ${SUPERPATH}/yacron.conf \
    && echo "startretries=100" >> ${SUPERPATH}/yacron.conf \
    && echo "stopwaitsecs=5" >> ${SUPERPATH}/yacron.conf \
    && echo "stopasgroup=true" >> ${SUPERPATH}/yacron.conf \
    && echo "defaults:" > ${YACFG} \
    && echo "    environment:" >> ${YACFG} \
    && echo "      - key: PATH" >> ${YACFG} \
    && echo "        value: /bin:/usr/bin" >>${YACFG} \
    && echo "    shell: /bin/bash" >>${YACFG} \
    && echo "    utc: false">>${YACFG} \
    && echo "jobs:">>${YACFG} \
    && echo "  - name: rmsession" >> ${YACFG} \
    && echo "    command: |" >> ${YACFG} \
    && echo "       find /var/lib/php/sessions/  -type f -amin +180 -exec rm {} + && " >> ${YACFG} \
    && echo "       sleep 1 && exit 0" >> ${YACFG} \
    && echo "    schedule: '0 * * * *'">>${YACFG} \
    && echo "  - name: dailyupdate" >> ${YACFG} \
    && echo "    command: |" >> ${YACFG} \
    && echo "       apt -y update && apt-y dist-upgrade && " >> ${YACFG} \
    && echo "       sleep 1 && exit 0" >> ${YACFG} \
    && echo "    schedule: '0 23 * * *'">>${YACFG} \
    ##CLEANUP 
    && apt -y purge gcc-9-base  wget  \ 
    && apt -y clean && rm -rf /var/lib/apt/lists/* /var/log/* \
    && mkdir -p /var/log/supervisor /var/log/nginx /var/cache/fusionpbx /run/php 
#    && ln -s ${FDLOG} ${ACLOG} && ln -s ${FDLOG} ${ERLOG} 

# WORKDIR /root

# COPY ./build/www-fpm.conf /etc/php/7.4/fpm/pool.d/www.conf
# COPY ./build/htpasswd /etc/nginx/.htpasswd
# COPY ./build/nginx.conf /etc/nginx/
# #COPY ./build/startup.sh /startup.sh 
# COPY ./build/entrypoint.sh /entrypoint.sh

# #Fix timezone
# #RUN chmod 0600 /startup.sh  && chmod 0500 /entrypoint.sh
# RUN  chmod 0500 /entrypoint.sh

## Add additional things here
ENTRYPOINT ["/entrypoint.sh"]
