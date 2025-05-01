#!/bin/sh
eval `dbus export cloudflared_`
source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODULE=cloudflared

# Stop service if running
echo_date "停止 cloudflared 服务..."
/koolshare/scripts/cloudflared.sh stop >/dev/null 2>&1

# Remove symbolic link
echo_date "移除启动链接..."
rm -f /koolshare/init.d/S99cloudflared.sh

# Remove scripts and web interface files
echo_date "移除脚本和网页文件..."
rm -f /koolshare/scripts/cloudflared*
rm -f /koolshare/webs/Module_cloudflared.asp

# Remove resources
echo_date "移除资源文件..."
rm -f /koolshare/res/cloudflared*
rm -f /koolshare/res/icon-cloudflared.png

# Remove binary
echo_date "移除二进制文件..."
rm -f /koolshare/bin/cloudflared

# Clean temporary files
echo_date "清理临时文件..."
rm -fr /tmp/cloudflared* >/dev/null 2>&1
rm -fr /tmp/upload/cloudflared* >/dev/null 2>&1

# Remove all dbus settings
echo_date "清理配置信息..."
values=`dbus list cloudflared | cut -d "=" -f 1`
for value in $values
do
  dbus remove $value
done

# Remove module from softcenter
dbus remove softcenter_module_${MODULE}_install

echo_date "cloudflared 卸载完成！"
logger "[软件中心]: 完成 cloudflared 卸载"

# Remove uninstall script itself
rm -f /koolshare/scripts/uninstall_cloudflared.sh
