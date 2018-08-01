FROM docker:18.06.0-ce-dind

RUN wget \
      --output-document s2i.tgz \
      --quiet \
      https://github.com/openshift/source-to-image/releases/download/v1.1.10/source-to-image-v1.1.10-27f0729d-linux-amd64.tar.gz \
    && tar xzf s2i.tgz \
    && rm -f s2i.tgz sti \
    && mv s2i /usr/local/bin/s2i

COPY entrypoint.sh /usr/local/bin/s2i-entrypoint.sh
RUN chmod +x /usr/local/bin/s2i-entrypoint.sh

RUN apk -Uuv add bash jq
RUN apk -Uuv --repository http://dl-3.alpinelinux.org/alpine/edge/testing add aws-cli

ENTRYPOINT ["/usr/local/bin/s2i-entrypoint.sh"]
