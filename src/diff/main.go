package main

import (
	"fmt"
	"os"
	"strings"
	"github.com/sergi/go-diff/diffmatchpatch"
)

const (
	// text1 = "Lorem ipsum dolor."
	// text2 = "Lorem dolor sit amet."
	text1 = "AAAnameBBB."
	text2 = "AAA名字BBB."
)

func goDiff(text1, text2, equal string){
	dmp := diffmatchpatch.New()
	diffs := dmp.DiffMain(text1, text2, false)

	var newDiffs []diffmatchpatch.Diff
	var tmp1 string
	for _, item := range diffs {
		if item.Type != diffmatchpatch.DiffEqual {
			// fmt.Println(item.Text)
			newDiffs = append(newDiffs, item)
		}

		//del >>>>> add
		if item.Type != diffmatchpatch.DiffEqual {
			if item.Type == diffmatchpatch.DiffDelete {
				tmp1= item.Text
			}
			if item.Type == diffmatchpatch.DiffInsert { //if: DEL1>ADD1>ADD2
				if find := strings.Contains(tmp1, " >>>>> "); find {
					tmp1= " >>>>> "+item.Text //new
				} else {
					tmp1= tmp1+" >>>>> "+item.Text
				}

				fmt.Println(tmp1)
			}
		}
	}
	// TODO: args[3]; equal=false/true;
	if "true" == equal {
		fmt.Println(dmp.DiffPrettyText(diffs)) //newDiffs
	} else {
		fmt.Println(dmp.DiffPrettyText(newDiffs)) //
	}
}

func main() {
	if len(os.Args) != 4 {
        fmt.Println("lack of config file, eg: go run main.go ${cmp1} ${cmp2} ${equal=true/false}")
        os.Exit(-1)
    }
    cmp1 := os.Args[1]
	cmp2:= os.Args[2]
	equal:= os.Args[3]

	goDiff(cmp1, cmp2, equal)
}