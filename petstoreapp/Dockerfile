FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN apk update && apk add curl
CMD /bin/bash
RUN echo "Downloading applicationinsights-agent-3.7.1.jar"
RUN curl "https://repo1.maven.org/maven2/com/microsoft/azure/applicationinsights-agent/3.7.1/applicationinsights-agent-3.7.1.jar" -o /app/applicationinsights-agent-3.7.1.jar

COPY --from=build /app/target/*.jar app.jar
COPY applicationinsights.json /app/applicationinsights.json
EXPOSE 8080
CMD ["java", "-javaagent:applicationinsights-agent-3.7.1.jar", "-jar", "app.jar"]