
**dict/public.tar.gz**

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

**publicMount**

```bash
# barge: 生成public.tar.gz
# ENV \
#     REPO="https://gitee.com/g-devops/fk-portainer" \ 
#     # BRANCH="release/2.9" \
#     TAG="2.9.1"

# TAG=2.9.0
docker run -it --rm -e BRANCH=sam-custom -v /mnt/data/$(pwd)/output:/output registry.cn-shenzhen.aliyuncs.com/infrastlabs/lang-replacement:replace



# tar -zxf public.tar.gz 
public=/mnt/data/$(pwd)/output/portainer/dist/public
docker run -it --rm --net=host -v /var/run/docker.sock:/var/run/docker.sock -v $public:/public portainer/portainer-ce:2.9.1-alpine


```
