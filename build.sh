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
