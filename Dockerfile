FROM <docker-base-image>

EXPOSE 8080
RUN mkdir -p /app/logs
WORKDIR /app
ADD target/app.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]
#
#HEALTHCHECK --start-period=60s --interval=10s --timeout=10s --retries=3 \
#    CMD curl --silent --fail --request GET http://localhost:8080/health || exit 1
