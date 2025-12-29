FROM pufferpanel/pufferpanel:latest

USER root

# 1. تثبيت الأساسيات وإنشاء المستخدم (لحل مشكلة invalid user)
RUN apt-get update && \
    apt-get install -y curl jq openjdk-17-jre-headless openjdk-21-jre-headless && \
    groupadd -f -g 1000 pufferpanel && \
    useradd -u 1000 -g 1000 -s /bin/bash -d /var/lib/pufferpanel -m pufferpanel || true && \
    rm -rf /var/lib/apt/lists/*

# 2. سكربت التشغيل (مختصر لإصلاح الكراش فوراً)
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
set -e

# أ. إعادة كتابة ملف الإعدادات إجبارياً (لحل مشكلة Unfinished JSON)
cat <<JSON > /etc/pufferpanel/config.json
{
  "logs": "/var/log/pufferpanel",
  "web": { "host": "0.0.0.0:8080" },
  "panel": { 
    "database": { "dialect": "sqlite3", "url": "file:/var/lib/pufferpanel/pufferpanel.db" },
    "registrationEnabled": false
  }
JSON

# ب. ضبط البورت إذا كان موجوداً
if [ ! -z "$PORT" ]; then
    tmp=$(mktemp)
    jq --arg port "$PORT" '.web.host = "0.0.0.0:" + $port' /etc/pufferpanel/config.json > "$tmp" && mv "$tmp" /etc/pufferpanel/config.json
fi

# ج. إنشاء الأدمن (يتجاهل الخطأ لو موجود)
/pufferpanel/pufferpanel user add --name ${PANEL_USER:-anvlo} --password ${PANEL_PASS:-anvlo123} --email ${PANEL_EMAIL:-sonk12122@gmail.com} --admin || true

# د. إصلاح الصلاحيات وتشغيل اللوحة
chown -R pufferpanel:pufferpanel /etc/pufferpanel /var/lib/pufferpanel
exec /pufferpanel/pufferpanel run
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
