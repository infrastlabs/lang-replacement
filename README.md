# file-replacement

该程序用于非本土化的应用, 可针对源码/未混淆加密的目标代码做汉化, 依赖于汉化字典:  
1.字典可基于源码手动做一版改动后,自动分析生成  
2.由上生成的字典,可进一步翻译为其它语言  

- 汉化程序(./main.go): 参考konga,改用Golang实现
- XML字典(./gitdiff1.sh): 反向分析git代码仓库的变动差异, 生成汉化程序所需的配置xml(依赖git, jq, transfer, ./main为./diff/main.go生成) 

**汉化程序**

- Konga v0.14.9 全支持
- Portainer v2.9.0 半汉化(docker+porainer部分)

## Dev

```bash
# headless @ barge in .../_ct/lang-replacement |11:39:37  |master ↑2 U:1 ?:1 ✗| 
$ go run ./main.go ./konga.xml "./asset"

# diff
CGO_ENABLED=0
$ go build -o godiff -x -v -ldflags "-s -w $flags" ./diff/main.go
# -rwxr-xr-x 1 headless headless 1.9M 10月  9 10:10 main*
# -rwxr-xr-x 1 headless headless 2.6M 10月  9 10:09 main00*
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
# headless @ barge in .../_ct/lang-replacement |14:42:10  |dev U:1 ✗|  #dindMnt
$ docker  run -it --rm -v /mnt/data/$(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement

```

## Refs

- https://github.com/jsonljd/konga-lang-plugin
- http://www.zzvips.com/article/167183.html
- https://blog.csdn.net/qiuyoujie/article/details/79289181
