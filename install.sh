#!/bin/sh
source /koolshare/scripts/base.sh
eval $(dbus export cloudflared_)
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
MODEL=$(nvram get productid)
MODULE=cloudflared
DIR=$(cd $(dirname $0); pwd)
PKG_TYPE=armhf

platform_test(){
	local LINUX_VER=$(uname -r|awk -F"." '{print $1$2}')
	if [ -d "/koolshare" -a -f "/usr/bin/skipd" -a "${LINUX_VER}" -ge "41" ];then
        if [ "${ROT_ARCH}" == "aarch64" ] && [ "${PKG_ARCH}" == "hnd" ];then
			# RT-AX86U, RT-AX88U
			echo_date "内核：${KEL_VERS}，架构：${ROT_ARCH}，安装cloudflared_linux_${PKG_TYPE}！"
		elif [ "${ROT_ARCH}" == "armv7l" ] && [ "${PKG_ARCH}" == "hnd" ];then
			# RT-AX56U, XT8, TUF-AX3000_V2
			echo_date "内核：${KEL_VERS}，架构：${ROT_ARCH}，安装fancyss_hnd_${PKG_TYPE}！"
		fi
	else
		exit_install 1
	fi

    # Check available space
	echo_date 检测jffs分区剩余空间...
	SPACE_AVAL=$(df|grep jffs|head -n 1  | awk '{print $4}')
	if [ -z "$SPACE_AVAL" ] || [ "$SPACE_AVAL" -lt 1024 ];then
		echo_date 当前jffs分区剩余空间不足 1MB，退出安装！
		exit_install 1
	fi
	echo_date 剩余空间充足，继续安装！
}

platform_test

if [ "$cloudflared_enable" == "1" ];then
	echo_date 先关闭cloudflared，保证文件更新成功!
	[ -f "/koolshare/scripts/cloudflared.sh" ] && sh /koolshare/scripts/cloudflared.sh stop >/dev/null 2>&1 &
fi

# Create necessary directories
mkdir -p /koolshare/bin
mkdir -p /koolshare/scripts
mkdir -p /koolshare/webs
mkdir -p /koolshare/res

# Copy configuration files and scripts
cd /tmp
cp -rf /tmp/cloudflared/scripts/* /koolshare/scripts/
cp -rf /tmp/cloudflared/webs/* /koolshare/webs/
cp -rf /tmp/cloudflared/res/* /koolshare/res/
cp -rf /tmp/cloudflared/uninstall.sh /koolshare/scripts/uninstall_cloudflared.sh

# Set permissions
chmod 755 /koolshare/scripts/cloudflared*
chmod 755 /koolshare/res/cloudflared*
chmod 755 /koolshare/scripts/uninstall_cloudflared.sh
ln -sf /koolshare/scripts/cloudflared.sh /koolshare/init.d/S99cloudflared.sh

# Notify user to download cloudflared binary
echo_date "请使用更新功能下载 cloudflared 二进制文件！"

dbus set softcenter_module_${MODULE}_name="${MODULE}"
dbus set softcenter_module_${MODULE}_title="cloudflared"
dbus set softcenter_module_${MODULE}_description="Cloudflare Tunnel client"
dbus set softcenter_module_${MODULE}_version="$(cat $DIR/version)"
dbus set cloudflared_version="$(cat $DIR/version)"
dbus set softcenter_module_${MODULE}_install="1"

rm -rf /tmp/cloudflared* >/dev/null 2>&1

logger "[软件中心]: 完成 cloudflared 安装"
exit