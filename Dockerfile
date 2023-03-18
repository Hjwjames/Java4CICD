FROM java:8
MAINTAINER HJW
ADD java-demo-0.0.1-SNAPSHOT.jar demo_docker.jar
RUN bash -c 'touch /demo_docker.jar'
ENTRYPOINT ["java","-jar","/demo_docker.jar"]
EXPOSE 8080

