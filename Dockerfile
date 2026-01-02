# Stage 1: Build the application
# We use a Maven image that includes Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Build the jar
RUN mvn clean package -DskipTests

# Stage 2: Run the application
# We use a lightweight Java 21 runtime image
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
# Copy the built jar from Stage 1
COPY --from=build /app/target/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]