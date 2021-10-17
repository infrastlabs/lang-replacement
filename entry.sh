#!/bin/bash

# $AUTH #-b $GENERATE_BRANCH
# TODO /output/.cache/pt0_dict
mkdir -p /output/.cache; srcGenerate=/output/.cache/pt0_dict
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
            git fetch origin tag $CMP2
    fi
}
getRepo


# wget newest dictions
file=dictReplace.txt; wget -qO /generate/$file https://gitee.com/g-devops/lang-replacement/raw/dev/generate/$file
cat /generate/$file |wc
file=dict_fications.txt; wget -qO /generate/$file https://gitee.com/g-devops/lang-replacement/raw/dev/generate/$file
cat /generate/$file |wc
echo -e "已获取最新replaceDict, 请注意获取到dict的行数(避免无效数据) \n准备clone仓库反向分析 生成替换字典：(sleep 5)"; sleep 5

outPath="/output" && mkdir -p $outPath
# export CMP1=055c57
# export CMP2=br-lang2
export SOURCE=$srcGenerate/app
export OUTPUT=$outPath/$GENERATE_OUTPUT 
/generate/gitdiff.sh

# view
cat $OUTPUT |wc; tail -30 $OUTPUT
# /generate/transfer -f -s $OUTPUT -t /tmp/view.json; cat /tmp/view.json |jq #tranferErr: got "null"
# cat $OUTPUT |/generate/xml2json |jq #nonViewHere
