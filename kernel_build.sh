#!/bin/bash

# ============================================
# Linux 内核编译脚本
# ============================================

# 配置
KERNEL_SRC="$HOME/kernel/linux-6.6"          # 源码目录（纯净，Git 管理）
KERNEL_BUILD="$HOME/kernel/build-linux"  # 编译目录（临时文件，可随时删除）
CC="gcc-12"
JOBS=$(nproc)

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 检查内核源码目录是否存在
if [ ! -d "$KERNEL_SRC" ]; then
    echo -e "${RED}错误: 内核源码目录不存在: $KERNEL_SRC${NC}"
    exit 1
fi

# 创建编译目录（如果不存在）
if [ ! -d "$KERNEL_BUILD" ]; then
    echo -e "${YELLOW}创建编译目录: $KERNEL_BUILD${NC}"
    mkdir -p "$KERNEL_BUILD"
fi

# 检查是否需要配置 .config
if [ ! -f "$KERNEL_BUILD/.config" ]; then
    echo -e "${YELLOW}未找到 .config 文件，使用默认配置...${NC}"
    
    # 方法1：从源码目录复制已有配置（如果存在）
    if [ -f "$KERNEL_SRC/.config" ]; then
        echo -e "${YELLOW}从源码目录复制 .config...${NC}"
        cp "$KERNEL_SRC/.config" "$KERNEL_BUILD/.config"
    else
        # 方法2：在编译目录中生成默认配置
        echo -e "${YELLOW}生成默认配置 defconfig...${NC}"
        make -C "$KERNEL_SRC" O="$KERNEL_BUILD" defconfig
    fi
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}开始编译内核...${NC}"
echo -e "${GREEN}=========================================${NC}"
echo -e "源码目录: $KERNEL_SRC"
echo -e "编译目录: $KERNEL_BUILD"
echo -e "编译器: $CC"
echo -e "并行任务数: $JOBS"
echo ""

# 编译内核（使用 O= 指定编译目录）
make -C "$KERNEL_SRC" O="$KERNEL_BUILD" CC="$CC" -j"$JOBS"

# 检查编译结果
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=========================================${NC}"
    echo -e "${GREEN}✅ 内核编译成功！${NC}"
    echo -e "${GREEN}=========================================${NC}"
    echo ""
    echo "内核镜像位置: $KERNEL_BUILD/arch/x86/boot/bzImage"
    ls -lh "$KERNEL_BUILD/arch/x86/boot/bzImage"
else
    echo ""
    echo -e "${RED}=========================================${NC}"
    echo -e "${RED}❌ 内核编译失败！${NC}"
    echo -e "${RED}=========================================${NC}"
    exit 1
fi