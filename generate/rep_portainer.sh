cur=$(cd "$(dirname "$0")"; pwd)
cd $cur

REPO="https://gitee.com/g-devops/fk-portainer"
BRANCH="release/2.9"
# git clone --depth=1 -b $BRANCH $REPO portainer

./lang-replacement ./portainer_zh.xml ./portainer/app
