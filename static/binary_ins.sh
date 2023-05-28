#!/bin/bash
cur=$(cd "$(dirname "$0")"; pwd)

# ===============================================
# export DEPLOY="{module_args.agent_deploy_dir}"
# export URL="{module_args.portainer_url}"
# export USER1="{module_args.portainer_user}"
# export PASS="{module_args.portainer_pass}"
# chmod +x binary_ins.sh; bash binary_ins.sh -ACT=install/uninstall
# 
# deps: curl, jq/gojq
# ===============================================

# ACTION=$1; shift
# from ENV
test -z "$DEPLOY" && DEPLOY="/usr/local/portainer-agent"
test -z "$ACTION" && ACTION="install" #install/uninstall
test -z "$VOLUME_PATH" && VOLUME_PATH="/var/lib/docker/volumes" #"/opt/docker-data/volumes" 

PACKAGE="agent-v291.tar.gz" #agent程序包
BINARY_URL=https://gitee.com/g-devops/fk-agent/attach_files/1020608/download/agent-v291-220407.tar.gz #892492/download/agent-v291-1125.tar.gz
BINARY_HOST="{{.}}"
# BINARY_HOST="http://172.25.21.62:9000" #dbg
test -z $(echo $BINARY_HOST |grep "}}") && BINARY_URL="$BINARY_HOST/static/$PACKAGE" #ct's /misc/binary_ins.sh
test -z $(echo $BINARY_HOST |grep "}}") && URL=$BINARY_HOST #"http://172.17.0.60:9000" #golang从req中获取，tpl写入

function errExit(){
  echo "$1"
  exit 1
}

# https://blog.csdn.net/bandaoyu/article/details/113770557
function parseArgs(){
  for arg in $@
  do
  local pre=${arg%%=*}       #从O开始，截取3个字符？ 
  case $pre in
    -u|-U)  USER1=${arg#*=}; echo "USER: $USER1";;   #从左边第3个字符开始，一直到结束。
    -p|-P)   PASS=${arg#*=}; echo "PASS: ***";;
    -url|-URL) URL=${arg#*=}; echo "URL: $URL";;
    -deploy|-DEPLOY) DEPLOY=${arg#*=}; echo "DEPLOY: $DEPLOY";;
    -act|-ACT) ACTION=${arg#*=}; echo "ACTION: $ACTION";;
    -name|-NAME) NODENAME=${arg#*=}; echo "NAME: $NODENAME";;
    -h|-H)  #help
      echo -e "Usage: \n  binary_ins.sh -u=user -p=pass [-a=install/uninstall]"
      exit 0
      ;;
    *)
      echo "notMatch: $arg"
  esac
  done
}
# sh binary_ins.sh  install -u=admin -p=xxx -name=Name bb cc -h
parseArgs $@
line="========================"; echo $line

function checkDeps(){ #gojq,goawk
  # curl/wget?
  curl -V > /dev/null 2>&1
  err=$?; test "0" == "$err" || errExit "curl 未安装(apt/yum install curl)"
  
  # jq/gojq
  if [ ! -z $(echo $BINARY_HOST |grep "}}") ]; then #non ct's /misc/binary_ins.sh
    jqBin="jq"
    $jqBin -V > /dev/null 2>&1
    err=$?; test "0" == "$err" || errExit "jq 未安装(apt/yum install jq)"
  else
    echo "download: /tmp/gojq, please wait.."
    test -s /tmp/gojq && echo "existed, skip" || sudo bash -c "curl -fsSL "$BINARY_HOST/static/gojq" > /tmp/gojq"
    jqBin=/tmp/gojq; sudo chmod +x $jqBin
    $jqBin -v > /dev/null 2>&1
    err=$?; test "0" == "$err" || errExit "gojq 错误"
  fi
}
checkDeps

test -z "$DEPLOY" && errExit "DEPLOY 为空"
test -z "$ACTION" && errExit "ACTION 为空"
test -z "$URL" && errExit "URL 为空"
test -z "$USER1" && errExit "USER 为空"
test -z "$PASS" && errExit "PASS 为空"
# exit 0 #debug_skip

# INSTANCE_ID Params
HOST="$URL" #URL > HOST
URL_IP=$(echo $URL |grep -E -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" |sed "s/\:/_/g"); test -z "$URL_IP" && errExit "fail to get URL_IP"
INSTANCE_ID=$URL_IP
dpPath="$DEPLOY/agent-$INSTANCE_ID"
svc="agent-$INSTANCE_ID.service"

function doLogin(){
  local USERNAME="$USER1"
  local PASSWORD="$PASS"
  # validate:
  curl --connect-timeout 3 -s $HOST > /dev/null #3s
  local errCode=$?; test "0" == "$errCode" || errExit "$HOST 地址访问失败，curl错误码: $errCode"

  # if login err;
  ret=$(curl -s -H "Content-Type: application/json" -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" -X POST $HOST/api/auth)
  # echo "ret: $ret"
  # Access denied to resource
  message=$(echo $ret |grep "message"); test -z "$message" ||  errExit "$HOST 登录失败，detail: $ret"  
  
  # LOGIN_TOKEN
  LOGIN_TOKEN=$(echo $ret | $jqBin -r .jwt) #global
  test -z "$LOGIN_TOKEN" && errExit "LOGIN_TOKEN为空" || echo "LOGIN_TOKEN: $LOGIN_TOKEN"
}

# EDGE_NAME="$ip"
function endpointJudgeAdd(){
  # clearDuplicate ##当列表较多时(>50)，消耗时间较长；
  # exit 0
  
  # 清理后，重load一次
  # local jsonList=$(curl -s -X GET "$HOST/api/endpoints?limit=0&start=0"  -H "Authorization: Bearer $LOGIN_TOKEN") #|$jqBin ".Name"
  json=/tmp/.pt_jsonList.txt
  curl -s -X GET "$HOST/api/endpoints?limit=0&start=0"  -H "Authorization: Bearer $LOGIN_TOKEN" \
   |$jqBin -c "del(.[].SecuritySettings,.[].Kubernetes,.[].AzureCredentials,.[].TLSConfig)" > $json
  local len=$(cat $json |$jqBin ".|length")
  echo "==PT已有主机数：$len"
  EP_EDGE_KEY="" #
  for ((i=0; i<$len; i++)); do
    # echo $i
    local epName=$(cat $json |$jqBin -r ".[$i].Name")
    if [ "$EDGE_NAME" == "$epName" ]; then
      # cat $json |$jqBin -r ".[$i].Status" #status=1， 无用途
      # exist: 
      # 如活跃：fail(请提前删除)
      # 如不活跃：解除关联，复用旧的EDGE_KEY
      local id=$(cat $json |$jqBin -r ".[$i].Id")
      local qryDate=$(cat $json |$jqBin -r ".[$i].QueryDate")
      local lastCheckDate=$(cat $json |$jqBin -r ".[$i].LastCheckInDate")
      local val1=`expr $qryDate - $lastCheckDate`
      # test "$val1" -gt "20" && echo "val1: $val1" #超过20s

      if [ "$val1" -gt "20" ]; then
        echo "[$i]==$id-$epName, 已存在(不活跃)，本次将复用该节点的EDGE_KEY"
        EP_EDGE_KEY=$(cat $json |$jqBin -r ".[$i].EdgeKey")
        EP_EDGE_ID=$(cat $json |$jqBin -r ".[$i].Id")
        EP_EDGE_NAME=$(cat $json |$jqBin -r ".[$i].Name")

        # lastCheckDate == 0: 表明从未用过，无需解绑
        if [ "0" != "$lastCheckDate" ]; then 
          echo "lastCheckDate!=0, 进行解绑操作ing"; 
          # slow: pt-boltdb-batch
          curl -s -X DELETE "$HOST/api/endpoints/$id/association"  -H "Authorization: Bearer $LOGIN_TOKEN" |$jqBin -r ".Id"
        else
          echo "lastCheckDate=0(未反向注册过), 不用解绑, skip"
        fi

        break #如多个: 取第一个即返回
      else
        # echo "still active"
        errExit "[ERROR] $id-$epName, 已存在且活跃，本次节点注册失败。(请检查本地获取到的IP节点名是否正确：$epName, 或先停用/删除PT端已有Agent节点)"
      fi
    fi
  done


  # 如不存在，则添加：
  EDGE_KEY=""
  if [ -z "$EP_EDGE_KEY" ]; then
    # epName：简短唯一; agentID: 格式<IP_AddTime>
    EDGE_NAME="$LOCAL_IP" #"$ip-$rand"
    test -z "$NODENAME" || EDGE_NAME=$NODENAME
    # -F "URL=$HOST"  ##try notes: 导致注册的节点写死了URL(需要epUpdate操作才更新)
    # 22.1.19: -F "URL=$URL"  ##UI中会自动带上, pt-cn1124测试：当不指定URL时，导致生成的EDGE_KEY没得URL信息， ptAgent注册失败.
    local jsonAdd=$(curl -s -X POST $HOST/api/endpoints -H "accept: application/json" -H "Authorization: Bearer $LOGIN_TOKEN" -F "URL=$URL" -F "Name=$EDGE_NAME" -F "EndpointCreationType=4")
    # echo "jsonAdd: $jsonAdd" |grep "Invalid"
    EDGE_EP_ID=$(echo $jsonAdd |$jqBin -r .Id) #表ID号
    EDGE_EP_NAME=$(echo $jsonAdd |$jqBin -r .Name) #IP名
    EDGE_KEY=$(echo $jsonAdd |$jqBin -r .EdgeKey) #&& echo $EDGE_KEY
    test -z "$EDGE_KEY" && errExit "EDGE_KEY为空, PT端新加节点失败: $EDGE_NAME"
    echo "新加节点，EDGE_KEY(decode):"
    echo $EDGE_KEY |base64 -d
  else
    EDGE_EP_ID="$EP_EDGE_ID"
    EDGE_EP_NAME="$EP_EDGE_NAME"
    EDGE_KEY="$EP_EDGE_KEY"
    echo "复用节点，EDGE_KEY(decode):"
    echo $EDGE_KEY |base64 -d
  fi  
  export EDGE_EP_ID EDGE_EP_NAME EDGE_KEY #暴露给之后func使用
}

function endpointRemove(){
  echo "removeEp"

  # EP # DO: 从PT删除已加节点；
  source $dpPath/env.conf
  local id=$EDGE_EP_ID
  local epName=$EDGE_EP_NAME
  if [ -z "$id" ]; then
    echo "EDGE_EP_ID为空，skip PT端的清理"
  else 
    echo "清理 $id-$epName， 该节点已卸载"
    curl -s -X DELETE "$HOST/api/endpoints/$id"  -H "Authorization: Bearer $LOGIN_TOKEN"
  fi
}

# LOCAL_IP
function selectLocalIP(){
  # 取IP: ip > ifconfig > nonip-$(hostname)
  LOCAL_IP=$(ip a |grep inet |grep -v "inet6\|lo$\|br\-\|docker" |awk '{print $2}' |cut -d'/' -f1 |head -1) #list: head -1
  test -z "$LOCAL_IP" && LOCAL_IP=$(ifconfig  -a |grep "flags\|inet " |sed ":a;N;s/\n *inet/|inet/g" |grep -v "lo: \|br\-\|docker" |cut -d'|' -f2 |awk '{print $2}' |head -1)
  test -z "$LOCAL_IP" && LOCAL_IP="nonip-$(hostname)" #-$rq # ip="1.2.3.4"

  echo "Got Local IP(top 1): $LOCAL_IP"  
}

function generateConf(){
  echo "gen: env.conf"
  local rq=$(date +%Y%m%d.%H%M%S |sed "s/^..//")
  # local rand=$(tr -dc 'A-Z0-9' </dev/urandom | head -c 2)
  EDGE_ID="id-$LOCAL_IP-$rq" #存放于agent端，首注册时送到PT
  test -s $dpPath/env.conf && mv $dpPath/env.conf $dpPath/env.conf-bk$rq
  echo """
source /etc/profile
# export LOG_LEVEL=debug #info
export EDGE=1
export EDGE_EP_ID=$EDGE_EP_ID
export EDGE_EP_NAME=$EDGE_EP_NAME
export EDGE_ID=$EDGE_ID
export EDGE_KEY=$EDGE_KEY
export EDGE_INACTIVITY_TIMEOUT=525600m  #60*24*365 min
# Done >> chisel v142(需改PT端): 改为绑定本地socket
export AGENT_PORT=1906 #AGENT_PORT 改用socket,不再需要
export AGENT_SOCKET=/var/run/portainer-agent-$INSTANCE_ID.sock
export AGENT_SOCKET_MODE=true
"""  |sudo tee $dpPath/env.conf > /dev/null
  echo "export DOCKER_HOST=unix:///var/run/docker.sock" |sudo tee -a $dpPath/env.conf > /dev/null
  echo "export DOCKER_BINARY_PATH=$dpPath" |sudo tee -a $dpPath/env.conf > /dev/null
  echo "export DOCKER_VOLUME_PATH=$VOLUME_PATH" |sudo tee -a $dpPath/env.conf > /dev/null


  # ./agent > logs/output.log 2>&1
  echo "gen: run.sh"
  sudo bash -c "cat > $dpPath/run.sh" <<EOF
#!/bin/bash
cur=\$(cd "\$(dirname "\$0")"; pwd)
cd \$cur
source ./env.conf
mkdir -p ./logs && exec ./agent |grep -v "occured during short poll" >> logs/output.log 2>&1 # |tee -a
EOF
  sudo chmod +x $dpPath/run.sh
}

function generateService(){
  echo "generateService"
  local WS=$dpPath
  sudo mkdir -p /etc/systemd/system
  sudo bash -c "cat > /etc/systemd/system/$svc" <<EOF
[Unit]
Description=Portainer Agent
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com

[Service]
Type=simple
WorkingDirectory=$WS
ExecStart=$WS/run.sh
#Restart=on-failure
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}

function install(){
  # preCheck, validate
  echo "download: /tmp/$PACKAGE, please wait.."
  test -s /tmp/$PACKAGE && echo "existed, skip" || sudo bash -c "curl -fsSL $BINARY_URL > /tmp/$PACKAGE" #down from gitee's release
  test -s /tmp/$PACKAGE || errExit "agent-pkg not exist"

  sudo mkdir -p "$dpPath"; #echo "dpPath: $dpPath"
  sudo tar -zxf /tmp/$PACKAGE -C /tmp; #unpack
  sudo \cp -a /tmp/agent $dpPath/ #不拷贝env.conf

  # PT: login > jwtToken, addEp, ret epKey;
  selectLocalIP #LOCAL_IP
  doLogin && endpointJudgeAdd
  generateConf 
  genUninstall $dpPath/uninstall.sh; sudo chmod +x $dpPath/uninstall.sh
  ls -lh $dpPath/

  # Systemd: init + start
  systemctl -a > /dev/null 2>&1
  if [ "0" == "$?" ]; then
    generateService #
    # 注：需要systemd环境
    sudo systemctl daemon-reload 
    sudo systemctl enable $svc #auto start
    sudo systemctl restart $svc #stop first, if exist
    # view
    sudo systemctl status $svc |grep Active
    sudo systemctl -a |grep agent
  else #DO if non-systemd: use nohup
    echo "WARN: non-systemd, run with nohup."
    # /usr/local/portainer-agent/agent-172xxx_9000/run.sh
    nohup bash $dpPath/run.sh >/dev/null 2>&1 & 
  fi
}

function genUninstall(){
  echo "gen: uninstall.sh"
  sudo bash -c "cat > $1" <<EOF
echo "unInstalling..."
systemctl -a > /dev/null 2>&1
if [ "0" == "\$?" ]; then
  # svcStopClean
  sudo systemctl stop $svc
  sudo systemctl disable $svc
  sudo systemctl status $svc |grep Active
  sudo rm -f /etc/systemd/system/$svc #del
else
  echo "WARN: non-systemd, uninstall try kill pid."
  killPids=\$(ps -ef |grep "$dpPath/run.sh" |grep -v grep |awk '{print \$2}')
  echo "killPids: \$killPids"
  test -z "\$killPids" && echo "emp, skip." || kill -9 \$killPids
fi
sudo rm -rf $dpPath #只删对应实例
EOF
}
# binary_ins.sh -act=uninstall ##本脚本执行uninstall，可删PT对应节点
function uninstall(){
  echo "removeEndpoint..."
  test -f $dpPath/env.conf || errExit "env.conf找不到(agent目录已删?, PT端节点清理将skip)"
  doLogin && endpointRemove

  # uninstall.sh
  genUninstall /tmp/ptAgent-uninstall.sh
  sh /tmp/ptAgent-uninstall.sh; sudo rm -f /tmp/ptAgent-uninstall.sh
}

case "$ACTION" in
    install)   
        install
        ;;
    uninstall)   
        uninstall
        ;;
    *)
        echo "Usage: ./ins.sh -ACT=<install/uninstall> -URL=URL -U=USER -P=PASS"
        ;;
esac
