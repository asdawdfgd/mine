FROM pufferpanel/pufferpanel:latest

# 1. التثبيت والتحضير
USER root
RUN apk update && \
    apk add --no-cache \
    openjdk17-jre-headless \
    bash curl wget jq git tar unzip gcompat libstdc++

# 2. إنشاء سكريبت التشغيل الشامل
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
set -e

CONFIG_FILE="/etc/pufferpanel/config.json"

echo "🛠️  Starting PufferPanel initialization..."

# --- 1. إنشاء ملف الإعدادات لو مش موجود ---
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

# --- 2. ضبط البورت (للمنصات السحابية) ---
if [ ! -z "$PORT" ]; then
    echo "🌍 Railway Environment detected. Setting PORT to $PORT"
    tmp=$(mktemp)
    jq --arg port "$PORT" '.web.host = "0.0.0.0:" + $port' "$CONFIG_FILE" > "$tmp" && mv "$tmp" "$CONFIG_FILE"
fi

# --- 3. إدارة الأدمن ---
ADMIN_USER=${PANEL_USER:-anvlo}
ADMIN_PASS=${PANEL_PASS:-anvlo123}
ADMIN_EMAIL=${PANEL_EMAIL:-sonk12122@gmail.com}

echo "👤 Configuring Admin User..."
/pufferpanel/pufferpanel user add --name "$ADMIN_USER" --password "$ADMIN_PASS" --email "$ADMIN_EMAIL" --admin 2>/dev/null || echo "✅ User setup skipped (exists)."

# --- 4. 🧹 (الجزئية المضافة) إصلاح أسماء ملفات الجار تلقائياً ---
echo "🧹 Checking server files..."
# البحث داخل مجلدات السيرفرات فقط
if [ -d "/var/lib/pufferpanel/servers" ]; then
    cd /var/lib/pufferpanel/servers
    for dir in */; do
        if [ -d "$dir" ]; then
            cd "$dir"
            # إذا وجدنا ملف يبدأ بـ paper وينتهي بـ jar وليس اسمه paper.jar
            if ls paper-*.jar 1> /dev/null 2>&1 && [ ! -f paper.jar ]; then
                echo "🔄 Auto-Renaming jar inside $dir to paper.jar"
                mv paper-*.jar paper.jar
            fi
            cd ..
        fi
    done
fi

# --- 5. الصلاحيات ---
echo "🔒 Fixing permissions..."
chown -R pufferpanel:pufferpanel /etc/pufferpanel /var/lib/pufferpanel

# --- 6. التشغيل النهائي ---
echo "🚀 Launching PufferPanel..."
exec /pufferpanel/pufferpanel run
EOF

# جعل السكريبت قابل للتنفيذ
RUN chmod +x /entrypoint.sh

# المنفذ
EXPOSE 8080

# أمر التشغيل
ENTRYPOINT ["/entrypoint.sh"]
