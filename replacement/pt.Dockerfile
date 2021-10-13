FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:dict as bins
FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:cache as cache

# ref: dvp-ci-mgr.ui-frontend
# FROM node:10.15.0-alpine AS builder
# ref: docs-devops_vuepress
FROM node:14.13.1-alpine AS builder
MAINTAINER sam <sam@devcn.top>

RUN domain="mirrors.aliyun.com" \
&& echo "http://$domain/alpine/v3.8/main" > /etc/apk/repositories \
&& echo "http://$domain/alpine/v3.8/community" >> /etc/apk/repositories \
&& apk add git bash curl wget jq
# portainer: yarn install
# RUN apk add autoconf libtool libpng automake gcc

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
RUN apk add libpng

#####################
#just lastStage build
RUN /entry.sh
FROM portainer/portainer-ce:2.9.1-alpine
RUN rm -rf /public
COPY --from=builder /output/portainer/dist/public/ /public/
RUN ls -lh /public

