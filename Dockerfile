# Base image
FROM openjdk:17-jdk-slim

# 작업 디렉토리 설정
WORKDIR /app

# 빌드된 애플리케이션 복사
COPY build/libs/app.jar app.jar

# 애플리케이션 실행 명령어
CMD ["java", "-jar", "app.jar"]