
```bash
headless @ barge in .../lang-replacement/generate |17:31:51  |dev U:3 ?:3 ✗| 
$ cat t1.txt  |sed "s^<expect><\!\[CDATA\[^bb/^g"
bb/
# $ cat t1.txt 
<expect><![CDATA[
```

- dictReplace.txt

```bash
$ cat portainer_zh.xml |grep expect |grep fications  |sort |wc
    385    2138   37171
$ cat portainer_zh.xml |grep expect |grep fications  |sort |uniq |wc
    280    1570   27113
$ cat portainer_zh.xml |grep expect |grep fications  |sort -u |wc
    280    1570   27113


# 生成dict_fications.txt
$ cat portainer_zh.xml |grep expect |grep fications  |sort -u |awk '$1=$1' > dict_fications.txt

$ cat portainer_zh.xml |grep expect |grep fications  |sort -u |awk '$1=$1' |while read one; do echo "$one|$one"; done > dict_fications.txt 

# 280-90(sucMsg)-10*(top)=余下 180行 ##10.17号中午

# GITEE_ERR: .txt > .dat??
==[dictReplace]===============
该文件疑似存在违规内容，无法显示
该文件疑似存在违规内容，无法显示
```

## notifications汉化字典:

```bash
notifications.
./fk-portainer/app/ x618
ex: portainer,docker,kubernetes,edge,integrations,azure,agent: x0
./fk-portainer/app/kubernetes x131
./fk-portainer/app/edge x33
./fk-portainer/app/agent x16
./fk-portainer/app/azure x9
./fk-portainer/app/integrations x40

# 
./fk-portainer/app/portainer  x221
	notifications.error  x153  fications.error(.*) >> @@@;
		fications.error\('(.*)': x153 fications.error\('(.*)' >>> @@@
	notifications.success x68  fications.success(.*) >> @@@;
		fications.success\('(.*)': X68 fications.success\('(.*)' >> @@@

./fk-portainer/app/docker  x168
	fications.error(.*) x116
		fications.error\('(.*)': x114 fications.error\('(.*)' >>> @@@
	fications.success(.*): X49
		fications.success\('(.*)': X47 fications.success\('(.*)' >> @@@
	fications.warning(.*) x3
		fications.warning\('(.*)': x3 fications.warning\('(.*)' >>> @@@




# -----------
# DOCKER: 之前已汉化记录
# err:
Notifications.error('节点连接失败', e);
Notifications.error('Failure', err, '获取节点信息失败');
Notifications.error('Failure', err, '容器删除失败');
this.Notifications.error('Failure', err, '获取仓库失败');
this.Notifications.error('Failure', err, '获取镜像失败');
Notifications.error('Failure', err, '获取 macvlan');
this.Notifications.error('Failure', err, '获取配置失败');
Notifications.error('Failure', err, '获取容器失败');
Notifications.error('Failure', details, 'Container ' + attachId + ' 未运行!');
Notifications.error('Error', err, '获取容器明细失败');
Notifications.error('Failure', err, '不能进入容器');
Notifications.error('Error', err, '获取容噟����������������������������明细失败');
Notifications.error('Failure', err, '获取仓库失败');
Notifications.error('Failure', err, '获取容器失败');
Notifications.error('Failure', err, '获取网络失败');
Notifications.error('Failure', err, '获取容器信息失败');
return Notifications.error('Failure', err, '拉取镜像失败');
Notifications.error('Failure', err, '拉取镜像失败');


# suc:
Notifications.success('容器已删除', container.Names[0]);
this.Notifications.success('配置删除成功', config.Name);
Notifications.success('镜像已拉取', registryModel.Image);
Notifications.success('Network 删除成功', network.Name);
Notifications.success('Network 创建成功');
Notifications.success('Secret 删除成功', secret.Name);
Notifications.success('Secret 创建成功');
Notifications.success('Volume 创建成功');
Notifications.success('Snapshot 删除成功', item.Id);
Notifications.success('Volume 删除成功', $transition$.params().id);


```