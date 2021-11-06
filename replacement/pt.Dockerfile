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
ENV \
    REPO="https://gitee.com/g-devops/fk-portainer" \ 
    # TAG="2.9.1"
    # TAG="v291-patch"
    BRANCH="sam-custom"    
# VOLUME ["/data"]
# EXPOSE 8080
ENTRYPOINT ["/entry.sh"]
RUN apk add libpng

#############
#just lastStage build ##echo 123: force new build.
RUN echo aa.12; /entry.sh
##########################################
# PT/API
# FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/golang:1.13.9-alpine3.10 as api
# FROM golang:1.16.9-alpine3.14 as api
FROM golang:1.16.8-alpine3.14 as api
# use go modules
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

# Build
RUN domain="mirrors.aliyun.com" \
&& echo "http://$domain/alpine/v3.14/main" > /etc/apk/repositories \
&& echo "http://$domain/alpine/v3.14/community" >> /etc/apk/repositories \
&& apk add curl tree bash git 
#git: for build_ver

# Copy in the go src
WORKDIR /src
ENV \
    REPO="https://gitee.com/g-devops/fk-portainer" \ 
    BRANCH="sam-custom"
    # TAG="2.9.1"

# COPY . .
RUN echo aa.1; \
  git clone --depth=1 -b $BRANCH$TAG $REPO pt0; cd pt0/api; ls -lh; \
  CGO_ENABLED=0 \
  go build -o portainer -v -ldflags "-s -w $flags" ./cmd/portainer/

##########################################
FROM portainer/portainer-ce:2.9.1-alpine
RUN rm -rf /public /portainer
COPY --from=api /src/pt0/api/portainer /portainer
COPY --from=builder /output/portainer/dist/public/ /public/
RUN ls -lh /public

