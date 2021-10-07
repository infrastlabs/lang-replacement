package main

import (
    "encoding/xml"
    "fmt"
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

func main() {

    var Text = `
    <?xml version="1.0"?>
    <root>
        <file>
            <name>js/app/dashboard/dashboard.html</name>
            <item>
                <replace>
                    <target><![CDATA[^\s+Welcome!$]]></target>
                    <expect><![CDATA[欢迎!]]></expect>
                </replace>
                <replace>
                    <target><![CDATA[Make sure your active <a ui-sref="connections">connection</a> is valid and Kong is up and running.]]></target>
                    <expect><![CDATA[请确认 <a ui-sref="connections">连接管理</a> 设置有可用的Kong并且是运行中.]]></expect>
                </replace>
                <replace>
                    <target><![CDATA[^\s+CONNECTIONS$]]></target>
                    <expect><![CDATA[连接端]]></expect>
                </replace>
                <replace>
                    <target><![CDATA[Total Requests: ]]></target>
                    <expect><![CDATA[总请求: ]]></expect>
                </replace>
                <replace>
                    <target><![CDATA[^\s+CLUSTER \(\{\{clusters.total\}\} nodes\)&]]></target>
                    <expect><![CDATA[集群有 ({{clusters.total}} 节点数)]]></expect>
                </replace>
            </item>
        </file>
        <file>
            <name>js/app/connections/partials/create-connection-form.html</name>
            <item>
                <replace>
                    <target><![CDATA[^\s+DEFAULT$]]></target>
                    <expect>默认</expect>
                </replace>
                <replace>
                    <target><![CDATA[^\s+KEY AUTH$]]></target>
                    <expect>键值授权</expect>
                </replace>
                <replace>
                    <target><![CDATA[^\s+JWT AUTH$]]></target>
                    <expect>JWT授权</expect>
                </replace>
            </item>
        </file>
    </root>
    `

    pars := &root{}
    xml.Unmarshal([]byte(Text), &pars)
    fmt.Println("%#v", pars)

    
    /* for i := 0; i < len(pars.Asset); i++ {
        // fmt.Println("i=", i, pars.Asset[i])
        for j:= 0; j < len(pars.Asset[i].Test); j++ {
            fmt.Println("j=", j, pars.Asset[i].Test[j])
        }
    } */

}
