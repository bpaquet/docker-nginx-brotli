FROM nginx:alpine

RUN apk add --virtual .build gcc make libc-dev pcre-dev zlib-dev git \
  && NGINX_VERSION=$(nginx -v 2>&1 | awk -F/ '{print$2}') \
  && echo Building brotli for nginx $NGINX_VERSION \
  && mkdir /work \
  && cd /work \
  && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && git clone https://github.com/eustas/ngx_brotli.git \
  && cd ngx_brotli \
  && git checkout 28ce18 \
  && git submodule update --init \
  && cd /work \
  && tar xzf nginx-$NGINX_VERSION.tar.gz \
  && cd nginx-$NGINX_VERSION \
  && ./configure --with-compat --add-dynamic-module=/work/ngx_brotli \
  && make modules \
  && install -m755 objs/ngx_http_brotli_filter_module.so /usr/lib/nginx/modules/ngx_http_brotli_filter_module.so \
  && install -m755 objs/ngx_http_brotli_static_module.so /usr/lib/nginx/modules/ngx_http_brotli_static_module.so \
  && (echo "load_module modules/ngx_http_brotli_static_module.so;" && echo "load_module modules/ngx_http_brotli_filter_module.so;" && cat /etc/nginx/nginx.conf) > /etc/nginx/nginx.conf2 \
  && mv /etc/nginx/nginx.conf2 /etc/nginx/nginx.conf \
  && apk del .build \
  && rm -rf /work
