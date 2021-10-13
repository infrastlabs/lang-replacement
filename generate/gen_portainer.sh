cur=$(cd "$(dirname "$0")"; pwd)
cd $cur

REPO="https://gitee.com/g-devops/fk-portainer"
BRANCH="br-v29-lang"
# git clone -b $BRANCH $REPO portainer
# export SOURCE=portainer/app
# export CMP1=055c57
# export CMP2=origin/br-v29-lang

export SOURCE="/_ext/working/_ct/fk-portainer/app"
# export SOURCE="/_ext/bbox/_ee/fk-portainer/app"
export CMP1=604f2823428aa26401b5b0f1ba118eb494325edb
export CMP2=br-lang2 #origin/br-v29-lang
# export SOURCE="portainer/app"
# export CMP1=604f2823428aa26401b5b0f1ba118eb494325edb #origin/br-v29-lang
# export CMP2=origin/br-lang2
export OUTPUT="$cur/portainer_zh.xml"
./gitdiff.sh
