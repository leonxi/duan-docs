# 短应用™ 文档
**短应用™**致力于提供一个生命周期长, 技术依赖度低, 升级速度快的网站系统
    该系统中的每个短应用™, 就像人体中的细胞一样, 承担各自不同的功能, 不断的更新, 焕发新的活力。
    每个短应用™可以由不同的语言开发, 可以快速的进行升级, 即使重新开发一遍也只需要24小时的工作量, 使用短应用™支持的系统, 每天都是一个全新, 将永不过时。

## 由来
* **入口分散** 作为一个程序员, 在做项目的过程中需要使用很多开源的系统帮助项目团队进行代码管理, 设计协同, 问题跟踪和发布等, 没有一个统一的网站提供所有系统的入口, 很不方便
* **每个团队有特有的流程** 开源的系统在使用过程中, 有些流程往往不符合自己的项目, 重新做一个和开源系统类似的功能又是一个大工程,最终只能凑合着用
* **用户分散** 每个开源系统都有独立的用户和权限管理, 当有新成员加入或者离开的时候, 不得不在每个系统中进行设置, 在没有专职的系统管理员负责的时候, 这件事就变得很复杂
* **编程语言分散** 使用不同语言和技术开发的开源系统, 由于语言或者技术不熟悉, 以及代码规模庞大, 往往很难自己去修改, 随着使用越来越深入, 问题往往越来越多得不到解决
* **生命周期短** 自己开发的内部系统, 往往因为开发人员的离开, 以及技术的更新而没人愿意维护, 重新开发的成本又很高, 随着时间的推移, 可以使用的功能也越来越少

    基于以上的原因, 我们考虑需要一个可以动态配置的Nginx进行反向代理应用网关; 需要一个容易管理的虚拟机环境（类似VMWare ESXi Server的虚拟化产品占用空间大, 部署时间长, 我们最终选择了Docker Swarm）; 需要可以脱离具体的应用系统进行用户认证和授权, 同时可以简单的集成第三方认证; 需要一个统一入口, 支持菜单的编排.

## 短应用™
[短应用™](https://www.guobaa.com)是一个应用网关, 可以把类似GitLab, Taiga, MongoExpress, phpMySQLAdmin, Portainer, Docsify以及自己开发的应用, 在同一个域名网站上提供服务;
    通过短应用™统一登录和独立菜单, 在每个应用以外提供统一的用户认证、授权和入口.
* Nginx作为短应用™入口, 通过反向代理, 转发请求到不同的应用系统, 可选支持SSL, 提供安全的访问协议 `https`, `wss`等
* Netflix Zuul作为可配置的应用网关, 通过MySQL配置路由, 反向代理 `http` 或 `https`请求, 实现 `网页` 、 `静态文件` 和 `Restful接口` 的调度
* Docker Swarm作为部署环境, 提供应用系统的DNS解析、集群部署和快捷发布环境
* 短应用™ 协议规范了路由、用户和权限, 例如: 约定了通过第一层子路径映射每个应用系统的访问路径, `/doc/` 为docsify文档系统的入口, `/tai/` 为Taiga系统的入口 ...

## 快速开始

### 使用Docker Swarm安装
1. 创建网络
```bash
docker network create --driver overlay duan-network-overlay
```

2. 部署MySQL数据库
```bash
docker service rm duan-mysql
docker service create --replicas 1 --name duan-mysql --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-mysql --lower_case_table_names=1
docker service logs -f duan-mysql
```

(可选) 部署adminer, 查看短应用™初始化结果
```bash
docker service rm duan-adminer
docker service create --replicas 1 --name duan-adminer --network duan-network-overlay --endpoint-mode=dnsrr --publish published=8089,target=8080,mode=host adminer
docker service logs -f duan-adminer
```

3. 部署Mongo数据库
```bash
docker service rm duan-mongo
docker service create --replicas 1 --name duan-mongo --network duan-network-overlay --endpoint-mode=dnsrr mongo
docker service logs -f duan-mongo
```

4. 部署短应用™ Zuul网关
```bash
docker service rm duan-zuul
docker service create --replicas 1 --name duan-zuul --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-zuul
docker service logs -f duan-zuul
```

5. 部署短应用™ Nginx代理
```bash
docker service rm duan-nginx
docker service create --replicas 1 --name duan-nginx --network duan-network-overlay --endpoint-mode=dnsrr --publish published=8088,target=80,mode=host leonxi/duan-nginx
docker service logs -f duan-nginx
```

6. 部署短应用™ 欢迎首页
```bash
docker service rm duan-aac
docker service create --replicas 1 --name duan-aac --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-home
docker service logs -f duan-aac
```

7. 部署短应用™ 用户认证
```bash
docker service rm duan-aba
docker service create --replicas 1 --name duan-aba --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-auth
docker service logs -f duan-aba
```

8. 部署短应用™ 用户授权
```bash
docker service rm duan-abd
docker service create --replicas 1 --name duan-abd --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-grant
docker service logs -f duan-abd
```

9. 部署短应用™ 内建单点登录
```bash
docker service rm duan-auo
docker service create --replicas 1 --name duan-auo --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-auth-origin
docker service logs -f duan-auo
```

10. 部署短应用™ 菜单
```bash
docker service rm duan-aad
docker service create --replicas 1 --name duan-aad --network duan-network-overlay --endpoint-mode=dnsrr leonxi/duan-menu
docker service logs -f duan-aad
```

11. 访问短应用™
确认Nginx代理部署的节点
```bash
docker service ps duan-nginx
```

访问短应用™
```
http://ip-duan-nginx:8088/
```
出现以下页面, 表示安装成功
![短应用™ 欢迎首页](https://raw.githubusercontent.com/leonxi/duan-docs/master/welcome.png)

## 版权 / License
版权所有 © 2019 上海效吉软件有限公司
