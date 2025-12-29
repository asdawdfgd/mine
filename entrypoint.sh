#!/bin/bash
set -e

# إصلاح الأسماء
if [ -d "/var/lib/pufferpanel/servers" ]; then
    cd /var/lib/pufferpanel/servers && \
    for dir in */; do
        if ls "$dir"paper-*.jar 1> /dev/null 2>&1 && [ ! -f "$dir"paper.jar ]; then
            mv "$dir"paper-*.jar "$dir"paper.jar
        fi
    done
fi

# إضافة الأدمن
/pufferpanel/pufferpanel user add --name anvlo --password anvlo123 --email sonk12122@gmail.com --admin || true

# الصلاحيات وتشغيل
chown -R pufferpanel:pufferpanel /etc/pufferpanel /var/lib/pufferpanel
exec /pufferpanel/pufferpanel run
