
package main
import (
    "bufio"
    "encoding/xml"
    "fmt"
    "io"
    "os"
    "strings"
)
type root struct {
    XMLName xml.Name `xml:"root"`
    // Version string   `xml:"version,attr"`
    File   []file  `xml:"file"`
}

type file struct {
    // Type string `xml:"type,attr"`
    Name name `xml:"name"`
    Item item `xml:"item"`
    // XMLName xml.Name `xml:"item"`
}
type name struct {
    // Name  string `xml:"name,attr"`
    Value string `xml:",cdata"`
}
type item struct {
    Replace   []replace  `xml:"replace"`
    // XMLName xml.Name `xml:"replace"`
    // Target  target   `xml:"target"`
}
type replace struct {
    XMLName xml.Name `xml:"replace"`
    Target  target   `xml:"target"`
    Expect  expect   `xml:"expect"`
}

type target struct {
    // Name  string `xml:"name,attr"`
    Value string `xml:",cdata"`
}
type expect struct {
    Value string `xml:",cdata"`
}

func parseReplacement(fileName string) *root {
    in, err := os.Open(fileName)
    if err != nil {
        fmt.Println("open replacement-file fail:", err)
        os.Exit(-1)
    }
    defer in.Close()
 
    var Text = ""
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
        Text=Text+string(line)+"\n"
        index++
    }

    pars := &root{}
    xml.Unmarshal([]byte(Text), &pars)
    // fmt.Println("%#v", pars)
    return pars
}

func replaceFile(basePath string, fileName string, replaceList []replace){
    fileName= basePath+"/"+fileName
    in, err := os.Open(fileName)
    if err != nil {
        fmt.Println("open file fail:", err)
        return
    }
    defer in.Close()
 
    out, err := os.OpenFile(fileName+".mdf", os.O_RDWR|os.O_CREATE, 0766)
    if err != nil {
        fmt.Println("Open write file fail:", err)
        return
    }
    defer out.Close()

    //debug
    for j:= 0; j < len(replaceList); j++ {
        fmt.Println("(replace)j=", j, replaceList[j].Target, ">", replaceList[j].Expect)
    }
 
    br := bufio.NewReader(in)
    index := 1
    for {
        line, _, err := br.ReadLine()
        if err == io.EOF {
            break
        }
        if err != nil {
            fmt.Println("read err:", err)
            return
        }
        // newLine := strings.Replace(string(line), os.Args[2], os.Args[3], -1) //os.Args
        newLine := string(line)
        for j:= 0; j < len(replaceList); j++ {
            src:= replaceList[j].Target.Value
            dest:= replaceList[j].Expect.Value
            newLine = strings.Replace(newLine, src, dest, -1)
        }

        _, err = out.WriteString(newLine + "\n")
        if err != nil {
            fmt.Println("write to file fail:", err)
            return
        }
        // fmt.Println("done ", index)
        index++
    }
}

func main() {
    if len(os.Args) != 3 {
        fmt.Println("lack of config file, eg: go run main.go ${path_of_file} ${path_of_src}")
        os.Exit(-1)
    }
    fileName := os.Args[1]
    basePath:= os.Args[2]

    pars:= parseReplacement(fileName)
    // fmt.Println("%#v", pars)

    for i := 0; i < len(pars.File); i++ {
        fmt.Println("i=", i, pars.File[i].Name.Value)
        /* for j:= 0; j < len(pars.File[i].Item.Replace); j++ {
            fmt.Println("  j=", j, pars.File[i].Item.Replace[j].Target, ">", pars.File[i].Item.Replace[j].Expect)
        } */

        //go routine
        replaceFile(basePath, pars.File[i].Name.Value, pars.File[i].Item.Replace)
    }

    fmt.Println("FINISH!")
}
