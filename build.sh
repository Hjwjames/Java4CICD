# 移除镜像
cd /data/workspace/javademo
docker-compose down
docker rmi java-demo:v1.0
# 生成工作路径
cd /data/jenkins/workspace/first
rm -rf /data/workspace/javademo/
mkdir /data/workspace/javademo
cp Dockerfile /data/workspace/javademo/
cp docker-compose.yml /data/workspace/javademo
cd /data/jenkins/workspace/first/target
cp java-demo-0.0.1-SNAPSHOT.jar /data/workspace/javademo
cd /data/workspace/javademo
# 生成镜像
docker build -t java-demo:v1.0 .
# 构建项目
docker-compose up -d
