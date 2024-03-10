FROM ubuntu:noble

# NGINX as a Mail Proxy Server

RUN set -x \
# create nginx user/group first, to be consistent throughout docker variants
    && groupadd --system --gid 101 nginx \
    && useradd --system --no-create-home --comment "nginx user" --shell /bin/false --gid 101 --uid 101 nginx \
    && apt-get update \
    && apt-get upgrade -y \
    # mail proxy libnginx-mod-mail
    && apt-get install --no-install-recommends --no-install-suggests -y nginx-full ssl-cert fcgiwrap libfcgi-bin libnginx-mod-mail \
    && apt-get remove --purge --auto-remove -y && rm -rf /var/lib/apt/lists/* \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    # create a docker-entrypoint.d directory
    && mkdir /docker-entrypoint.d

COPY docker-entrypoint.sh /
COPY 10-listen-on-ipv6-by-default.sh /docker-entrypoint.d
COPY 15-local-resolvers.envsh /docker-entrypoint.d
COPY 20-envsubst-on-templates.sh /docker-entrypoint.d
COPY 30-tune-worker-processes.sh /docker-entrypoint.d
ENTRYPOINT ["/docker-entrypoint.sh"]    

EXPOSE 80
EXPOSE 25

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]