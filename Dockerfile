# استخدام صورة Kali XFCE من LinuxServer.io كقاعدة
FROM linuxserver/webtop:kali-xfce

# تحديث النظام وتثبيت المتطلبات الأساسية
RUN apt-get update && \
    apt-get install -y \
    curl \
    wget \
    sudo \
    git \
    tar \
    unzip \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# تحميل وتثبيت PufferPanel (النسخة الثنائية Binary مباشرة لتجنب مشاكل Systemd)
RUN mkdir -p /var/lib/pufferpanel
WORKDIR /var/lib/pufferpanel

# تحميل آخر إصدار وتشغيله
RUN curl -L -o pufferpanel https://github.com/PufferPanel/PufferPanel/releases/latest/download/pufferpanel_linux_amd64 && \
    chmod +x pufferpanel

# إضافة PufferPanel إلى المسار العام ليسهل تشغيله
RUN cp /var/lib/pufferpanel/pufferpanel /usr/local/bin/pufferpanel

# إعداد الأمر ليتم تشغيله يدوياً أو عبر سكربت لاحقاً
# ملاحظة: الصورة الأساسية (WebTop) لديها نظام تشغيل خاص بها (S6-Overlay)
# نحن لن نعدل الـ Entrypoint الأساسي حتى لا نخرب واجهة سطح المكتب.
