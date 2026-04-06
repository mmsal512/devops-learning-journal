#!/bin/bash

# ========================================
# Docker Cleanup Script with Telegram Notification
# Runs daily to remove unused Docker resources
# Author: Mohammed
# ========================================

# -------- إعدادات تلجرام --------
TELEGRAM_BOT_TOKEN="YOUR_BOT_TOKEN_HERE"
TELEGRAM_CHAT_ID="YOUR_CHAT_ID_HERE"

# -------- إعدادات عامة --------
RETENTION_PERIOD="72h"
HOSTNAME=$(hostname)
DATE_NOW=$(date '+%Y-%m-%d %H:%M:%S')

# -------- دالة الإرسال لتلجرام --------
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d parse_mode="HTML" \
        -d text="${message}" > /dev/null 2>&1
}

echo "========================================="
echo "Starting Docker Cleanup: $DATE_NOW"
echo "========================================="

# -------- المساحة قبل التنظيف --------
DISK_BEFORE=$(df -h / | awk 'NR==2 {print $4}')
DOCKER_DISK_BEFORE=$(docker system df 2>/dev/null)

# 1. إزالة الحاويات المتوقفة
echo "[1/5] Removing stopped containers..."
CONTAINERS_OUTPUT=$(docker container prune -f --filter "until=$RETENTION_PERIOD" 2>&1)
CONTAINERS_RECLAIMED=$(echo "$CONTAINERS_OUTPUT" | grep -oP 'Total reclaimed space: \K.*' || echo "0B")

# 2. إزالة الصور غير المستخدمة
echo "[2/5] Removing unused images..."
IMAGES_OUTPUT=$(docker image prune -a -f --filter "until=$RETENTION_PERIOD" 2>&1)
IMAGES_DELETED=$(echo "$IMAGES_OUTPUT" | grep -c "deleted:" || echo "0")
IMAGES_RECLAIMED=$(echo "$IMAGES_OUTPUT" | grep -oP 'Total reclaimed space: \K.*' || echo "0B")

# 3. إزالة الشبكات غير المستخدمة
echo "[3/5] Removing unused networks..."
NETWORKS_OUTPUT=$(docker network prune -f --filter "until=$RETENTION_PERIOD" 2>&1)
NETWORKS_DELETED=$(echo "$NETWORKS_OUTPUT" | grep -c "Deleted" || echo "0")

# 4. إزالة الـ Volumes غير المستخدمة
echo "[4/5] Removing unused volumes..."
VOLUMES_OUTPUT=$(docker volume prune -f 2>&1)
VOLUMES_RECLAIMED=$(echo "$VOLUMES_OUTPUT" | grep -oP 'Total reclaimed space: \K.*' || echo "0B")

# 5. تنظيف Build Cache
echo "[5/5] Removing build cache..."
BUILD_OUTPUT=$(docker builder prune -f --filter "until=$RETENTION_PERIOD" 2>&1)
BUILD_RECLAIMED=$(echo "$BUILD_OUTPUT" | grep -oP 'Total reclaimed space: \K.*' || echo "0B")

# -------- المساحة بعد التنظيف --------
DISK_AFTER=$(df -h / | awk 'NR==2 {print $4}')
DOCKER_DISK_AFTER=$(docker system df 2>/dev/null)

# -------- حساب إجمالي الحاويات والصور الحالية --------
RUNNING_CONTAINERS=$(docker ps -q 2>/dev/null | wc -l)
TOTAL_IMAGES=$(docker images -q 2>/dev/null | wc -l)
TOTAL_VOLUMES=$(docker volume ls -q 2>/dev/null | wc -l)

# -------- تجهيز رسالة تلجرام --------
MESSAGE="🐳 <b>Docker Cleanup Report</b>
━━━━━━━━━━━━━━━━━━━━━

🖥 <b>Server:</b> <code>$HOSTNAME</code>
📅 <b>Date:</b> <code>$DATE_NOW</code>

━━━━━━━━━━━━━━━━━━━━━
📊 <b>Cleanup Results:</b>
━━━━━━━━━━━━━━━━━━━━━

📦 <b>Containers:</b>
   ├ Reclaimed: <code>$CONTAINERS_RECLAIMED</code>

🖼 <b>Images:</b>
   ├ Deleted: <code>$IMAGES_DELETED</code> image(s)
   ├ Reclaimed: <code>$IMAGES_RECLAIMED</code>

🌐 <b>Networks:</b>
   ├ Deleted: <code>$NETWORKS_DELETED</code> network(s)

💾 <b>Volumes:</b>
   ├ Reclaimed: <code>$VOLUMES_RECLAIMED</code>

🔨 <b>Build Cache:</b>
   ├ Reclaimed: <code>$BUILD_RECLAIMED</code>

━━━━━━━━━━━━━━━━━━━━━
💽 <b>Disk Space:</b>
━━━━━━━━━━━━━━━━━━━━━
   ├ Before: <code>$DISK_BEFORE</code> free
   ├ After:  <code>$DISK_AFTER</code> free

━━━━━━━━━━━━━━━━━━━━━
📈 <b>Current Status:</b>
━━━━━━━━━━━━━━━━━━━━━
   ├ Running Containers: <code>$RUNNING_CONTAINERS</code>
   ├ Total Images: <code>$TOTAL_IMAGES</code>
   ├ Total Volumes: <code>$TOTAL_VOLUMES</code>

✅ <b>Cleanup Completed Successfully!</b>"

# -------- إرسال الإشعار --------
send_telegram "$MESSAGE"

if [ $? -eq 0 ]; then
    echo "Telegram notification sent successfully!"
else
    echo "Failed to send Telegram notification!"
fi

echo ""
echo "Cleanup completed at: $(date)"
echo "========================================="
