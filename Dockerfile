FROM pufferpanel/pufferpanel:latest

USER root

# 1. التعديل هنا: استخدام apt-get بدلاً من apk
# وتعديل أسماء حزم الجافا لتناسب ديبيان/أوبونتو
RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jre-headless \
    openjdk-21-jre-headless \
    bash curl wget jq git tar unzip && \
    rm -rf /var/lib/apt/lists/*

# 2. بقية السكريبت الذكي (كما هو، ممتاز جداً)
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
set -e

CONFIG_FILE="/etc/pufferpanel/config.json"

echo "🛠️  Starting PufferPanel initialization..."

# --- 1. إنشاء ملف الإعدادات ---
if [ ! -f "$CONFIG_FILE" ]; then
    echo "📄 Config not found, generating default..."
    cat <<JSON > $CONFIG_FILE
{
  "logs": "/var/log/pufferpanel",
  "web": {
    "host": "0.0.0.0:8080"
  },
  "panel": {
    "database": {
      "dialect": "sqlite3",
      "url": "file:/var/lib/pufferpanel/pufferpanel.db"
    },
    "registrationEnabled": false
  }
JSON
fi

# --- 2. ضبط البورت ---
if [ ! -z "$PORT" ]; then
    echo "🌍 Environment detected. Setting PORT to $PORT"
    tmp=$(mktemp)
    jq --arg port "$PORT" '.web.host = "0.0.0.0:" + $port' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
fi

# --- 3. إصلاح أسماء ملفات الجار (مهم جداً) ---
if [ -d "/var/lib/pufferpanel/servers" ]; then
    echo "🧹 Checking server files..."
    cd /var/lib/pufferpanel/servers
    for dir in */; do
        if [ -d "$dir" ]; then
            cd "$dir"
            # لو لقينا ملف اسمه paper-*.jar بنغير اسمه لـ paper.jar
            if ls paper-*.jar 1> /dev/null 2>&1 && [ ! -f paper.jar ]; then
                echo "🔄 Auto-Renaming jar inside $dir to paper.jar"
                mv paper-*.jar paper.jar
            fi
            cd ..
        fi
    done
fi

# --- 4. إدارة الأدمن ---
ADMIN_USER=${PANEL_USER:-anvlo}
ADMIN_PASS=${PANEL_PASS:-anvlo123}
ADMIN_EMAIL=${PANEL_EMAIL:-sonk12122@gmail.com}

/pufferpanel/pufferpanel user add --name "$ADMIN_USER" --password "$ADMIN_PASS" --email "$ADMIN_EMAIL" --admin 2>/dev/null || echo "✅ Admin setup skipped."

# --- 5. الصلاحيات والتشغيل ---
echo "🔒 Fixing permissions..."
chown -R pufferpanel:pufferpanel /etc/pufferpanel /var/lib/pufferpanel

echo "🚀 Launching PufferPanel..."
exec /pufferpanel/pufferpanel run
EOF

RUN chmod +x /entrypoint.sh

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
