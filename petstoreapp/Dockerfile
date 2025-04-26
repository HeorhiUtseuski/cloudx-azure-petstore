FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

ARG AI_AGENT_VERSION=3.7.1
RUN apk update && apk add curl
RUN echo "Downloading applicationinsights-agent-${AI_AGENT_VERSION}.jar"
RUN curl -L "https://repo1.maven.org/maven2/com/microsoft/azure/applicationinsights-agent/${AI_AGENT_VERSION}/applicationinsights-agent-${AI_AGENT_VERSION}.jar" \
    -o /app/applicationinsights-agent.jar

COPY --from=build /app/target/*.jar app.jar
COPY applicationinsights.json /app/applicationinsights.json

EXPOSE 8080
CMD ["java", "-javaagent:applicationinsights-agent.jar", "-jar", "app.jar"]