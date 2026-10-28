# Stage 1: Build the application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /build

COPY pom.xml .
COPY src ./src

RUN mvn -B clean package -DskipTests

# Stage 2: Minimal Java runtime
FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

RUN groupadd --system spring \
    && useradd --system --gid spring --home-dir /app spring

COPY --from=builder --chown=spring:spring \
    /build/target/habit-tracker.jar /app/habit-tracker.jar

USER spring:spring

EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/habit-tracker.jar"]
