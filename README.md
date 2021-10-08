# file-replacement

- https://github.com/jsonljd/konga-lang-plugin
- http://www.zzvips.com/article/167183.html
- https://blog.csdn.net/qiuyoujie/article/details/79289181

## Dev

```bash
# headless @ barge in .../_ct/lang-replacement |11:39:37  |master ↑2 U:1 ?:1 ✗| 
$ go run ./main.go ./konga.xml "./asset"
```

## Replacement模版生成

TODO: git diff 锁定到行? > tpl > Replace指定行

**Portainer汉化**

- app/docker 半汉化
- app/portainer 半汉化
- app/kubernetes
- app/integrations
- app/azure
- app/agent
- app/edge

https://www.bejson.com/xml2json/

## Use

```bash
# headless @ barge in .../_ct/lang-replacement |18:40:40  |master ?:4 ✗| 
# $ go build .
# headless @ barge in .../_ct/lang-replacement |18:41:05  |master ?:4 ✗| 
# $ ll -h
# -rwxr-xr-x 1 headless headless 2.3M 10月  8 18:41 lang-replacement*

# headless @ barge in .../_ct/lang-replacement |18:41:11  |master ?:4 ✗| 
$ ./lang-replacement ./tpl/gen/gen1-bejson.xml /_ext/working/_ct/fk-portainer/app
i= 0 docker/components/datatables/networks-datatable/networksDatatable.html
i= 1 docker/components/host-view-panels/engine-details-panel/engine-details-panel.html
(replace)j= 0 {Engine Details} > {容器信息}
i= 2 docker/components/host-view-panels/host-details-panel/host-details-panel.html
(replace)j= 0 {Host Details} > {主机信息}
...
```