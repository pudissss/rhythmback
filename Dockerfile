# ---- Build stage ----
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy maven wrapper and pom first to leverage cache
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .

# Copy source, build
COPY src ./src

RUN chmod +x mvnw
RUN ./mvnw clean package -DskipTests

# move generated jar to a predictable name
RUN ls -la target
RUN mv target/*.jar app.jar

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy only the jar from the build stage
COPY --from=build /app/app.jar app.jar

EXPOSE 8081

CMD ["java", "-jar", "app.jar"]
