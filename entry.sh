#!/bin/bash
outPath="/output" && mkdir -p $outPath

# if EXEC_TYPE="GENERATE"
# $AUTH
git clone -b $GENERATE_BRANCH $GENERATE_REPO srcGen
export SOURCE=srcGen/app
export CMP1=055c57
export CMP2=br-v29-lang
export OUTPUT=$outPath/$GENERATE_OUTPUT 
./gitdiff.sh

cat $OUTPUT |wc
# SOURCE=srcReplace

