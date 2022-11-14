FROM sommerfeldio/git:ci-build
LABEL maintainer="sebastian@sommerfeld.io"

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends make=4.3-4.1 \
    && apt-get install -y --no-install-recommends gawk=1:5.1.0-1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --recursive https://github.com/reconquest/shdoc /tmp/shdoc
WORKDIR /tmp/shdoc
RUN make install

COPY assets/index-template.adoc /tmp/index-template.adoc
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
