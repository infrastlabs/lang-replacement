
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


func copy(src, dst string) (int64, error) {
    sourceFileStat, err := os.Stat(src)
    if err != nil {
            return 0, err
    }

    if !sourceFileStat.Mode().IsRegular() {
            return 0, fmt.Errorf("%s is not a regular file", src)
    }

    source, err := os.Open(src)
    if err != nil {
            return 0, err
    }
    defer source.Close()

    destination, err := os.Create(dst)
    if err != nil {
            return 0, err
    }
    defer destination.Close()
    nBytes, err := io.Copy(destination, source)
    return nBytes, err
}

func main() {
    if len(os.Args) != 3 {
        fmt.Println("lack of config file, eg: ./lang-replacement ${replaceDictFile} ${replacePath}")
        os.Exit(-1)
    }
    replaceDictFile := os.Args[1]
    replacePath:= os.Args[2]

    pars:= parseReplacement(replaceDictFile)
    // fmt.Println("%#v", pars)

    for i := 0; i < len(pars.File); i++ {
        fmt.Println("i=", i, pars.File[i].Name.Value)
        /* for j:= 0; j < len(pars.File[i].Item.Replace); j++ {
            fmt.Println("  j=", j, pars.File[i].Item.Replace[j].Target, ">", pars.File[i].Item.Replace[j].Expect)
        } */

        //go routine
        replaceFile(replacePath, pars.File[i].Name.Value, pars.File[i].Item.Replace)
        
        //TODO: 
        // 1.mv src 2.cp xx.mdf 3.mv xx.mdf
        // https://blog.csdn.net/whatday/article/details/109287416
        filesrc:= replacePath+"/"+pars.File[i].Name.Value
        replace:= filesrc+".mdf"
        fileDest:= replacePath+"/.lang-replacement/"+pars.File[i].Name.Value //mvDest
        pos:= strings.LastIndex(fileDest, "/")
        filedir:=fileDest[0:pos]
        // fmt.Println(filesrc)
        // fmt.Println(replace)
        // fmt.Println(filedir)
        // 创建文件夹
        os.MkdirAll(filedir, 0777)
        // 移动文件
        os.Rename(filesrc, fileDest)

        // 拷贝文件, 拷贝其实就是创建一个文件, 然后写入文件内容
        // file, _ := os.OpenFile(replace, 2, 0666)
        // defer file.Close()
        // src1, _ := os.Create(filesrc)
        // io.Copy(file, src1) // 把文件file, 写入src1文件
        nBytes, err := copy(replace, filesrc)
        if err != nil {
            fmt.Printf("The copy operation failed %q\n", err)
        } else {
            fmt.Printf("Replace-Copied %d bytes, backdir: %s!\n", nBytes, fileDest)
        }

        // 移动文件
        os.Rename(replace, fileDest+".mdf")
    }

    fmt.Println("FINISH!")
}
