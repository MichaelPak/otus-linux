FROM python:3.7-alpine

ARG VCS_REF

LABEL org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Otus Linux 11-docker" \
      org.label-schema.vcs-url="https://github.com/MichaelPak/otus-linux" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

WORKDIR /app

COPY requirements.txt /app/
RUN pip install -r requirements.txt

COPY server.py /app/

CMD ["gunicorn", "-w 4", "server:app"]
