cur=$(cd "$(dirname "$0")"; pwd)
cd $cur

# REPO="https://gitee.com/g-devops/fk-portainer"
# BRANCH="br-lang3"
# git clone -b $BRANCH $REPO portainer
# # export SOURCE=portainer/app
# # export CMP1=055c57
# # export CMP2=origin/br-v29-lang


# git clone $GENERATE_REPO $srcGenerate #each newDir, just normal clone.
# repo
function getRepo(){
    errExit(){
        echo "$1"
        exit 1
    }
    if [ ! -d $srcGenerate ]; then
        git clone $GENERATE_REPO $srcGenerate #--depth=1
    else
        cd $srcGenerate; 
            git fetch
            # if both tag:
            git fetch origin tag $CMP1
            git fetch origin tag $CMP2 #if branch, with err, just ignore
    fi
}
# getRepo

GENERATE_REPO="https://gitee.com/g-devops/fk-portainer"
mkdir -p $cur/.cache; srcGenerate=$cur/.cache/pt0_dict
# export SOURCE="/_ext/working/_ct/fk-portainer/app"
# export SOURCE="/_ext/bbox/_ee/fk-portainer/app"
export CMP1=2.9.1
# export CMP1=3a9301ef93da898d581fb909cfd473f24584a497
export CMP1=4a98a2b089d9f3895e0e041e5c2a49cb4ee024b8 #gen dict_button_th_placeholer.txt
export CMP2=origin/br-lang3 #origin/br-v29-lang
export SOURCE=$srcGenerate/app
# export CMP1=604f2823428aa26401b5b0f1ba118eb494325edb #origin/br-v29-lang
# export CMP2=origin/br-lang2


getRepo
export OUTPUT="$cur/portainer_zh.xml"
$cur/gitdiff.sh
