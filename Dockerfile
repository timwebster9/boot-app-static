FROM openjdk:8-jre-alpine

COPY target/spring-boot-sample-web-static-2.0.3.RELEASE.jar /app/

CMD ["java", "-jar", "/app/spring-boot-sample-web-static-2.0.3.RELEASE.jar"]