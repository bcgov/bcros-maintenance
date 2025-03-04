FROM google/cloud-sdk:512.0.0-alpine


WORKDIR /app

RUN echo https://downloads.1password.com/linux/alpinelinux/stable/ >> /etc/apk/repositories \
    && wget https://downloads.1password.com/linux/keys/alpinelinux/support@1password.com-61ddfc31.rsa.pub -P /etc/apk/keys \
    && apk update && apk add 1password-cli \
    && op --version

RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq \
    && chmod +x /usr/local/bin/yq \
    && yq --version

RUN apk --update add jq \
    && jq --version

CMD [ "bash" ]