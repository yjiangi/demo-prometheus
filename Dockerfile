FROM registry.cn-hangzhou.aliyuncs.com/s-ops/maven:3.5.0-alpine AS builder
WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests -s settings.xml 
FROM registry.cn-hangzhou.aliyuncs.com/s-ops/openjdk:jre
WORKDIR /app
COPY --from=builder /app/demo-prometheus/target/*.jar /app/app.jar
EXPOSE 8012
ENTRYPOINT ["java","-jar","/app/app.jar"]
