
#!/bin/bash
cur=$(cd "$(dirname "$0")"; pwd)
GODIFF="$cur/main"
SOURCE="/_ext/bbox/_ee/fk-portainer/app"
CMP1=e027a82 #CMP1, CMP2: if not set, compare local with origin
CMP2=6ff78c6
# deps: git diff; go-diff

cd $SOURCE
tmp=/tmp/.gitdiff && mkdir -p $tmp

function doOne(){
    local file=$1
    echo -e "\nFILE=$file"
    # git --no-pager diff $file |grep "^\-\|^+" |grep -v "^\-\-\-\|^+++"
    git --no-pager diff $CMP1 $CMP2 $file |grep "^+" |grep -v "^+++" > $tmp/oneAdd.txt
    git --no-pager diff $CMP1 $CMP2 $file |grep "^\-" |grep -v "^\-\-\-" > $tmp/oneDel.txt

    i=0
    cat $tmp/oneAdd.txt |while read line; do 
        let i++
        # echo $i
        cmp1=$(cat $tmp/oneDel.txt |sed -n "$i"p |sed "s/^\-//g")
        cmp2=$(echo "$line" |sed "s/^\+//g")
        
        # debug
        # echo "$cmp1 ||| $cmp2"  ##./main ${cmp1} ${cmp2} ${equal=true/false}
        $GODIFF "$cmp1" "$cmp2" true2 #|grep ">>>>>"
    done
}

# git --no-pager diff $CMP1 $CMP2 --numstat . |grep "^+++" > $tmp/addList.txt
git --no-pager diff $CMP1 $CMP2 . |grep "^+++" > $tmp/addList.txt
cat $tmp/addList.txt | while read one; do
    file=$(echo ${one##*app/})
    doOne "$file"
done
