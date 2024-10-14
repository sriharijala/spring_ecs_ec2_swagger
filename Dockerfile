FROM amazoncorretto:21-alpine3.17-jdk

# Copy source to container
RUN mkdir -p /usr/app

ADD target/user-reviews-0.0.1-SNAPSHOT.jar /usr/app/app.jar

WORKDIR /usr/app

# Create a user group 'appgroup'
RUN addgroup -S appgroup

# Create a user 'appuser' under 'appgroup'
RUN adduser -S -D -h /usr/app appuser appgroup

# Chown all the files to the app user.
RUN chown -R appuser:appgroup /usr/app

#set environment vaiables
ENV DB_HOST=
ENV DB_PORT=
ENV DB_USER=
ENV DB_PASSWORD=
ENV DB_DATABASE=
ENV APP_CONFIG_DIR=
ENV SPRING_DATASOURCE_URL=


# Switch to 'appuser'
USER appuser

# Open the mapped port
EXPOSE 8080
ENTRYPOINT ["java","-jar","-Djava.security.egd=file:/dev/./urandom","app.jar","--spring.profiles.active=prod"]
