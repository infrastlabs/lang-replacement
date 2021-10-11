#!/bin/bash

# if EXEC_TYPE="GENERATE"
SOURCE=srcGenerate
CMP1=055c57
CMP2=br-v29-lang
OUTPUT=/output/$GENERATE_OUTPUT
./gitdiff.sh

cat $OUTPUT |wc
# SOURCE=srcReplace

