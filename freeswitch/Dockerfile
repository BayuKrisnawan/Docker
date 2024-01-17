FROM debian:bullseye as fs0
LABEL  Author="Bayu Krisnawan <krisna@gmail.com>"

ARG FS_VERSION="v1.10"
ARG FS_TAG="v1.10.9"
ARG PG_VERSION="13"
ARG TIMEZONE="Asia/Jakarta"
ARG YACRON="https://github.com/gjcarneiro/yacron/releases/download/0.19.0/yacron-0.19.0-x86_64-unknown-linux-gnu"
ARG SUPERPATH="/etc/supervisor/conf.d"
ARG MCRAM="256"
ARG MCMAXISIZE="32m"
ARG YACFG="/etc/yacron.yaml"
ARG FDLOG="/proc/1/fd/1"
ARG FSLOG="/var/log/freeswitch/freeswitch.log"

RUN apt -y update \
    && apt -y dist-upgrade 
RUN apt-get install -y curl lsb-release apt-transport-https ca-certificates \ 
    git-core curl unzip tar locales wget \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt install -y \
    sngrep memcached netcat supervisor tzdata  postgresql-$PG_VERSION openssh-server vim-tiny \
    build-essential cmake automake autoconf libtool-bin pkg-config \
    zlib1g-dev libdb-dev libncurses5-dev \
    libexpat1-dev libgdbm-dev bison erlang-dev libtpl-dev libtiff5-dev uuid-dev \
    libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev nasm \
    libogg-dev libspeex-dev libspeexdsp-dev python3-dev \
    libavformat-dev libswscale-dev libavresample-dev liblua5.2-dev \
    libopus-dev libpq-dev flite1-dev libmagickcore-dev \
    libsndfile1-dev libflac-dev libogg-dev libvorbis-dev \
    libmp3lame-dev libmpg123-dev   libevent-dev \
    libssl-dev libldns-dev libshout3-dev \
    memcached libmemcached-dev  \
    ## YaCron Scheduler
    && wget ${YACRON} -O /usr/sbin/yacron && chmod 755 /usr/sbin/yacron \
    ## Timezone
    && echo "$TIMEZONE" |tee  /etc/timezone \
    && ln -fs /usr/share/zoneinfo/`cat /etc/timezone` /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata  \
    ## PostgreSQL
    && echo "local  all     all                     trust" > /etc/postgresql/$PG_VERSION/main/pg_hba.conf \
    && echo "host   all     all     127.0.0.1/32    trust" >> /etc/postgresql/$PG_VERSION/main/pg_hba.conf \
    ## PgSQL Supervisor
    && echo "[program:postgresql]" > ${SUPERPATH}/postgresql.conf \
    && echo "command=/usr/lib/postgresql/${PG_VERSION}/bin/postgres  -N 30 -F -c synchronous_commit=off -c full_page_writes=off -D /var/lib/postgresql/${PG_VERSION}/main -c config_file=/etc/postgresql/${PG_VERSION}/main/postgresql.conf -r ${FDLOG}" \
    >> ${SUPERPATH}/postgresql.conf \
    && echo "user=postgres" >> ${SUPERPATH}/postgresql.conf \
    && echo "autostart=true" >>  ${SUPERPATH}/postgresql.conf \
    && echo "stopsignal=TERM" >>  ${SUPERPATH}/postgresql.conf \
    && echo "startretries=100" >>  ${SUPERPATH}/postgresql.conf \
    && echo "autorestart=true" >>  ${SUPERPATH}/postgresql.conf \
    && echo "stopwaitsecs=5" >>  ${SUPERPATH}/postgresql.conf \
    ## PgSQL Init CoreDB
    && /etc/init.d/postgresql start  \
    && createdb -U postgres coredb \
    ## FreeSWITCH Supervisor
    && echo "[program:freeswitch]" >  ${SUPERPATH}/freeswitch.conf \
    && echo "command=bash /startup.sh" >> ${SUPERPATH}/freeswitch.conf \
    && echo "autostart=true" >> ${SUPERPATH}/freeswitch.conf \
    && echo "stopsignal=TERM" >> ${SUPERPATH}/freeswitch.conf \
    && echo "startretries=100" >> ${SUPERPATH}/freeswitch.conf \
    && echo "autorestart=true" >> ${SUPERPATH}/freeswitch.conf \
    && echo "stopwaitsecs=5" >> ${SUPERPATH}/freeswitch.conf \
    && echo "stopasgroup=true" >> ${SUPERPATH}/freeswitch.conf \
    ## SSHD
    && mkdir -p /run/sshd \
    && echo "PubkeyAuthentication yes" > /etc/ssh/sshd_config.d/sshd.conf \
    && echo "PermitRootLogin prohibit-password" >> /etc/ssh/sshd_config.d/sshd.conf \
    && echo "PasswordAuthentication no" >> /etc/ssh/sshd_config.d/sshd.conf \
    && echo "UsePAM no" >> /etc/ssh/sshd_config.d/sshd.conf \
    && echo "Port 20022" >> /etc/ssh/sshd_config.d/sshd.conf \
    ## SSHD Supervisor
    && echo "[program:sshd]" >  ${SUPERPATH}/sshd.conf \
    && echo "command=/usr/sbin/sshd -D" >> ${SUPERPATH}/sshd.conf \
    && echo "autostart=true" >> ${SUPERPATH}/sshd.conf \
    && echo "autorestart=true" >> ${SUPERPATH}/sshd.conf \
    && echo "command=/usr/sbin/sshd -D" >> ${SUPERPATH}/sshd.conf \
    ## Memcached Supervisor
    && echo "[program:memcached]" >  ${SUPERPATH}/memcached.conf \
    && echo "command=/usr/bin/memcached --user=memcache  -m ${MCRAM} -p 11211 -l 127.0.0.1 -I ${MCMAXISIZE}" >>  ${SUPERPATH}/memcached.conf \
    && echo "autostart=true" >>  ${SUPERPATH}/memcached.conf \
    && echo "stopsignal=TERM" >>  ${SUPERPATH}/memcached.conf \
    && echo "startretries=100" >>  ${SUPERPATH}/memcached.conf \
    && echo "autorestart=true" >>  ${SUPERPATH}/memcached.conf \
    && echo "stopwaitsecs=5" >>  ${SUPERPATH}/memcached.conf  \
    # YaCron Schedule
    && echo "[program:yacron]" >  ${SUPERPATH}/yacron.conf \
    && echo "command=/usr/sbin/yacron -c ${YACFG}" >>  ${SUPERPATH}/yacron.conf \
    && echo "autostart=true" >>  ${SUPERPATH}/yacron.conf \
    && echo "autorestart=true" >>  ${SUPERPATH}/yacron.conf \
    && echo "defaults:" > ${YACFG} \
    && echo "    environment:" >> ${YACFG} \
    && echo "      - key: PATH" >> ${YACFG} \
    && echo "        value: /bin:/usr/bin" >>${YACFG} \
    && echo "    shell: /bin/bash" >>${YACFG} \
    && echo "    utc: false">>${YACFG} \
    && echo "jobs:">>${YACFG} \
    && echo "  - name: fscli" >> ${YACFG} \
    && echo "    command: |" >> ${YACFG} \
    && echo "       date >/tmp/status.log &&" >> ${YACFG} \
    && echo "       fs_cli -x 'status' >>/tmp/status.log &&" >> ${YACFG} \
    && echo "       sleep 1 && exit 0" >> ${YACFG} \
    && echo "    schedule: '*/1 * * * *'">>${YACFG} 


#Initial default debian
#RUN find /usr  > /usr.txt && find /var > /var.txt && find /etc > /etc.txt
# Freeswitch
RUN ls -la /usr/src/
RUN git clone -b ${FS_VERSION} https://github.com/signalwire/freeswitch /usr/src/freeswitch 
RUN git clone https://github.com/signalwire/libks /usr/src/libs/libks
RUN git clone https://github.com/freeswitch/sofia-sip /usr/src/libs/sofia-sip
RUN git clone https://github.com/freeswitch/spandsp /usr/src/libs/spandsp \
    #https://github.com/signalwire/freeswitch/issues/2158
    && cd /usr/src/libs/spandsp && git reset --hard 67d2455efe02e7ff0d897f3fd5636fed4d54549e 
RUN git clone https://github.com/signalwire/signalwire-c /usr/src/libs/signalwire-c

# Enable modules
RUN sed -i 's|#applications/mod_avmd|applications/mod_avmd|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_callcenter|applications/mod_callcenter|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_cidlookup|applications/mod_cidlookup|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_curl|applications/mod_curl|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_directory|applications/mod_directory|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_distributor|applications/mod_distributor|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_easyroute|applications/mod_easyroute|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_esl|applications/mod_esl|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_lcr|applications/mod_lcr|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_memcache|applications/mod_memcache|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|applications/mod_signalwire|#applications/mod_signalwire|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|applications/mod_spy|#applications/mod_spy|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|applications/mod_stress|#applications/mod_stress|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_translate|applications/mod_translate|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#applications/mod_voicemail_ivr|applications/mod_voicemail_ivr|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#asr_tts/mod_flite|asr_tts/mod_flite|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#asr_tts/mod_tts_commandline|asr_tts/mod_tts_commandline|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#codecs/mod_amrwb|codecs/mod_amrwb|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#codecs/codecs/mod_codec2|codecs/codecs/mod_codec2|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|dialplans/mod_dialplan_asterisk|#dialplans/mod_dialplan_asterisk|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|endpoints/mod_verto|#endpoints/mod_verto|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|event_handlers/mod_cdr_sqlite|#event_handlers/mod_cdr_sqlite|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#event_handlers/mod_json_cdr|event_handlers/mod_json_cdr|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#formats/mod_imagick|formats/mod_imagick|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#formats/mod_shout|formats/mod_shout|' /usr/src/freeswitch/build/modules.conf.in
RUN sed -i 's|#say/mod|say/mod|' /usr/src/freeswitch/build/modules.conf.in

#Dependency:libks
RUN cd /usr/src/libs/libks && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 \
    && make install 
#Dependency:sofia-sip
RUN cd /usr/src/libs/sofia-sip && ./bootstrap.sh \
    && ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr \
    && make -j`nproc --all` && make install 
#Dependency:spandsp
RUN cd /usr/src/libs/spandsp \
# &&  sed -i 's/\[2.71\]/\[2.69\]/g' configure.ac \
    && ./bootstrap.sh   \
    && ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr \
    && make -j`nproc --all` && make install 
#Dependency:signalwire-c
RUN cd /usr/src/libs/signalwire-c \
    && PKG_CONFIG_PATH=/usr/lib/pkgconfig cmake . -DCMAKE_INSTALL_PREFIX=/usr \
    && make install 
#Build Freeswitch
RUN cd /usr/src/freeswitch && ./bootstrap.sh -j \
    && cd /usr/src/freeswitch && ./configure --prefix=/usr   \
    --sysconfdir=/etc --sharedstatedir=/usr/share/freeswitch  --localstatedir=/var \
    # --disable-dependency-tracking --enable-zrtp --enable-core-odbc-support \
    # --disable-dependency-tracking --enable-zrtp  \
    # --with-openssl --with-gnu-ld \
    #--enable-portable-binary --enable-core-pgsql-support \
    && cd /usr/src/freeswitch && make -j`nproc` && make install  

# BCG729
RUN git clone https://github.com/xadhoom/mod_bcg729.git /usr/src/mod_bcg729 \
    && cd /usr/src/mod_bcg729 && make && make install \
#Unimrcp
    && wget https://www.unimrcp.org/project/component-view/unimrcp-deps-1-6-0-tar-gz/download -O /usr/src/unimrcp-deps-1.6.0.tar.gz \
    && cd /usr/src &&  tar xvzf unimrcp-deps-1.6.0.tar.gz \
    && cd /usr/src/unimrcp-deps-1.6.0/libs/apr \
    && ./configure --prefix=/usr/local/apr && make && make install \
    && cd /usr/src/unimrcp-deps-1.6.0/libs/apr-util \
    && ./configure --with-apr=/usr/local/apr  && make && make install \
    && cd /usr/src/unimrcp-deps-1.6.0/libs \
    && git clone https://github.com/unispeech/unimrcp.git \
    && cd unimrcp && ./bootstrap && ./configure --with-sofia-sip=/usr && make && make install \
    && cd /usr/src/unimrcp-deps-1.6.0/libs \
    && git clone https://github.com/freeswitch/mod_unimrcp.git \
    && cd mod_unimrcp \
    && export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/local/unimrcp/lib/pkgconfig \
    && ./bootstrap.sh && ./configure && make && make install

    ##CLEANUP 
RUN apt -y clean  &&  apt --purge -y autoremove \
    && rm -r /var/lib/apt/ /var/cache/apt \
    && mkdir  -p /var/log/supervisor /var/log/freeswitch /var/log/postgresql 

WORKDIR /root

## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 443/tcp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 6050/tcp 6050/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 7443/tcp
EXPOSE 5070/udp 5070/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp
# COPY build/fsmerge.sh /usr/src/

# RUN  cd /usr/src && bash ./fsmerge.sh

# #-------------------
# FROM debian:stable-slim  AS fs1
# LABEL Author="Bayu Krisnawan <krisna@gmail.com>"

# WORKDIR /root

# COPY --from=fs0 /tmp/fs/ /
# COPY --from=fs0 /tmp/all.txt /


# RUN DEBIAN_FRONTEND=noninteractive apt update \
#     && DEBIAN_FRONTEND=noninteractive apt -y upgrade \
#     && DEBIAN_FRONTEND=noninteractive apt -y install curl unzip \
#     sngrep curl memcached supervisor tzdata sipsak bash-static sqlite3 \
#     procps  && apt clean \
#     && rm -r /var/lib/apt/ /var/cache/apt \
#     && echo "Asia/Singapore" |tee  /etc/timezone \
#     && ln -fs /usr/share/zoneinfo/`cat /etc/timezone` /etc/localtime \
#     && dpkg-reconfigure --frontend noninteractive tzdata 

# ##- from localfile
# COPY  build/entrypoint.sh /
# COPY  build/startup_fs.sh /
# COPY  build/supervisord.conf /etc/supervisor/
# COPY  build/limits/root.limits.conf /etc/security/limits.d/
# COPY  build/supervisor.ini /etc/supervisor/conf.d/

# ## Ports
# # Open the container up to the world.
# ### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
# EXPOSE 8021/tcp
# EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
# EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
# EXPOSE 7443/tcp
# EXPOSE 5070/udp 5070/tcp
# EXPOSE 64535-65535/udp
# EXPOSE 16384-32768/udp

# # #RUN tar zxvpf fs-image.tar.gz -C / \
# # #   && rm /fs-image.tar.gz && 
# RUN chmod +x /entrypoint.sh && mkdir -p /var/lib/freeswitch/{db,images} \
#     && rm -rf /var/tmp /var/run \
#     && ln -s /run /var/run  \
#     && mkdir -p /tmp && chmod 1777 /tmp && ln -s /tmp /var/tmp 
#     ## CLEANUP
#     # &&  rm -r /usr/include /etc/freeswitch/* /usr/share/freeswitch/*
 
# CMD ["/entrypoint.sh"]
