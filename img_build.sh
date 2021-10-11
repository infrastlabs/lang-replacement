
#echo "export DOCKER_REGISTRY_USER_sdsir=xxx" >> /etc/profile
#echo "export DOCKER_REGISTRY_PW_sdsir=xxx" >> /etc/profile

source /etc/profile
export |grep DOCKER_REG
repo=registry.cn-shenzhen.aliyuncs.com
echo "${DOCKER_REGISTRY_PW_infrastSubUser2}" |docker login --username=${DOCKER_REGISTRY_USER_infrastSubUser2} --password-stdin $repo

ns=infrastlabs
# cache="--no-cache"
# pull="--pull"
ver=latest
img="lang-replacement:$ver"
docker build $cache $pull -t $repo/$ns/$img -f Dockerfile . 
# push
docker push $repo/$ns/$img

# dind: out-binary
docker run -it --rm --entrypoint=bash -v   /mnt/data/$(pwd)/generate:/mnt $repo/$ns/$img -c "ls -lh /mnt/; cp -a transfer godiff lang-replacement /mnt/; ls -lh /mnt/"
