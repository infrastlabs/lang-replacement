#!/bin/bash
cur=$(cd "$(dirname "$0")"; pwd)

# ===============================================
# export SERVER_URL="http://172.25.23.192:680" #9000
# export SERVER_USER="admin"
# export SERVER_PASS="admin123"
# # export COUNT=2 #MultiAgent(default 1)
# # export AUTH="-u admin:admin123" #PrivateRepo
# curl -k -fSL $AUTH https://gitee.com/g-devops/lang-replacement/raw/dev/static/binary_ins.sh |bash -s #uninstall
# 
# deps: curl, jq/gojq, goawk
# ===============================================

# ACTION=$1; shift
CONST_NOT_ALIVE=5 #20
#AUTH="-u admin:admin123"
C=/opt/.cache_binary_ins; mkdir -p $C #cacheDir
sudo -V > /dev/null 2>&1; test "0" == "$?" && sudo="sudo" || sudo=""
function errLog(){
  echo "$1"
  test "$2" != "false" && exit 1
}
# from ENV
test -z "$SERVER_URL" && errLog "SERVER_URL 为空"
test -z "$SERVER_USER" && errLog "SERVER_USER 为空"
test -z "$SERVER_PASS" && errLog "SERVER_PASS 为空"
test -z "$DEPLOY" && DEPLOY="/usr/local/portainer-agent"
test -z "$VOLUME_PATH" && VOLUME_PATH="/var/lib/docker/volumes" #"/opt/docker-data/volumes" 
# exit 0 #debug_skip
BinDir=$DEPLOY/bin; mkdir -p $BinDir #/bin #/usr/bin
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin #psu host pty
sudo echo 123 > /dev/null 2>&1; test "0" == "$?" && sudo="sudo" || sudo=""
echo -e "\nsudo: $sudo"

function checkDeps(){ #static-curl,gojq,goawk
  # apt/yum install curl jq
  # wget -qO - $url # curl -k -fSL $url
  wgetAUTH=""
  if [ ! -z "$AUTH" ]; then
    local auth2=$(echo $AUTH |awk '{print $2}')
    local user=$(echo $auth2 |cut -d':' -f1)
    local pass=$(echo $auth2 |cut -d':' -f2)
    wgetAUTH="--http-user=$user  --http-passwd=$pass"
  fi

  # curl|wget
  wget -V > /dev/null 2>&1
  test "0" == "$?" && dlcmd="wget $wgetAUTH --no-check-certificate -O" || dlcmd="curl -k -fSL $AUTH -o"
  echo "==dlcmd: $dlcmd"

  # static-curl
  local arch=amd64; test -z "$(uname -a |grep aarch)" || arch=aarch64 
  local file=static-curl-$arch
  curl_url=https://ghproxy.com/https://github.com/moparisthebest/static-curl/releases/download/v7.88.1/curl-$arch
  test -s $C/$file && echo "existed, skip" || $dlcmd $C/$file $curl_url
  curlBin=$C/$file; chmod +x $curlBin
  $curlBin -V > /dev/null 2>&1; test "0" == "$?" || errLog "curl-static错误"

  # jq/gojq
  local arch=amd64; test -z "$(uname -a |grep aarch)" || arch=arm64 
  gojq_url=https://ghproxy.com/https://github.com/itchyny/gojq/releases/download/v0.12.12/gojq_v0.12.12_linux_$arch.tar.gz
  test -s $C/gojq && echo "existed, skip" || $curlBin -k -fSL $AUTH $gojq_url | tar -zx -C $C --strip-components=1; #wget -O -
  jqBin=$C/gojq; $sudo chmod +x $jqBin
  $jqBin -v > /dev/null 2>&1; test "0" == "$?" || errLog "gojq 错误"
  
  # goawk
  goawk_url=https://ghproxy.com/https://github.com/benhoyt/goawk/releases/download/v1.23.1/goawk_v1.23.1_linux_$arch.tar.gz
  #test -s $C/goawk && echo "existed, skip" || $curlBin -k -fSL $AUTH $goawk_url | tar -zx -C $C --strip-components=1;
}
echo -e "\ncheckDeps" && checkDeps
# preCheck, validate
PACKAGE="agent-v291.tar.gz" #agent程序包
test -z "$(uname -a |grep aarch)" && arch=x64 || arch=arm64
# https://gitee.com/g-devops/fk-agent/attach_files/1020608/download/agent-v291-220407.tar.gz #892492/download/agent-v291-1125.tar.gz
# https://gitee.com/g-devops/fk-agent/releases/download/agent-v291-230522/agent-v291-x64-230523.tar.gz
# BINARY_URL=https://gitee.com/g-devops/fk-agent/releases/download/agent-v291-230522/agent-v291-$arch-230523.tar.gz
BINARY_URL=https://gitee.com/g-devops/fk-agent/releases/download/agent-v291-230725/agent-v291-230725-$arch.tar.gz
BINARY_HOST="{{.}}"
# BINARY_HOST="http://172.25.21.62:9000" #dbg
test -z $(echo $BINARY_HOST |grep "}}") && BINARY_URL="$BINARY_HOST/static/$PACKAGE" #ct's /misc/binary_ins.sh
test -z $(echo $BINARY_HOST |grep "}}") && SERVER_URL=$BINARY_HOST #"http://172.17.0.60:9000" #golang从req中获取，tpl写入

# echo "download: $C/$PACKAGE, please wait.."
echo "BINARY_URL: $BINARY_URL"
test -s $C/$PACKAGE && echo "existed, skip" || $sudo $curlBin -k -fSL $AUTH -o $C/$PACKAGE $BINARY_URL #down from gitee's release
test -s $C/$PACKAGE || errLog "agent-pkg not exist"

function initSV(){ # go-supervisor
  echo "initSV"
  local arch=amd64
  test -z "$(uname -a |grep aarch)" && arch=64-bit || arch=ARM64; \
  gosv_url=https://ghproxy.com/https://github.com/ochinchina/supervisord/releases/download/v0.7.3/supervisord_0.7.3_Linux_$arch.tar.gz; \
  test -s $C/supervisord && echo "existed, skip" || $curlBin -k -fSL $AUTH $gosv_url | tar -zx -C $C --strip-components=1; \
  \cp -a $C/supervisord $BinDir/go-supervisord;
  rm -f $BinDir/sv; echo -e "#!/bin/bash\ntest -z "\$1" && go-supervisord ctl -h || go-supervisord ctl \$@" > $BinDir/sv; chmod +x $BinDir/sv;
  # 
  $sudo mkdir -p /var/run /var/log/supervisor /etc/supervisor
  $sudo bash -c "cat > /etc/supervisor/supervisord.conf" <<EOF
[unix_http_server]
file=/var/run/supervisor.sock   ; (the path to the socket file)
chmod=0700                       ; sockef file mode (default 0700)
;[inet_http_server]
;port=0.0.0.0:9001 ;9001
;username=root
;password=root123 ; replace with vnc-view's pass? (ro)
;;prom http://127.0.0.1:9001/metrics
[supervisord]
logfile=/var/log/supervisor/supervisord.log ; (main log file;default $CWD/supervisord.log)
pidfile=/var/run/supervisord.pid ; (supervisord pidfile;default supervisord.pid)
childlogdir=/var/log/supervisor            ; ('AUTO' child log dir, default $TEMP)
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
[supervisorctl]
serverurl=unix:///var/run/supervisor.sock ; use a unix:// URL  for a unix socket
[include]
files = /etc/supervisor/conf.d/*.conf
EOF
}
systemctl -a > /dev/null 2>&1
test "0" != "$?" && initSV

function doLogin(){
  echo "doLogin"
  # validate:
  $curlBin --connect-timeout 3 -s $SERVER_URL > /dev/null 2>&1 #3s
  local errCode=$?; test "0" == "$errCode" || errLog "$SERVER_URL 地址访问失败，curl错误码: $errCode"

  # if login err;
  ret=$($curlBin -s -H "Content-Type: application/json" -d "{\"username\":\"$SERVER_USER\",\"password\":\"$SERVER_PASS\"}" -X POST $SERVER_URL/api/auth)
  # echo "ret: $ret"
  # Access denied to resource
  message=$(echo $ret |grep "message"); test -z "$message" ||  errLog "$SERVER_URL 登录失败，detail: $ret"  
  
  # LOGIN_TOKEN
  LOGIN_TOKEN=$(echo $ret | $jqBin -r .jwt) #global
  test -z "$LOGIN_TOKEN" && errLog "LOGIN_TOKEN为空" || echo "LOGIN_TOKEN: $LOGIN_TOKEN"
}

function endpointJudgeAdd(){
  unset EDGE_EP_ID EDGE_EP_NAME EDGE_KEY EDGE_ID #reset for eachNewLoop
  # clearDuplicate ##当列表较多时(>50)，消耗时间较长；
  # exit 0
  local rq=$(date +%Y%m%d.%H%M%S |sed "s/^..//")
  # local rand=$(tr -dc 'A-Z0-9' </dev/urandom | head -c 2)
  EDGE_ID_new="id-$LOCAL_IP-$rq" #存放于agent端，首注册时送到PT
  
  # 清理后，重load一次
  # local jsonList=$($curlBin -s -X GET "$SERVER_URL/api/endpoints?limit=0&start=0"  -H "Authorization: Bearer $LOGIN_TOKEN") #|$jqBin ".Name"
  json=$C/.pt_jsonList.txt
  $curlBin -s -X GET "$SERVER_URL/api/endpoints?limit=0&start=0"  -H "Authorization: Bearer $LOGIN_TOKEN" \
   |$jqBin -c "del(.[].SecuritySettings,.[].Kubernetes,.[].AzureCredentials,.[].TLSConfig)" > $json
  local len=$(cat $json |$jqBin ".|length")
  echo "==PT已有主机数：$len"
  EDGE_NAME=$LOCAL_IP$INDEX; #EP_EDGE_KEY="" #

  # speedup: 如果匹配上再loop;
  match0=$(cat $json |$jqBin |grep Name |grep "$EDGE_NAME\"")
  if [ ! -z "$match0" ]; then #如非空，进loop
  idx0=$(cat $json |$jqBin |grep Name |grep "$EDGE_NAME\"" -n |head -1 |cut -d':' -f1 |cut -d'|' -f1)
  idx0=$(($idx0-1))
  echo "EDGE_NAME: $EDGE_NAME, idx0-1: $idx0"; cat $json |$jqBin ".[$idx0]" |grep Name
  local i=$idx0; local epName=$(cat $json |$jqBin -r ".[$i].Name")
  # for ((i=0; i<$len; i++)); do
  #   # echo $i
  #   local epName=$(cat $json |$jqBin -r ".[$i].Name")
  #   if [ "$EDGE_NAME" == "$epName" ]; then
      # cat $json |$jqBin -r ".[$i].Status" #status=1， 无用途
      # exist: 
      # 如活跃：fail(请提前删除)
      # 如不活跃：解除关联，复用旧的EDGE_KEY
      local id=$(cat $json |$jqBin -r ".[$i].Id")
      local qryDate=$(cat $json |$jqBin -r ".[$i].QueryDate")
      local lastCheckDate=$(cat $json |$jqBin -r ".[$i].LastCheckInDate")
      local val1=`expr $qryDate - $lastCheckDate`
      # cat $json |$jqBin ".[$i]" #dbg
      # test "$val1" -gt "20" && echo "val1: $val1" #超过20s

      EDGE_EP_ID=$(cat $json |$jqBin -r ".[$i].Id")
      EDGE_EP_NAME=$(cat $json |$jqBin -r ".[$i].Name")
      EDGE_KEY=$(cat $json |$jqBin -r ".[$i].EdgeKey") #used for install_2
      EDGE_ID=$(cat $json |$jqBin -r ".[$i].EdgeID")
      if [ "$val1" -gt "$CONST_NOT_ALIVE" ]; then #20s
        echo "[$i]==$id-$epName, 已存在(不活跃)，本次将复用该节点的EDGE_KEY"

        # lastCheckDate == 0: 表明从未用过，无需解绑
        if [ "0" != "$lastCheckDate" ]; then 
          echo "lastCheckDate!=0, 进行解绑操作ing"; 
          # slow: pt-boltdb-batch
          $curlBin -s -X DELETE "$SERVER_URL/api/endpoints/$id/association"  -H "Authorization: Bearer $LOGIN_TOKEN" |$jqBin -r ".Id"
          EDGE_ID=$EDGE_ID_new #解绑后才用新id
        else
          echo "lastCheckDate=0(未反向注册过), 不用解绑, skip"
          # 仍用旧EDGE_ID
        fi
        # break #如多个: 取第一个即返回
      else
        # echo "still active"
        errLog "[RETURN] $id-$epName, 已存在且活跃，本次节点注册失败。(请检查本地获取到的IP节点名是否正确：$epName, 或先停用/删除PT端已有Agent节点)" false
        
        # TODO: 此项aliveNode>> 不应该跑新进程(Edge identifier对不上，也用不了)

        # EDGE_EP_ID="$EP_EDGE_ID";EDGE_EP_NAME="$EP_EDGE_NAME";EDGE_KEY="$EP_EDGE_KEY"
        echo "复用节点，EDGE_KEY(decode):"
        echo $EDGE_KEY |base64 -d
        export EDGE_EP_ID EDGE_EP_NAME EDGE_KEY EDGE_ID #暴露给之后func使用
        return #return func >> DO: 这里return 导致install_2取到上1条的信息?? (未export)
      fi
  #   fi
  # done
  fi

  # 如不存在，则添加：
  # EDGE_KEY=""
  if [ -z "$EDGE_KEY" ]; then
    # epName：简短唯一; agentID: 格式<IP_AddTime>
    # EDGE_NAME=$LOCAL_IP$INDEX #$ip-$rand
    test -z "$NODENAME" || EDGE_NAME=$NODENAME$INDEX
    # -F "URL=$SERVER_URL"  ##try notes: 导致注册的节点写死了URL(需要epUpdate操作才更新)
    # 22.1.19: -F "URL=$SERVER_URL"  ##UI中会自动带上, pt-cn1124测试：当不指定URL时，导致生成的EDGE_KEY没得URL信息， ptAgent注册失败.
    local jsonAdd=$($curlBin -s -X POST $SERVER_URL/api/endpoints -H "accept: application/json" -H "Authorization: Bearer $LOGIN_TOKEN" -F "URL=$SERVER_URL" -F "Name=$EDGE_NAME" -F "EndpointCreationType=4")
    # echo "jsonAdd: $jsonAdd" |grep "Invalid"
    EDGE_EP_ID=$(echo $jsonAdd |$jqBin -r .Id) #表ID号
    EDGE_EP_NAME=$(echo $jsonAdd |$jqBin -r .Name) #IP名
    EDGE_KEY=$(echo $jsonAdd |$jqBin -r .EdgeKey) #&& echo $EDGE_KEY
    test -z "$EDGE_KEY" && errLog "[RETURN] EDGE_KEY为空, PT端新加节点失败: $EDGE_NAME"  false
    echo "新加节点，EDGE_KEY(decode):"
    echo $EDGE_KEY |base64 -d
    EDGE_ID=$EDGE_ID_new
    
  # else
  #   EDGE_EP_ID="$EP_EDGE_ID"; EDGE_EP_NAME="$EP_EDGE_NAME"; EDGE_KEY="$EP_EDGE_KEY"
  #   echo "复用节点，EDGE_KEY(decode):"
  #   echo $EDGE_KEY |base64 -d
  fi  
  export EDGE_EP_ID EDGE_EP_NAME EDGE_KEY EDGE_ID #暴露给之后func使用
  test -z "$EDGE_KEY" && endpointJudgeAdd #失败则重试，TODO: EDGE_KEY_MAX_RETRY=3
  # install_2 #aviod returned, still exec
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
    $curlBin -s -X DELETE "$SERVER_URL/api/endpoints/$id"  -H "Authorization: Bearer $LOGIN_TOKEN"
  fi
}

# LOCAL_IP
function selectLocalIP(){
  # 取IP: ip > ifconfig > nonip-$(hostname)
  LOCAL_IP=$(ip a |grep inet |grep -v "inet6\|lo$\|br\-\|docker" |awk '{print $2}' |cut -d'/' -f1 |head -1) #list: head -1
  test -z "$LOCAL_IP" && LOCAL_IP=$(ifconfig  -a |grep "flags\|inet " |sed ":a;N;s/\n *inet/|inet/g" |grep -v "lo: \|br\-\|docker" |cut -d'|' -f2 |awk '{print $2}' |head -1)
  test -z "$LOCAL_IP" && LOCAL_IP="nonip-$(hostname)" #-$rq # ip="1.2.3.4"

  HOST=$(hostname) #REF: KEDGE
  echo "HOST: $HOST"
  hostlen=${#HOST}; test "$hostlen" -gt "6" && hostlen=6 || echo "hostlen<6"
  h1=${HOST:0-$hostlen}
  test "-" == "${h1:0:1}" && h1="x${h1:1}"
  LOCAL_IP="$h1-$LOCAL_IP"
  echo "Got Local IP(top 1): $LOCAL_IP"  
}

function generateConf(){
  echo "gen: env.conf"
  echo "EDGE_KEY: $EDGE_KEY"
  echo "EDGE_ID: $EDGE_ID"
  local rq=$(date +%Y%m%d.%H%M%S |sed "s/^..//")
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
export AGENT_SOCKET=$agentSock
export AGENT_SOCKET_MODE=true
"""  |$sudo tee $dpPath/env.conf > /dev/null
  echo "export DOCKER_HOST=unix:///var/run/docker.sock" |$sudo tee -a $dpPath/env.conf > /dev/null
  echo "export DOCKER_BINARY_PATH=$dpPath" |$sudo tee -a $dpPath/env.conf > /dev/null
  echo "export DOCKER_VOLUME_PATH=$VOLUME_PATH" |$sudo tee -a $dpPath/env.conf > /dev/null


  # ./agent > logs/output.log 2>&1
  echo "gen: run.sh"
  $sudo bash -c "cat > $dpPath/run.sh" <<EOF
#!/bin/bash
cur=\$(cd "\$(dirname "\$0")"; pwd)
cd \$cur
source ./env.conf
#mkdir -p ./logs
#exec ./agent |grep -v "occured during short poll" >> logs/output.log 2>&1 # |tee -a
#exec ./agent > >(tee -a \$cur/logs/output.log) 2>&1 #|grep -v "occured during short poll"
rm -rf ./logs; ln -s /var/log/supervisor ./logs
exec \$cur/agent #full path
EOF
  $sudo chmod +x $dpPath/run.sh
}

function generateService(){
  echo "generateService"
  $sudo mkdir -p /etc/systemd/system
  $sudo bash -c "cat > /etc/systemd/system/$svc" <<EOF
[Unit]
Description=Portainer Agent
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com

[Service]
Type=simple
WorkingDirectory=$dpPath
ExecStart=$dpPath/run.sh
#Restart=on-failure
Restart=always
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
}
function generateSV(){
  echo "generateSV"
  $sudo mkdir -p /etc/supervisor/conf.d
  $sudo bash -c "cat > /etc/supervisor/conf.d/$svc.conf" <<EOF
[program:$svc]
priority=20
user=root
startretries=5
autorestart=true
command=$dpPath/run.sh
stdout_logfile=/var/log/supervisor/$svc.log
stdout_logfile_maxbytes = 50MB
stdout_logfile_backups  = 10
redirect_stderr=true
EOF
}

function install(){
  $sudo mkdir -p "$dpPath"; #echo "dpPath: $dpPath"
  $sudo tar -zxf $C/$PACKAGE -C $C; #unpack
  $sudo \cp -a $C/agent-$arch $dpPath/agent #不拷贝env.conf

  # PT: login > jwtToken, addEp, ret epKey;
  endpointJudgeAdd
  install_2
}
function install_2(){
  generateConf 
  genUninstall $dpPath/uninstall$INDEX.sh; $sudo chmod +x $dpPath/uninstall$INDEX.sh
  ls -lh $dpPath/

  # Systemd: init + start
  systemctl -a > /dev/null 2>&1
  if [ "0" == "$?" ]; then
    generateService #
    # 注：需要systemd环境
    $sudo systemctl daemon-reload 
    $sudo systemctl enable $svc #auto start
    $sudo systemctl restart $svc #stop first, if exist
    # view
    $sudo systemctl status $svc |grep Active
    $sudo systemctl -a |grep agent
  else #DO if non-systemd: use nohup
    echo "WARN: non-systemd, run with gosv/nohup."
    generateSV
    match1=$(ps -ef |grep "go-supervisord" |grep -v grep)
    if [ -z "$match1" ]; then 
      echo "start gosv"
      # exec go-supervisord
      nohup $BinDir/go-supervisord >/dev/null 2>&1 &
    else 
      export PATH=$BinDir:$PATH;
      echo "sv reload"; sv reload; sv restart $svc #restart cur-svc
    fi
    # echo sleep 1; sleep 1
    # export PATH=$BinDir:$PATH; sv status #view
  fi
}

function genUninstall(){
  echo "gen: uninstall.sh"
  $sudo bash -c "cat > $1" <<EOF
echo "unInstalling..."
systemctl -a > /dev/null 2>&1
if [ "0" == "\$?" ]; then
  # svcStopClean
  $sudo systemctl stop $svc
  $sudo systemctl disable $svc
  $sudo systemctl status $svc |grep Active
  $sudo rm -f /etc/systemd/system/$svc #del
else
  echo "WARN: non-systemd, uninstall try kill pid."
  killPids=\$(ps -ao pid,user,comm,args |grep "$dpPath/agent" |grep -v grep |awk '{print \$1}')
  echo "killPids: \$killPids"
  test -z "\$killPids" && echo "emp, skip." || kill -9 \$killPids
fi
$sudo rm -rf $dpPath #只删对应实例
EOF
}
# binary_ins.sh -act=uninstall ##本脚本执行uninstall，可删PT对应节点
function uninstall(){
  echo "removeEndpoint..."
  test -f $dpPath/env.conf || errLog "env.conf找不到(agent目录已删?, PT端节点清理将skip)" false
  doLogin && endpointRemove

  # uninstall.sh
  genUninstall $C/ptAgentUnInstall$INDEX.sh
  sh $C/ptAgentUnInstall$INDEX.sh; $sudo rm -f $C/ptAgentUnInstall$INDEX.sh
}

echo "===doInstall=========="
# SERVER_IP TODO: if domain, ping
SERVER_IP=$(echo $SERVER_URL |grep -E -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+" |sed "s/\:/_/g"); test -z "$SERVER_IP" && errLog "fail to get SERVER_IP"
dpPath="$DEPLOY/agent-$SERVER_IP"
svc="agent-$SERVER_IP.service"
agentSock=/var/run/portainer-agent-$SERVER_IP.sock
#LOCAL_IP
selectLocalIP; doLogin; INDEX=""
# COUNT=10 #dbg
test -z "$COUNT" && COUNT=1
function doMulti(){
  echo "#Barge环境rebootVM再初始：sleep \$CONST_NOT_ALIVE; ($CONST_NOT_ALIVE)，让PT节点不活跃"; sleep $CONST_NOT_ALIVE
  for((idx=1;idx<=$COUNT;idx++));do
    echo "doMulti: $idx"; INDEX="-$idx"
    dpPath="$DEPLOY/agent-$SERVER_IP$INDEX"
    svc="agent-$SERVER_IP$INDEX.service"
    agentSock=/var/run/portainer-agent-$SERVER_IP$INDEX.sock
    $1 #ins/unins
  done
}
case "$1" in
    uninstall)   
        test "1" == "$COUNT" && uninstall || doMulti "uninstall"
        ;;
    *)
        test "1" == "$COUNT" && install || doMulti "install"
        ;;
esac

echo "export PATH=$BinDir:\$PATH; sv status #view"