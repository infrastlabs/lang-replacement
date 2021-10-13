FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:dict as bins
FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:cache as cache

# ref: dvp-ci-mgr.ui-frontend
# FROM node:10.15.0-alpine AS builder
 # ref: docs-devops_vuepress
 # node:14.13.1-alpine #39.36 MB
 # node:14.13.1-stretch-slim #57.83 MB
# FROM node:14.13.1-alpine AS builder
FROM node:14.13.1-stretch-slim AS builder

# RUN domain="mirrors.aliyun.com" \
# && echo "http://$domain/alpine/v3.8/main" > /etc/apk/repositories \
# && echo "http://$domain/alpine/v3.8/community" >> /etc/apk/repositories \
# && apk add git bash curl wget jq
# portainer: yarn install
# RUN apk add autoconf libtool libpng automake gcc
RUN domain="mirrors.163.com" \
  && echo "deb http://$domain/debian/ stretch main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://$domain/debian/ stretch-updates main contrib non-free">> /etc/apt/sources.list; \
  \
  echo 'apt update -qq && apt install -yq --no-install-recommends $@ && apt-get clean && rm -rf /var/lib/apt/lists/*; ' > /usr/local/bin/apt.sh \
  && chmod +x /usr/local/bin/apt.sh
RUN apt.sh \ git bash curl wget jq libpng*

RUN \
    # npm
    npm -v; \
    npm config set registry=https://registry.npm.taobao.org -g; \
    npm config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g; \
    # npm install -g yarn #installed
    # grunt
    npm install -g grunt-cli; \
    grunt -h; \
    # yarn
    yarn -v; \
    yarn config set registry https://registry.npm.taobao.org -g; \
    yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g

# TODO: node_mods from res_repo
# ADD ./node_modules /.cache/node_modules
COPY --from=cache /.cache/node_modules /.cache/node_modules
ADD ./entry.sh /entry.sh
ADD ./conf/webpack.production.js /conf/webpack.production.js
ADD ./conf/gruntfile.js /conf/gruntfile.js
COPY --from=bins /generate/lang-replacement /usr/local/bin/
WORKDIR /output

# VOLUME ["/data"]
# EXPOSE 8080
ENTRYPOINT ["/entry.sh"]
# RUN apk add libpng