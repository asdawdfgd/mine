FROM pufferpanel/pufferpanel:latest

USER root

# تثبيت الأدوات والجافا 17 و 21
RUN apk update && \
    apk add --no-cache openjdk17-jre-headless openjdk21-jre-headless bash curl wget

# انسخ ملف التشغيل الذي أنشأته
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV PANEL_PORT=8080
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
