cur=$(cd "$(dirname "$0")"; pwd)
cd $cur

REPO="https://gitee.com/g-devops/fk-portainer"
BRANCH="br-v29-lang"
git clone -b $BRANCH $REPO portainer

export SOURCE=portainer/app
export CMP1=055c57
export CMP2=br-v29-lang
export OUTPUT="$cur/portainer_zh.xml"
./gitdiff.sh
