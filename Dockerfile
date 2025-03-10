FROM registry.cn-hangzhou.aliyuncs.com/s-ops/maven:3.5.0-alpine AS builder
WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests -s settings.xml 
FROM registry.cn-hangzhou.aliyuncs.com/s-ops/openjdk:jre
WORKDIR /appCOPY --from=builder /app/demo-prometheus/target/*.jar /app/app.jar
COPY --from=builder /app/target/*.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]
