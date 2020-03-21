FROM nginx:1.17-alpine

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Otus Linux 11-docker" \
      org.label-schema.vcs-url="https://github.com/MichaelPak/otus-linux" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN rm -f /etc/nginx/conf.d/default.conf

ADD front/app.conf /etc/nginx/conf.d/
ADD front/index.html /usr/share/nginx/html/index.html
