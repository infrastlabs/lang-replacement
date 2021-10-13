
REPO="https://gitee.com/g-devops/fk-portainer"
# BRANCH="release/2.9"
TAG="2.9.0" #TAG

errExit(){
    echo "$1"
    exit 1
}
test -z "$BRANCH" && test -z "$TAG" && errExit "BRANCH/TAG both emp, must set one"
if [ ! -z "$BRANCH" ]; then
    # ; git pull
    test -d pt0 && (cd pt0; git fetch; git checkout origin/$BRANCH) || git clone -b $BRANCH $REPO pt0 #--depth=1 
else
    # test -z "$BRANCH" && BRANCH=$TAG #use tag
    # -b "br-$TAG" 
    test -d pt0 && (cd pt0; git fetch origin tag $TAG; git checkout $TAG) || git clone -b $TAG $REPO pt0 #--depth=1 
fi


echo building...; sleep 10
# REPLACE
mkdir -p .cache/node_modules
rm -rf portainer0; cp -a pt0 portainer0
cd portainer0
    rm -rf node_modules;  ln -s ../.cache/node_modules .;
    yarn config set registry https://registry.npm.taobao.org -g
    yarn config set sass_binary_site http://cdn.npm.taobao.org/dist/node-sass -g
    yarn install #imageUtils's deps hand breadIns; #395M
