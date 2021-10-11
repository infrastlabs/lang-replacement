package main

import (
    "encoding/xml"
    "fmt"
)

type assets struct {
    XMLName xml.Name `xml:"Assets"`
    Version string   `xml:"version,attr"`
    Asset   []asset  `xml:"Asset"`
}

type asset struct {
    Type string `xml:"type,attr"`
    Test []Test `xml:"Test"`
}

type Test struct {
    XMLName xml.Name `xml:"Test"`
    Person  Person   `xml:"Person"`
}

type Person struct {
    Name  string `xml:"name,attr"`
    Value string `xml:",cdata"`
}

func main() {

    var Text = `
    <Assets version="3.0.2.1">
        <Asset type="10">
            <Test>
                <Person name="appid"><![CDATA[wx0f0df4fda4ff1937]]></Person>
            </Test>
            <Test>
                <Person name="appid1"><![CDATA[wx0f0df4fda4ff19371]]></Person>
            </Test>
        </Asset>
    </Assets>
    `

    pars := &assets{}
    xml.Unmarshal([]byte(Text), &pars)
    // fmt.Println("%#v", pars)

    
    for i := 0; i < len(pars.Asset); i++ {
        // fmt.Println("i=", i, pars.Asset[i])
        for j:= 0; j < len(pars.Asset[i].Test); j++ {
            fmt.Println("j=", j, pars.Asset[i].Test[j])
        }
    }

    /* v := &assets{Version: "3.0.2.1"}
    //ass
    for cp := 0; cp < 2; cp++ {
        var ass asset
        ass.Type = "10"

        for testNum := 0; testNum < 2; testNum++ {
            var test Test
            var person Person
            person.Name = "appid"
            person.Value = "wx0f0df4fda4ff1937"
            test.Person = person
            ass.Test = append(ass.Test, test)
        }

        v.Asset = append(v.Asset, ass)
    } 

    output, err := xml.MarshalIndent(v, "", "  ")
    if err != nil {
        fmt.Printf("error: %v\n", err)
    }
    fmt.Println(string(output))*/

    /*
            var Text1 = `
            <Test>
                 <Person name="appid"><![CDATA[wx0f0df4fda4ff1937]]></Person>
            </Test>
            `
            v := &Test{
                 Person: person{Value: "bbbccc", Name: "ggggg"},
            }
            output, err := xml.MarshalIndent(v, "  ", "    ")
            if err != nil {
                fmt.Printf("error: %v\n", err)
            }
            fmt.Println(string(output))
            pars := &Test{}
            xml.Unmarshal([]byte(output), &pars)
            fmt.Println("%#v", pars)
    */

    /*
        w := &asset{Type: "10"}
        w.Test = append(w.Test, *v)
        output, err = xml.MarshalIndent(v, "  ", "    ")
        if err != nil {
            fmt.Printf("error: %v\n", err)
        }
        fmt.Println(string(output))
    */

}
