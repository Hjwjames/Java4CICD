## 基于Jenkins CICD项目



#### 项目内容

- 1.基于docker-compose部署的Jenkins项目(包括git、maven、java)
- 2.spring项目搭建,解决中间件容器间内网访问
- 3.Java项目基于Dockerfile镜像打包、自动化部署



#### 环境搭建

##### 1.docker搭建

- 安装docker

```
yum install -y yum-utils
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum makecache fast
yum -y install docker-ce-18.09.9-3.el7 docker-ce-cli-18.09.9
```

- 启动docker && 开机启动

```
systemctl enable docker && systemctl start docker
systemctl status docker
```

- 设置镜像加速

```
cat > /etc/docker/daemon.json <<EOF
{
"registry-mirrors": ["https://gqk8w9va.mirror.aliyuncs.com"]
}
```

- 重启生效

```
systemctl restart docker
systemctl status docker
```

##### 2.安装docker-compose

```
sudo curl -L https://get.daocloud.io/docker/compose/releases/download/1.25.1/docker-compose-uname -s-uname -m -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

##### 3.安装Jenkins

- 安装Java环境

```
# 解压
tar -zxvf jdk-8u281-linux-x64.tar.gz 
# 修改环境变量
vim /etc/profile
    JAVA_HOME=/opt/jdk1.8
    PATH=$JAVA_HOME/bin:$PATH
    CLASSPATH=.:$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
    export PATH JAVA_HOME CLASSPATH
# 更新资源文件
source /etc/profile
```

- 安装Maven环境

```
# 解压
tar -zxvf apache-maven-3.8.5.tar.gz
# 修改环境变量
vi /etc/profile  
	export M2_HOME=/opt/apache-maven-3.8.5
	export PATH=${PATH}:$JAVA_HOME/bin:$M2_HOME/bin
# 更新资源文件
source /etc/profile       
# 查看版本
mvn -v
```

配置文件

```
<mirror> 
    <id>alimaven</id> 
    <name>aliyun maven</name> 
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url> 
     <mirrorOf>central</mirrorOf> 
 </mirror> 
<localRepository>/usr/local/maven/ck</localRepository>   
```

- 安装git

```
# 解压安装
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker
tar -zxvf git-2.30.0.tar.gz
# 修改环境变量
vi /etc/profile           
	export PATH=/opt/git/bin:$PATH
# 安装
make prefix=/opt/git-2.30.0 all      
make prefix=/opt/git-2.30.0 install
# 查看版本
git --version
```

- 安装Jenkins

创建docker-compose.yml文件

```
version: "3"

services:
  jenkins:
    image: jenkins/jenkins:lts
    user: root
    container_name: jenkins
    restart: always
    ports:
      - 8090:8080
      - 10241:50000
    volumes:
      - /opt/apache-maven-3.8.5:/usr/local/maven
      - /opt/git/bin/git:/usr/local/git 
      - /data/jenkins:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
      - /etc/localtime:/etc/localtime 
      - /usr/bin/docker:/usr/bin/docker
      - /usr/local/bin/docker-compose:/usr/local/bin/docker-compose
      - /data/workspace:/data/workspace
```

在yml文件目录下执行启动

```
docker-compose up -d #启动
docker-compose down  #关闭
```



#### DEMO项目搭建

- spring官网下载spring maven项目，引入spring web包 （建议选2.7版本，3.0以后是基于高版本JDK实现）

https://start.spring.io/

<img width="777" alt="image" src="https://user-images.githubusercontent.com/31679768/226114646-fd889574-a167-4f4e-89dd-06f243c20ae5.png">


- 简单写个Controller访问Redis

```
@RestController
public class Demo {
    @Autowired
    private StringRedisTemplate redisTemplate;

    @GetMapping("/hello")
    public String count(){
        Long increment = redisTemplate.opsForValue().increment("count-people");
        return "一共【 "+increment+" 】人访问";
    }
}
```

- 配置文件

固定内网docker内部ip，使数据隔离，不存在黑客入侵风险

```
spring.redis.host=172.18.0.2
#spring.redis.password=123321
spring.redis.port=6379
```

- 搭建个Redis

将Redis和Java docker-compose 指定相同的网桥和同一个网段固定ip，这里redis：172.18.0.2

```
version: "3"

services:
    redis:
        image: redis:6.2.6
        container_name: redis
        ports:
            - "8001:6379"
        volumes:
            - /data/redis-solo/redis.conf:/etc/redis/redis.conf
            - /data/redis-solo/data:/data
        networks:
            hjwbridge:
               ipv4_address: 172.18.0.2
        command: redis-server /etc/redis/redis.conf
networks:
     hjwbridge:
        external: true
```



#### Jenkins部署

- 配置Jenkins. Manage Jenkins ---- >全局工具配置

​			设置JDK、GIT、MAVEN
<img width="863" alt="image" src="https://user-images.githubusercontent.com/31679768/226114726-544c4093-9bc4-434a-b65b-c879b91576d6.png">


- 构建项目 ----> MAVEN项目

​			填写git地址、分支、git token账号(注意：现在github只能使用token访问)

- 配置Java启动脚本

##### Dockfile

```
#镜像打包脚本
FROM java:8
MAINTAINER HJW
ADD java-demo-0.0.1-SNAPSHOT.jar demo_docker.jar
RUN bash -c 'touch /demo_docker.jar'
ENTRYPOINT ["java","-jar","/demo_docker.jar"]
EXPOSE 8080
```

##### docker-compose.yml

```
#镜像启动脚本
version: "3"
services:
  javaDemo:
    image: java-demo:v1.0
    container_name: javaDemo
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8081:8080"
    volumes:
      - /data/workspace/javademo/data:/data
    networks:
        hjwbridge:
           ipv4_address: 172.18.0.3

networks:
  hjwbridge:
    external: true
```

##### build.sh

```
jenkenworkspace="/var/jenkins_home/workspace/"
projectname="javademo"
projectworkspace="/data/workspace/"

# 移除镜像
cd ${projectworkspace}${projectname}
docker-compose down
docker rmi java-demo:v1.0
# 生成工作路径
cd ${jenkenworkspace}${projectname}
rm -rf ${projectworkspace}${projectname}
mkdir ${projectworkspace}${projectname}
cp Dockerfile ${projectworkspace}${projectname}
cp docker-compose.yml ${projectworkspace}${projectname}
cp build.sh ${projectworkspace}${projectname}
cd ${jenkenworkspace}${projectname}/target
cp java-demo-0.0.1-SNAPSHOT.jar ${projectworkspace}${projectname}
cd ${projectworkspace}${projectname}
# 生成镜像
docker build -t java-demo:v1.0 .
# 构建项目
docker-compose up -d
```

<img width="1070" alt="image" src="https://user-images.githubusercontent.com/31679768/226114858-5308130f-7934-49b7-9e75-e75f4cd5e8a0.png">


        volumes:
