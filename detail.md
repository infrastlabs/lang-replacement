# 

该程序用于非本土化的应用, 可针对源码/未混淆加密的目标代码做汉化, 依赖于汉化字典:  
1.字典可基于源码手动做一版改动后,自动分析生成  
2.由上生成的字典,可进一步翻译为其它语言  

- 汉化程序(./main.go): 参考konga,改用Golang实现
- XML字典(./gitdiff1.sh): 反向分析git代码仓库的变动差异, 生成汉化程序所需的配置xml(依赖git, jq, transfer, ./main为./diff/main.go生成) 

## 操作说明

- pt >> infrastlabs/portainer-cn:latest #基于官方v2.9.1, 生成portainer-cn汉化版镜像
- registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement
  - dict #字典生成
  - cache #node_modules @v291
  - replace,latest #汉化程序+Node构建 >> 生成public.tar.gz

**汉化(容器)** 

```bash
# choice1: 直接使用汉化的容器(基于官方v2.9.1, 替换/public)
docker run -it --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock registry.cn-shenzhen.aliyuncs.com/infrastlabs/portainer-cn

# choice2: 生成public.tar.gz, 手动挂载到容器内使用
#  choice2_step1: 容器运行(node环境: 替换后 直接构建输出public.tar.gz)
$ docker run -it --rm -v $(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement
#  choice2_step1: 挂载/public目录来使用
tar -zxf public.tar.gz
docker run -it --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/public:/public portainer/portainer-ce:2.9.1-alpine
```

**汉化(二进制用法)** 二进制运行替换后,手工build前端工程

```bash
# step1: 二进制运行替换
# headless @ barge in .../lang-replacement/generate |15:53:12  |dev U:1 ?:2 ✗| 
$ ./lang-replacement ./portainer_zh.xml $(pwd)/portainer/app
...
i= 49 portainer/views/users/edit/user.html
(replace)j= 0 {Change user password} > {修改密码}
Replace-Copied 4325 bytes, backdir: /_ext/working/_ct/lang-replacement/generate/portainer/app/.lang-replacement/portainer/views/users/edit/user.html!
i= 50 portainer/views/users/users.html
(replace)j= 0 {Add a new user} > {添加用户}
(replace)j= 1 {Users} > {用户管理}
Replace-Copied 7171 bytes, backdir: /_ext/working/_ct/lang-replacement/generate/portainer/app/.lang-replacement/portainer/views/users/users.html!
FINISH!

# step2: 基于上1步替换后的源码, 手工build前端工程(Portainer需要在源码层做汉化替换)
# ...
```

**生成汉化字典**

```bash
# headless @ barge in .../_ct/lang-replacement |14:42:10  |dev U:1 ✗|  #dindMnt
$ docker run -it --rm -v $(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:generate

```

## Dev开发说明

```bash
# headless @ barge in .../_ct/lang-replacement |11:39:37  |master ↑2 U:1 ?:1 ✗| 
$ go run ./main.go ./konga.xml "./asset"

# diff
CGO_ENABLED=0
$ go build -o godiff -x -v -ldflags "-s -w $flags" ./diff/main.go
# -rwxr-xr-x 1 headless headless 1.9M 10月  9 10:10 main*
# -rwxr-xr-x 1 headless headless 2.6M 10月  9 10:09 main00*
```

**Replacement模版生成**

```bash
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
```

**buildPortainer**

```bash
# https://www.cnblogs.com/ccti7/p/13956678.html
# npm install image-webpack-loader --save-dev
yarn add image-webpack-loader -D
yarn add image-webpack-loader -g

```

## Refs

- https://github.com/jsonljd/konga-lang-plugin
- http://www.zzvips.com/article/167183.html
- https://blog.csdn.net/qiuyoujie/article/details/79289181

