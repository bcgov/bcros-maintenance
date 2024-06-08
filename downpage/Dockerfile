FROM nginx:1.27.0

ARG VCS_REF="missing"
ARG BUILD_DATE="missing"

ENV VCS_REF=${VCS_REF}
ENV BUILD_DATE=${BUILD_DATE}

LABEL org.label-schema.vcs-ref=${VCS_REF} \
    org.label-schema.build-date=${BUILD_DATE}

ADD nginx.conf /etc/nginx/nginx.conf

RUN mkdir /app
COPY index.html /app
COPY assets /app

EXPOSE 8080:8080

CMD ["nginx", "-g", "daemon off;"]
