package main
import (
	"fmt"
	// "io"
    // "os"
    "strings"
)

func main(){
	// subString
	filePath:= "/aa/bb/cc.json"
	pos:= strings.LastIndex(filePath, "/")
	filePath=filePath[0:pos]
	fmt.Printf(filePath)
}