#!/bin/bash
REPO=https://gitee.com/g-devops/fk-portainer
BRANCH=release/2.9 #TAG=v291-patch
test -z "$PRV_REPO"   || REPO=$PRV_REPO
test -z "$PRV_BRANCH" || BRANCH=$PRV_BRANCH

barge=/mnt/data # /mnt/mnt/data/dbox_ext
repimg=registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:replace
docker run -it --rm \
  -e REPO=$REPO -e BRANCH=$BRANCH \
  -v $barge$(pwd)/output2:/output $repimg

