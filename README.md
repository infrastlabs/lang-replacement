# lang-replacement

- Konga v0.14.9 全支持 (借用 generate/konga.xml)
- Portainer v2.9.0 半汉化(docker+porainer部分)

![](./demo/pt-cn-2021-10-16_21-48.png)

## 快速体验

```bash
# 该镜像基于官方v291做汉化，其它版本请依据汉化步骤自行生成
img=registry.cn-shenzhen.aliyuncs.com/infrastlabs/portainer-cn
docker run -it --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock $img
```

## Portainer汉化

**output/portainer_zh.xml** 生成字典

```bash
# dict生成
# ENV GENERATE_REPO="https://gitee.com/g-devops/fk-portainer" \
#     GENERATE_OUTPUT="portainer_zh.xml" \
#     CMP1="2.9.1" \
#     CMP2="origin/br-lang2"
docker run -it --rm -e CMP1=2.9.1 -e CMP2=origin/br-lang3 -v /mnt/data/$(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:dict


# xml2json
# wget https://hub.fastgit.org/covrom/xml2json/releases/download/1.0/xml2json
cat portainer_zh.xml |./xml2json  |jq

```

**dict/public.tar.gz** 生成汉化包

```bash
# 方式一： 可指定官方/自定义的REPO仓库
# barge: 生成public.tar.gz
# ENV \
#     REPO="https://gitee.com/g-devops/fk-portainer" \ 
#     # BRANCH="release/2.9" \
#     # TAG="2.9.1"
#     TAG="v291-patch" #up/down样式; 美化rdash样式; CPU/MEM限定

# TAG=2.9.0; BRANCH=sam-custom
docker run -it --rm -e TAG=v291-patch -v /mnt/data/$(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:replace

# tar -zxf public.tar.gz 
public=/mnt/data/$(pwd)/output/portainer/dist/public
docker run -it --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $public:/public portainer/portainer-ce:2.9.1-alpine


# 方式二：clone本仓库，直接生成pt镜像`registry.cn-shenzhen.aliyuncs.com/infrastlabs/portainer-cn:latest`
# ENV \
#     REPO="https://gitee.com/g-devops/fk-portainer" \ 
#     BRANCH="sam-custom"
#     # TAG="2.9.1"
sh img_build.sh pt
# # 基于`sam-custom`分支：
# 1.sidebar up/down样式还原
# 2.前端(Alter)：改通用配置参数、紧凑/美化rdash样式
# 3.前端(Feat)：updateLimits，实时更新容器的CPU/MEM限定
# 3.后端(Alter)：调小edgePoll周期：DefaultEdgeAgentCheckinIntervalInSeconds = 2 //5
# 4.前端(Alter)：屏蔽sidebar新版提示、EE功能页、templates模块(当前用不上它)。
```


## +templates TODO

- `./templates`已缓存(含图片)，当前调用本地9000端口未登录会被限制使用
- 用法上不需要：只用`psu-stack`自动化部署、PT面板管维

```bash
# https://docs.portainer.io/v/ce-2.9/advanced/app-templates/build

# 地址是对的, 不能用: 需要LOGIN??
# headless @ barge in .../dist/portainer |20:15:24  |tag:v291-patch U:48 ✗| 
$ ./portainer --data=./data --admin-password=$token --templates=http://127.0.0.1:9000/templates/templates.json

```