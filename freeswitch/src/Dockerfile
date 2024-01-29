# vim:set ft=dockerfile:
#-- Bayu Krisnawan <krisna@gmail.com>
#* Memcached Support

#- Memcached Memory
ARG MEMRAM="128"           
ARG MEMMAXSIZE="32m"
#- Memcache Max Memory        
ARG DEBIANVER="debian:bookworm-slim"
ARG TIMEZONE="Asia/Singapore"
ARG "debian:${DEBIANVER}-sli"
ARG YCPATH="/etc/cfg/"
ARG GHPAT="" 
ARG SUPERCONFD="/etc/supervisor/conf.d"
## - URL List
ARG GITHUB="https://${GHPAT}@github.com/BayuKrisnawan"
ARG UNIMRCPDL="https://www.unimrcp.org/project/component-view/unimrcp-deps-1-6-0-tar-gz/download"
ARG YACRON="https://github.com/gjcarneiro/yacron/releases/download/0.19.0/yacron-0.19.0-x86_64-unknown-linux-gnu"

FROM ${DEBIANVER} as base
ARG DEBIANVER

RUN apt -y update \
    && apt install -y locales 2>/dev/null \ 
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 >/dev/null 2>&1
ENV LANG en_US.utf8

RUN apt list --installed  >/tmp/apt-base.txt 2>/dev/null \ 
    && find / -type f| grep ^"var\|usr"|grep -v "/usr/src/"|sort >/files-base.txt 2>/dev/null \
    && apt install -y vim-tiny memcached net-tools sngrep procps git-core curl unzip tar lsb-release apt-transport-https ca-certificates nasm  \
    build-essential cmake automake autoconf libtool-bin pkg-config zlib1g-dev libdb-dev libncurses5-dev \
    libexpat1-dev libgdbm-dev bison erlang-dev libtpl-dev libtiff5-dev uuid-dev libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev  \
    libogg-dev libspeex-dev libspeexdsp-dev python3-dev libavformat-dev libswscale-dev liblua5.2-dev \
    libopus-dev libpq-dev flite1-dev libmagickcore-dev libsndfile1-dev libflac-dev libogg-dev libvorbis-dev \
    libmp3lame-dev libmpg123-dev libevent-dev libssl-dev libldns-dev libshout3-dev libmemcached-dev  \
    && find / -type f| grep ^"var\|usr"|grep -v "/usr/src/"|sort >/files-pre-build.txt 2>/dev/null \
    && apt list --installed  >/tmp/apt-dev.txt 2>/dev/null 

FROM base as build

ARG GITHUB
ARG UNIMRCPDL

COPY build/generatefs.sh /

#Initial default Freeswitch Installation
RUN git clone          ${GITHUB}/freeswitch.git /usr/src/freeswitch \
    && git clone       ${GITHUB}/libks.git /usr/src/libks \
    && git clone       ${GITHUB}/sofia-sip.git /usr/src/sofia-sip \
    && git clone       ${GITHUB}/signalwire-c.git /usr/src/signalwire-c \
    && git clone -b fs ${GITHUB}/spandsp.git /usr/src/spandsp \
    && git clone       ${GITHUB}/mod_bcg729.git /usr/src/mod_bcg729 \
    && git clone       ${GITHUB}/unimrcp.git /usr/src/unimrcp  \
    && git clone       ${GITHUB}/mod_unimrcp.git /usr/src/mod_unimrcp \
# Enable modules
    && sed -i 's|#applications/mod_avmd|applications/mod_avmd|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_callcenter|applications/mod_callcenter|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_cidlookup|applications/mod_cidlookup|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_curl|applications/mod_curl|' /usr/src/freeswitch/build/modules.conf.in  \
    && sed -i 's|#applications/mod_directory|applications/mod_directory|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_distributor|applications/mod_distributor|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_easyroute|applications/mod_easyroute|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_esl|applications/mod_esl|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_lcr|applications/mod_lcr|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_memcache|applications/mod_memcache|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|applications/mod_signalwire|#applications/mod_signalwire|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|applications/mod_spy|#applications/mod_spy|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|applications/mod_stress|#applications/mod_stress|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_translate|applications/mod_translate|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#applications/mod_voicemail_ivr|applications/mod_voicemail_ivr|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#asr_tts/mod_flite|asr_tts/mod_flite|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#asr_tts/mod_tts_commandline|asr_tts/mod_tts_commandline|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#codecs/mod_amrwb|codecs/mod_amrwb|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#codecs/codecs/mod_codec2|codecs/codecs/mod_codec2|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|dialplans/mod_dialplan_asterisk|#dialplans/mod_dialplan_asterisk|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|endpoints/mod_verto|#endpoints/mod_verto|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|event_handlers/mod_cdr_sqlite|#event_handlers/mod_cdr_sqlite|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#event_handlers/mod_json_cdr|event_handlers/mod_json_cdr|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#formats/mod_imagick|formats/mod_imagick|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#formats/mod_shout|formats/mod_shout|' /usr/src/freeswitch/build/modules.conf.in \
    && sed -i 's|#say/mod|say/mod|' /usr/src/freeswitch/build/modules.conf.in 
#Dependency:libks
RUN  cd /usr/src/libks && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 \
    && make install \
#Dependency:sofia-sip
    && cd /usr/src/sofia-sip && ./bootstrap.sh \
    && ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr \
    && make -j`nproc --all` && make install \
#Dependency:spandsp
    && cd /usr/src/spandsp && ./bootstrap.sh  && ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr \
    && make -j`nproc --all` && make install 
#Dependency:signalwire-c
RUN cd /usr/src/signalwire-c \
    && PKG_CONFIG_PATH=/usr/lib/pkgconfig cmake . -DCMAKE_INSTALL_PREFIX=/usr \
    && make install \
#Build Freeswitch
    && cd /usr/src/freeswitch && ./bootstrap.sh -j \
    && cd /usr/src/freeswitch && ./configure --prefix=/usr   \
    --sysconfdir=/etc --sharedstatedir=/usr/share/freeswitch  --localstatedir=/var \
    --disable-dependency-tracking --enable-zrtp --with-openssl --with-gnu-ld \
    --enable-portable-binary --enable-core-pgsql-support \
    && cd /usr/src/freeswitch && make -j`nproc` && make install  
#BCG729
RUN cd /usr/src/mod_bcg729 && make && make install \
#Unimrcp
    && curl ${UNIMRCPDL} -o /usr/src/unimrcp-deps-1.6.0.tar.gz \
    && cd /usr/src &&  tar xzf unimrcp-deps-1.6.0.tar.gz \
    && cd /usr/src/unimrcp-deps-1.6.0/libs/apr && ./configure --prefix=/usr && make && make install \
    && cd /usr/src/unimrcp-deps-1.6.0/libs/apr-util && ./configure --prefix=/usr --with-apr=/usr  && make && make install \
    && cd /usr/src/unimrcp && ./bootstrap && ./configure --prefix=/usr/unimrcp --with-sofia-sip=/usr && make && make install \
    && cd /usr/src/mod_unimrcp && export PKG_CONFIG_PATH=/usr/lib/pkgconfig:/usr/unimrcp/lib/pkgconfig  && ./bootstrap.sh \
    && ./configure --prefix=/usr && make && make install 
RUN find / -type f| grep ^"var\|usr"|grep -v "/usr/src/"|sort >/files-pra-build.txt 2>/dev/null \
    && apt --yes update && apt --yes install memcached vim-tiny \
    && echo "/usr/bin/netstat">>/files-pra-build.txt && echo "/usr/bin/ps" >> /files-pra-build.txt \
    && echo "/usr/bin/top">>/files-pra-build.txt && echo "/usr/bin/sngrep" >> /files-pra-build.txt \
    && echo "/usr/bin/memcached">>/files-pra-build.txt && echo "/usr/bin/vi" >> /files-pra-build.txt \
    && bash /generatefs.sh && mkdir /target && cd /target && tar zxpf /freeswitch.tar.gz 

FROM ${DEBIANVER} as final

ARG DEBIANVER
ARG TIMEZONE
ARG MEMRAM
ARG MEMMAXSIZE
ARG SUPERCONFD
ARG YACRON
ARG YCPATH

WORKDIR /

COPY build/entrypoint.sh /
COPY build/*.limits.conf /etc/security/limits.d/

RUN apt --yes update  \
    && apt install --yes  supervisor curl tzdata  \
    ## Timezone
    && echo "$TIMEZONE" >  /etc/timezone \
    && ln -fs /usr/share/zoneinfo/$(cat /etc/timezone) /etc/localtime \
    && dpkg-reconfigure --frontend noninteractive tzdata \
    ## Final CLEANUP
    && apt --yes clean && apt list --installed  >/tmp/installed.txt 2>/dev/null \
    && grep 'xxd\|xauth\|dbus\|-dev\|openssh.*installed' /tmp/installed.txt |cut -d \/ -f1 |xargs  apt --yes purge \
    && apt --yes --auto-remove purge \
    # && tar zxvf /freeswitch.tar.gz -C /  && rm /freeswitch.tar.gz \
    && rm -rf /tmp/installed.txt /var/lib/apt/lists/ /usr/include /usr/share/doc /usr/games \
        /etc/cron.d* /etc/rc?.d/ \
    && ln -s /usr/bin/vim.tiny /etc/alternatives/vi

COPY --from=build /target/usr/ /usr/
COPY --from=build /target/lib/ /usr/lib/

    ## FreeSWITCH Supervisor
RUN echo "[program:freeswitch]" >  ${SUPERCONFD}/freeswitch.conf \
    && echo "command=/usr/bin/freeswitch -nc -nf" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "autostart=true" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "autorestart=true" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "umask=003" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "priority=999" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "stopsignal=TERM" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "startretries=1000" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "stopwaitsecs=5" >> ${SUPERCONFD}/freeswitch.conf \
    && echo "stopasgroup=true" >> ${SUPERCONFD}/freeswitch.conf \
    ## Memcached Supervisor
    && echo "[program:memcached]" >  ${SUPERCONFD}/memcached.conf \
    && echo "command=/usr/bin/memcached --user=root  -m ${MEMRAM} -p 11211 -l 127.0.0.1 -I ${MEMMAXSIZE}" >>  ${SUPERCONFD}/memcached.conf \
    && echo "autostart=true" >> ${SUPERCONFD}/memcached.conf \
    && echo "autorestart=true" >> ${SUPERCONFD}/memcached.conf \
    && echo "umask=003" >> ${SUPERCONFD}/memcached.conf \
    && echo "priority=999" >> ${SUPERCONFD}/memcached.conf \
    && echo "stopsignal=TERM" >> ${SUPERCONFD}/memcached.conf \
    && echo "startretries=1000" >> ${SUPERCONFD}/memcached.conf \
    && echo "stopwaitsecs=5" >> ${SUPERCONFD}/memcached.conf \
    && echo "stopasgroup=true" >> ${SUPERCONFD}/memcached.conf \
    # YaCron Schedule
    && curl -L ${YACRON} -o /usr/sbin/yacron && chmod 755 /usr/sbin/yacron \
    && mkdir -p ${YCPATH} \
    && echo "[program:yacron]" >  ${SUPERCONFD}/yacron.conf \
    && echo "command=/usr/sbin/yacron -c ${YCPATH}yacron.yaml" >>  ${SUPERCONFD}/yacron.conf \
    && echo "autostart=true" >> ${SUPERCONFD}/yacron.conf \
    && echo "autorestart=true" >> ${SUPERCONFD}/yacron.conf \
    && echo "umask=003" >> ${SUPERCONFD}/yacron.conf \
    && echo "priority=999" >> ${SUPERCONFD}/yacron.conf \
    && echo "stopsignal=TERM" >> ${SUPERCONFD}/yacron.conf \
    && echo "startretries=1000" >> ${SUPERCONFD}/yacron.conf \
    && echo "stopwaitsecs=5" >> ${SUPERCONFD}/yacron.conf \
    && echo "stopasgroup=true" >> ${SUPERCONFD}/yacron.conf \
    && echo "jobs:" >${YCPATH}yacron.yaml \
    && echo "  - name: fscli" >> ${YCPATH}yacron.yaml \
    && echo "    command: |" >> ${YCPATH}yacron.yaml \
    && echo "       date >/tmp/status.log &&" >> ${YCPATH}yacron.yaml \
    && echo "       sleep 1 && exit 0" >> ${YCPATH}yacron.yaml \
    && echo "    schedule: '*/30 * * * *'">>${YCPATH}yacron.yaml \ 
    ## Extract FreeSwitch Files
    && mkdir  -p /var/log/{supervisor,freeswitch} /etc/freeswitch /var/lib/freeswitch 

WORKDIR /root
## Ports
EXPOSE 443/tcp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 6050/tcp 6050/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 7443/tcp
EXPOSE 5070/udp 5070/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp
 
ENTRYPOINT ["/entrypoint.sh"]
