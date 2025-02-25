#
# HTTPbin over HTTP/2 Dockerfile
#
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV VENV_PATH=/opt/venv
ENV PATH="$VENV_PATH/bin:$PATH"

RUN \
  apt-get update && apt-get install --no-install-recommends build-essential python3.12-venv python3-dev python3-pip python3-setuptools nghttp2 -y && \
  python3 -m venv $VENV_PATH && \
  $VENV_PATH/bin/pip install --upgrade pip==25.0.01 && \
  $VENV_PATH/bin/pip install gunicorn==23.0.0 httpbin==0.10.2 && \
  echo 'frontend=0.0.0.0,8000;no-tls' > nghttp2-proxy.conf && \
  echo 'backend=127.0.0.1,8001' >> nghttp2-proxy.conf && \
  echo '#!/bin/sh' > run.sh && \
  echo 'exec gunicorn --bind=127.0.0.1:8001 httpbin:app &' >> run.sh && \
  echo 'exec nghttpx --conf=nghttp2-proxy.conf' >> run.sh && \
  echo 'wait' >> run.sh && \
  echo 'kill -s TERM %-' >> run.sh && \
  chmod +x run.sh && \
  apt-get remove --purge build-essential python3-dev -y && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*
  
EXPOSE 8000
  
CMD ["./run.sh"]

