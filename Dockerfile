FROM tarantool/tarantool:1.10.2
COPY ./ /opt/tarantool
EXPOSE 8080
CMD ["tarantool", "/opt/tarantool/server.lua"]
