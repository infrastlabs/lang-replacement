FROM registry.cn-shenzhen.aliyuncs.com/infrastlabs/golang:1.13.9-alpine3.10 as builder

# use go modules
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn
WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -o godiff -x -v -ldflags "-s -w $flags" ./diff/main.go; \
  go build -x -v -ldflags "-s -w $flags" ./

FROM alpine
ENV LANG="en_US.UTF-8" \
    LC_ALL="C.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm"
RUN apk --update add \
      ca-certificates \
      curl bash jq \
      vim git \
      && rm -rf /tmp/src && rm -rf /var/cache/apk/*
WORKDIR /app
COPY --from=builder /src/lang-replacement /app
COPY --from=builder /src/godiff /app
ADD ./gitdiff.sh /app

# EXPOSE 80
ENV GENERATE_REPO="https://gitee.com/g-devops/fk-portainer" \
    GENERATE_BRANCH="br-v29-lang" \
    GENERATE_OUTPUT="portainer_zh.xml" \
    REPLACE_REPO="https://gitee.com/g-devops/fk-portainer" \ 
    REPLACE_BRANCH="release/2.9" \
    EXEC_TYPE="GENERATE"
ENTRYPOINT /stack-update.sh
