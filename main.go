
package main
import (
    "bufio"
    "fmt"
    "io"
    "os"
    "strings"
)
 
func main() {
    if len(os.Args) != 4 {
        fmt.Println("lack of config file, eg: go run main.go ${path_of_file} ${old_string} ${new_string}")
        os.Exit(-1)
    }
    fileName := os.Args[1]
    in, err := os.Open(fileName)
    if err != nil {
        fmt.Println("open file fail:", err)
        os.Exit(-1)
    }
    defer in.Close()
 
    out, err := os.OpenFile(fileName+".mdf", os.O_RDWR|os.O_CREATE, 0766)
    if err != nil {
        fmt.Println("Open write file fail:", err)
        os.Exit(-1)
    }
    defer out.Close()
 
    br := bufio.NewReader(in)
    index := 1
    for {
        line, _, err := br.ReadLine()
        if err == io.EOF {
            break
        }
        if err != nil {
            fmt.Println("read err:", err)
            os.Exit(-1)
        }
        newLine := strings.Replace(string(line), os.Args[2], os.Args[3], -1)
        _, err = out.WriteString(newLine + "\n")
        if err != nil {
            fmt.Println("write to file fail:", err)
            os.Exit(-1)
        }
        fmt.Println("done ", index)
        index++
    }
    fmt.Println("FINISH!")
}
