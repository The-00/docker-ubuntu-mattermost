FROM dotriver/alpine-s6

ARG edition=team
ARG MM_VERSION=6.1.0

RUN sed -i "s/3.12/3.14/g" /etc/apk/repositories \
    && apk update \
    && apk upgrade

# install mattermost
RUN set -x \
    && apk --no-cache add curl gnupg ca-certificates jq libc6-compat libffi-dev libcap linux-headers mailcap netcat-openbsd xmlsec-dev tzdata inotify-tools \
    && rm -rf /tmp/*

RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins && \
    if [ "$edition" = "team" ] ; \
        then curl https://releases.mattermost.com/$MM_VERSION/mattermost-team-$MM_VERSION-linux-amd64.tar.gz?src=docker-app | tar -xvz ; \
        else curl https://releases.mattermost.com/$MM_VERSION/mattermost-$MM_VERSION-linux-amd64.tar.gz?src=docker-app      | tar -xvz ; \
    fi \
    && cp /mattermost/config/config.json /config.json.save \
    && rm -rf /mattermost/config/config.json \
    && setcap cap_net_bind_service=+ep /mattermost/bin/mattermost

# install ldap-link
RUN set -x \
    && apk add --no-cache add php7 php7-ldap php7-pgsql php7-mysqli php7-pdo php7-xml nginx \
    && mkdir -p /run/nginx/ \
    && rm -R /var/www/* || true \
    && chown nginx:nginx /var/www/ /run/nginx/ \
    && rm -rf /tmp/* \

ADD conf/ /

RUN set -x \
    && chmod +x /etc/cont-init.d/ -R \
    && chmod +x /etc/periodic/ -R  \
    && chmod +x /etc/s6/services/ -R
