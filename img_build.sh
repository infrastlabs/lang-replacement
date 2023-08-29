
#echo "export DOCKER_REGISTRY_USER_sdsir=xxx" >> /etc/profile
#echo "export DOCKER_REGISTRY_PW_sdsir=xxx" >> /etc/profile

source /etc/profile
export |grep DOCKER_REG
repo=registry.cn-shenzhen.aliyuncs.com
echo "${DOCKER_REGISTRY_PW_infrastSubUser2}" |docker login --username=${DOCKER_REGISTRY_USER_infrastSubUser2} --password-stdin $repo

ns=infrastlabs
# cache="--no-cache"
# pull="--pull"
ver=v1

cmd="$1"
case "$cmd" in
    dict) #./generate >> go源码编译/jqEnv >> 运行时:Clone代码_br-lang2生成dict (entry/gitdiff.sh)
        img="lang-replacement:dict" #v1-generate
        cd dict; docker build $cache $pull -t $repo/$ns/$img -f Dockerfile . 
        docker push $repo/$ns/$img
        
        # dind:out-binary ##barge=/mnt/data/
        docker run -it --rm --entrypoint=bash -v   $barge$(pwd)/generate:/mnt $repo/$ns/$img -c "ls -lh /mnt/; cp -a transfer godiff lang-replacement xml2json /mnt/; ls -lh /mnt/"
        ;;
    
    cache) #node_modules @v291
        img="lang-replacement:cache" #v1-generate
        cd output/.cache; docker build $cache $pull -t $repo/$ns/$img -f Dockerfile . 
        docker push $repo/$ns/$img
        ;; 
    replace) ##./replacement/
        # Dockerfile
        #  >> Node环境+lang_placement+node_modules
        #  >> 运行时: Clone发版的代码, 替换CN, npm构建生成public.tar.gz
        img="lang-replacement:replace" #v1-generate
        cd replacement; docker build $cache $pull -t $repo/$ns/$img -f Dockerfile.alpine . #cd replacement
        docker push $repo/$ns/$img
        
        # tag:replace> latest
        img2="lang-replacement:latest" 
        docker tag $repo/$ns/$img docker push $repo/$ns/$img2
        docker push $repo/$ns/$img2
        ;;  
    repslim) #replace-slim [node-slim]
        img="lang-replacement:replace-slim" 
        cd replacement; docker build $cache $pull -t $repo/$ns/$img -f Dockerfile . #cd replacement
        docker push $repo/$ns/$img
        ;; 
    pt) #replace-img 在replace基础上 直接生成汉化版portainer-ce镜像
        rq=`date +%Y%m%d |sed "s/^..//"`
        img="portainer-cn:v$rq" #-v291
        
        # 改顶层dir构建: 用到./static资源
        # cd replacement; docker build $cache $pull -t $repo/$ns/$img -f pt.Dockerfile . 
        pwd;
        docker build $cache $pull -t $repo/$ns/$img -f replacement/pt.Dockerfile . 
        docker push $repo/$ns/$img

        #latest 
        latest=$repo/$ns/"portainer-cn:latest"
        docker tag $repo/$ns/$img $latest
        docker push  $latest
        ;;  
    *) 
        echo "Please call with a param: [dict, cache,replace,repslim, pt]"
        ;;  
esac

