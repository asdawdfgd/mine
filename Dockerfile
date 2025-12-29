# تغييرنا النسخة إلى Ubuntu XFCE لأن نسخة Kali غير متوفرة في Webtop
FROM linuxserver/webtop:ubuntu-xfce

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

# تحميل وتثبيت PufferPanel
RUN mkdir -p /var/lib/pufferpanel
WORKDIR /var/lib/pufferpanel

# تحميل آخر إصدار وتشغيله
RUN curl -L -o pufferpanel https://github.com/PufferPanel/PufferPanel/releases/latest/download/pufferpanel_linux_amd64 && \
    chmod +x pufferpanel

# إضافة PufferPanel إلى المسار العام
RUN cp /var/lib/pufferpanel/pufferpanel /usr/local/bin/pufferpanel

# ملاحظة: سيتم استخدام Entrypoint الخاص بـ WebTop لتشغيل الواجهة
