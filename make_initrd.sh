#!/bin/bash

# ============================================
# initrd 打包脚本
# ============================================

# 配置路径
INITRD_SOURCE="$HOME/kernel/initrd"          # initrd 源文件目录
INITRD_TARGET="$HOME/kernel/build-linux/initrd-busybox.img"  # 输出的 initrd 镜像

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查源目录是否存在
if [ ! -d "$INITRD_SOURCE" ]; then
    echo -e "${RED}错误: 源目录不存在: $INITRD_SOURCE${NC}"
    echo "请先创建目录并准备好 init 脚本"
    exit 1
fi

# 检查 init 脚本是否存在
if [ ! -f "$INITRD_SOURCE/init" ]; then
    echo -e "${RED}错误: init 脚本不存在: $INITRD_SOURCE/init${NC}"
    exit 1
fi

# 检查 busybox 是否存在
if [ ! -f "$INITRD_SOURCE/bin/busybox" ]; then
    echo -e "${YELLOW}警告: busybox 不存在，正在复制...${NC}"
    if [ -f "/usr/bin/busybox" ]; then
        cp /usr/bin/busybox "$INITRD_SOURCE/bin/"
    else
        echo -e "${RED}错误: 找不到 busybox，请先安装: sudo apt install busybox-static${NC}"
        exit 1
    fi
fi

# 进入源目录
cd "$INITRD_SOURCE" || exit 1

# 如果目标文件已存在，先删除
if [ -f "$INITRD_TARGET" ]; then
    echo -e "${YELLOW}删除旧的 initrd 镜像: $INITRD_TARGET${NC}"
    rm -f "$INITRD_TARGET"
fi

# 打包 initrd
echo -e "${GREEN}正在打包 initrd...${NC}"
find . | cpio -o -H newc 2>/dev/null | gzip > "$INITRD_TARGET"

# 检查打包是否成功
if [ -f "$INITRD_TARGET" ]; then
    FILE_SIZE=$(ls -lh "$INITRD_TARGET" | awk '{print $5}')
    echo -e "${GREEN}✅ initrd 打包成功!${NC}"
    echo -e "   输出路径: $INITRD_TARGET"
    echo -e "   文件大小: $FILE_SIZE"
else
    echo -e "${RED}❌ initrd 打包失败!${NC}"
    exit 1
fi