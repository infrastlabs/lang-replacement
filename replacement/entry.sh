#!/bin/bash
# cur=$(cd "$(dirname "$0")"; pwd)
# cd $cur

function npmBuild(){
    cd /output/portainer

    # # npm
    # npm -v
    # npm config set registry=https://registry.npm.taobao.org -g
    # npm config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g
    # # npm install -g yarn #installed
    # # grunt
    # npm install -g grunt-cli
    # grunt -h

    # # yarn
    # yarn -v
    # yarn config set registry https://registry.npm.taobao.org -g
    # yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g
    # .cache
    # mkdir -p /output/.cache/node_modules; rm -rf node_modules;  ln -s /output/.cache/node_modules .;
    rm -rf node_modules;  ln -s /.cache/node_modules .;
    # yarn install

    ## grunt build
    # grunt build #OK
    # npm run build
    ## grunt build prod
    rm -f webpack/webpack.production.js; cp /conf/webpack.production.js webpack/webpack.production.js
    rm -f gruntfile.js; cp /conf/gruntfile.js gruntfile.js
    grunt devopsbuild
}

# repo
function getRepo(){
    errExit(){
        echo "$1"
        exit 1
    }
    test -z "$BRANCH" && test -z "$TAG" && errExit "BRANCH/TAG both emp, must set one"
    if [ ! -z "$BRANCH" ]; then
        test -d pt0 && (cd pt0; git fetch -t; git checkout origin/$BRANCH) || (git clone -b $BRANCH $REPO pt0; cd pt0; git checkout origin/$BRANCH) #--depth=1 
    else
        test -d pt0 && (cd pt0; git fetch origin tag $TAG; git checkout $TAG) || git clone -b $TAG $REPO pt0 #--depth=1 
    fi
}
# REPO="https://gitee.com/g-devops/fk-portainer"
# BRANCH="release/2.9"
# TAG="2.9.0" #TAG
# test -d pt0 && (cd pt0; git pull) || git clone --depth=1 -b $BRANCH $REPO pt0
getRepo

# dict portainer_zh.xml
curl -O https://gitee.com/g-devops/lang-replacement/raw/dev/generate/portainer_zh.xml

# REPLACE
rm -rf portainer; cp -a pt0 portainer
# out app/.lang-replacement
lang-replacement ./portainer_zh.xml ./portainer/app
rm -rf .lang-replacement; mv ./portainer/app/.lang-replacement .
# BUILD
npmBuild

# PACK
cd /output/portainer/dist; tar -zcf ./public.tar.gz public
ls -lh /output/portainer/dist/