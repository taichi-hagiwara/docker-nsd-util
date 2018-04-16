FROM xagiwara/nsd

LABEL maintainer "Taichi Hagiwara <xagiwara@gmail.com>"

ENV LDNS_VERSION 1.7.0

RUN apk add --virtual=dev-packs \
               ca-certificates \
               g++ \
               make \
               openssl-dev \
               perl \
               wget \
    # download / extract
    && mkdir /usr/local/src \
    && wget -O - "https://www.nlnetlabs.nl/downloads/ldns/ldns-${LDNS_VERSION}.tar.gz" | tar zxf -  -C /usr/local/src \
    # build
    && cd /usr/local/src/ldns-${LDNS_VERSION} \
    && ./configure --disable-dane-verify \
    && make \
    && make install \
    # build examples
    && cd examples \
    && ./configure \
    && make \
    && make install \
    # cleanup
    && cd / \
    && rm -rf /usr/local/src \
    && apk del dev-packs \
    # user
    && addgroup -S nsd \
    && adduser -S -G nsd nsd \
    && chown nsd:nsd /var/db/nsd \
    && mkdir /etc/nsd/confs \
    && mkdir /etc/nsd/zonefiles

ADD nsd.conf /etc/nsd/nsd.conf
ADD entrypoint.sh /entrypoint.sh

ADD reload.sh /usr/local/bin/reload
ADD rebuild.sh /usr/local/bin/rebuild

RUN chmod +x /usr/local/bin/*

VOLUME /etc/nsd/conf.d
VOLUME /etc/nsd/zonefiles

EXPOSE 53/udp 53

ENTRYPOINT ["sh", "/entrypoint.sh"]

CMD ["start"]
