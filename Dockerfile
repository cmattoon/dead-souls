FROM library/golang:buster AS gotpl

RUN go get github.com/tsg/gotpl

FROM library/ubuntu

ARG DS_VERSION
ARG VCS_REF
ARG BUILD_DATE

COPY --from=gotpl /go/bin/gotpl /bin/gotpl

WORKDIR /opt/deadsouls-${DS_VERSION}

RUN apt-get -y update && apt-get -y install \
    wget \
    build-essential \
    libc6-dev \
    bison \
    zip \
    locales \
    language-pack-en-base 

ENV MUDHOME "/opt/deadsouls"

ENV "LANG"     "en_US.utf8"
ENV "LANGUAGE" "en_US.utf8"
ENV "LC_ALL"   "en_US.utf8"

COPY files/ds${DS_VERSION}.zip .

RUN unzip ds${DS_VERSION}.zip && rm ds${DS_VERSION}.zip && mv -f ds${DS_VERSION} /opt/deadsouls

WORKDIR $MUDHOME

RUN cd fluffos* && ./configure && make install

COPY files/mudos.tpl $MUDHOME/mudos.tpl

# do this here to avoid these volumes being owned by root. otherwise, need to chown to deadsouls UID on host
RUN mkdir -p $MUDHOME/config && mkdir -p $MUDHOME/logs && mkdir -p $MUDHOME/lib && mkdir -p $MUDHOME/custom-lib

RUN useradd deadsouls && chown -R deadsouls:deadsouls /opt/deadsouls

COPY files/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER deadsouls

ENV "MUDHOME"  "/opt/deadsouls"
ENV "LANG"     "en_US.utf8"
ENV "LANGUAGE" "en_US.utf8"
ENV "LC_ALL"   "en_US.utf8"

RUN umask 007

VOLUME ["$MUDHOME/lib", "$MUDHOME/custom-lib", "$MUDHOME/config", "$MUDHOME/custom-lib"]

EXPOSE 6666

EXPOSE 8099

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.name="dead-souls"
LABEL org.label-schema.description="DeadSouls MUD Server"
LABEL org.label-schema.vendor="Unofficial Dead Souls Image"
LABEL org.label-schema.url="http://dead-souls.net"
LABEL org.label-schema.vcs-url="https://github.com/cmattoon/dead-souls.git"

LABEL org.label-schema.usage="/opt/deadsouls/README.txt"

LABEL org.label-schema.docker.cmd="docker run -p 6666:6666 -p 8099:8099 -v $(pwd)/config:/opt/deadsouls/config -t cmattoon/deadsouls:v${DS_VERSION}"

LABEL org.label-schema.build-date="${BUILD_DATE}"
LABEL org.label-schema.vcs-ref="${VCS_REF}"
LABEL org.label-schema.version="${DS_VERSION}"

ENTRYPOINT ["/entrypoint.sh"]
