FROM tarantool/tarantool

RUN set -x \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        gcc \
        g++ \
    && cd /opt/tarantool/ \
    && tarantoolctl rocks install http 2.0.1-1\
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY *.lua /opt/tarantool/
EXPOSE 3301
WORKDIR /opt/tarantool

CMD ["tarantool", "server.lua"]
