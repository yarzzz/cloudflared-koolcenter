#!/bin/sh
eval `dbus export cloudflared`
source /koolshare/scripts/base.sh
alias echo_date='echo $(date +%Y年%m月%d日\ %X):'

# Define constants
LOG_FILE="/tmp/upload/cloudflaredupdate.log"
BIN_PATH="/koolshare/bin/cloudflared"
BACKUP_PATH="${BIN_PATH}.bak"

# Get download URL from user input or use default
if [ -n "$cloudflared_download_url" ]; then
    DOWNLOAD_URL="$cloudflared_download_url"
else
    DOWNLOAD_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-armhf"
fi

# Clean old log
rm -rf $LOG_FILE

# Main update process
echo_date "开始更新 cloudflared..." >> $LOG_FILE

# Check available space
echo_date "检测 jffs 分区剩余空间..." >> $LOG_FILE
SPACE_AVAL=$(df | grep jffs | head -n 1 | awk '{print $4}')
if [ -z "$SPACE_AVAL" ] || [ "$SPACE_AVAL" -lt 40960 ]; then
    echo_date "当前 jffs 分区剩余空间不足 40MB，退出更新！" >> $LOG_FILE
    exit 1
fi
echo_date "剩余空间充足，继续更新..." >> $LOG_FILE

# Stop service if running
if [ "$cloudflared_enable" == "1" ]; then
    echo_date "停止 cloudflared 服务..." >> $LOG_FILE
    sh /koolshare/scripts/cloudflared.sh stop >/dev/null 2>&1
    sleep 1
fi

# Download new version
echo_date "下载最新版本的 cloudflared..." >> $LOG_FILE
curl -L -o "$BIN_PATH" "$DOWNLOAD_URL" 2>> $LOG_FILE

if [ $? -ne 0 ]; then
    echo_date "下载失败" >> $LOG_FILE
    exit 1
fi

# Set executable permission
chmod +x "$BIN_PATH"
if [ $? -ne 0 ]; then
    echo_date "设置可执行权限失败" >> $LOG_FILE
    exit 1
fi

# Verify the new binary
if "$BIN_PATH" -V >> $LOG_FILE 2>&1; then
    echo_date "更新成功！" >> $LOG_FILE
    
    # Restart service if it's running
    pid_ali=$(pidof cloudflared)
    if [ -n "$pid_ali" ] && [ "$cloudflared_enable" == "1" ]; then
        echo_date "重启 cloudflared 服务..." >> $LOG_FILE
        sh /koolshare/scripts/cloudflared.sh restart
    fi
else
    echo_date "新版本验证失败" >> $LOG_FILE
    exit 1
fi

echo BBABBBBC >> $LOG_FILE
exit 0