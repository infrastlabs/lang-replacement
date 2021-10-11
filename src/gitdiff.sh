
#!/bin/bash
set -e
cur=$(cd "$(dirname "$0")"; pwd)
GODIFF="$cur/main"
# SOURCE="/_ext/bbox/_ee/fk-portainer/app"
# SOURCE=/_ext/working/_ct/fk-portainer/app
# CMP1=bdb827fb081c44388f8fd506fa318a03b960fa11 #CMP1, CMP2: if not set, compare local with origin
# CMP2=e1c2e0439ff627a45b7ee0967309eb4460c44b4c
# OUTPUT=$cur/tpl/gen/gen1-trans.xml
# deps: git diff; go-diff

cd $SOURCE
tmp=/tmp/.gitdiff && mkdir -p $tmp

function doOneLine(){
    local lineAnayFile=$1
    cat $lineAnayFile |grep -v "^$" |while read rep0; do 

        local rep0=$(echo $rep0 |sed "s/ >>>>> />>>>>/g")
        # echo $rep0
        OLD_IFS="$IFS"
        IFS=">>>>>"
        local arr=($rep0)
        IFS="$OLD_IFS"

        local src0=$(echo ${arr[0]})
        local dest0=$(echo ${arr[${#arr[@]}-1]})
        if [ "" != "$src0" ] && [ "" != "$dest0" ]; then
            rep=$(cat $cur/tpl/_replace.json |jq ".target=\"$src0\"" |jq ".expect=\"$dest0\"" -c)
            # echo "=== $rep"
            
            # //$onefile变量与文件来回倒: (直接单个变量不能赋值..)
            # cat $tmp/oneAdd_line_replace.txt
            onefile=$(cat $tmp/oneAdd_line_replace.txt)
            # echo ">>> $onefile"

            # echo $onefile |jq ".item.replace[.item.replace|length]=$rep" -c
            onefile=$(echo $onefile |jq ".item.replace[.item.replace|length]=$rep" -c)
            # echo $onefile
            echo $onefile > $tmp/oneAdd_line_replace.txt
            # cat $tmp/oneAdd_line_replace.txt
        fi
    done
}

function doOne(){
    local file=$1
    echo -e "\nFILE=$file"
    # git --no-pager diff $file |grep "^\-\|^+" |grep -v "^\-\-\-\|^+++"
    git --no-pager diff $CMP1 $CMP2 $file |grep "^+" |grep -v "^+++" > $tmp/oneAdd.txt
    git --no-pager diff $CMP1 $CMP2 $file |grep "^\-" |grep -v "^\-\-\-" > $tmp/oneDel.txt

    # local onefile=$(cat $cur/tpl/_file.json)
    local onefile=$(cat $cur/tpl/_file.json |jq ".name=\"$file\"" -c)
    echo $onefile > $tmp/oneAdd_line_replace.txt #fisrt initContent: to file
    i=0
    cat $tmp/oneAdd.txt |while read line; do #//loopLines
        # echo "=================  $onefile" #each to be the initContent
        let i+=1
        # echo $i
        cmp1=$(cat $tmp/oneDel.txt |sed -n "$i"p |sed "s/^\-//g")
        cmp2=$(echo "$line" |sed "s/^\+//g")
        
        # debug
        # echo "$cmp1 ||| $cmp2"  ##./main ${cmp1} ${cmp2} ${equal=true/false}
        $GODIFF "$cmp1" "$cmp2" true2 #|grep ">>>>>" #view
        $GODIFF "$cmp1" "$cmp2" true2 |grep ">>>>>" > $tmp/oneAdd_line.txt #//oneLine: if multiReplace
        
        doOneLine "$tmp/oneAdd_line.txt"
    done
    onefile=$(cat $tmp/oneAdd_line_replace.txt)
    # echo $onefile |jq 
    # echo ">>> $onefile"
}

# git --no-pager diff $CMP1 $CMP2 --numstat . |grep "^+++" > $tmp/addList.txt
# debug="|grep sidebar |grep -v docker"
cat $cur/tpl/_root.json >$tmp/root.txt
git --no-pager diff $CMP1 $CMP2 . |grep "^+++" > $tmp/addList.txt
cat $tmp/addList.txt | while read one; do
    file=$(echo ${one##*app/})
    doOne "$file"

    onefileFinish=$(cat $tmp/oneAdd_line_replace.txt)
    # $tmp/root.txt: 
    # root=$(cat $tmp/root.txt |jq ".root.file[.root.file|length]=$onefileFinish" -c) ##
    # echo $root >$tmp/root.txt

    root=$(cat $tmp/root.txt)
    root=$(echo $root |jq ".root.file[.root.file|length]=$onefileFinish" -c) ##
    echo $root >$tmp/root.txt
    # echo $root
done

root=$(cat $tmp/root.txt)
echo $root |jq -c

cat $tmp/root.txt > $cur/tpl/gen/gen1.json
# $cur/transfer -h
$cur/transfer -s $cur/tpl/gen/gen1.json -t $OUTPUT