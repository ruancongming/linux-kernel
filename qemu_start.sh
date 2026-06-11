#!/bin/bash

# ============================================
# QEMU 内核启动脚本（带网络配置）
# ============================================

# 文件路径
KERNEL_IMAGE="$HOME/kernel/build-linux/arch/x86_64/boot/bzImage"
INITRD_IMAGE="$HOME/kernel/build-linux/initrd-busybox.img"

# 网络配置模式
# 可选值: "user" (用户模式NAT) 或 "tap" (桥接模式，需要额外配置)
NET_MODE="user"

# ===== 用户模式网络配置（默认，无需管理员权限）=====
if [ "$NET_MODE" = "user" ]; then
    # 用户模式网络参数
    # hostfwd: 将宿主机的 2222 端口转发到虚拟机的 22 端口（SSH）
    NET_ARGS="-netdev user,id=net0,hostfwd=tcp::2222-:22"
    NET_ARGS="$NET_ARGS -device e1000,netdev=net0"
fi

# ===== 桥接模式网络配置（虚拟机与宿主机同网段）=====
# 注意：需要先创建桥接网络，Windows 上配置较复杂，WSL 环境下不推荐
if [ "$NET_MODE" = "tap" ]; then
    echo "桥接模式需要额外配置，当前使用用户模式"
    NET_ARGS="-netdev user,id=net0 -device e1000,netdev=net0"
fi

# 内核启动参数（通过 init 脚本配置 IP，或者直接在这里传参）
# 注意：QEMU 的 -append 只能传递内核参数，不能直接配置 IP
# IP 配置仍然需要在 init 脚本中完成
CMDLINE="console=ttyS0 init=/init"

# 硬件配置
MEMORY="2G"
SMP="2"

# 检查文件
if [ ! -f "$KERNEL_IMAGE" ]; then
    echo "错误: 内核镜像 $KERNEL_IMAGE 不存在"
    echo "请先执行 make CC=gcc-12 -j\$(nproc) 编译内核"
    exit 1
fi

if [ ! -f "$INITRD_IMAGE" ]; then
    echo "错误: initrd 镜像 $INITRD_IMAGE 不存在"
    exit 1
fi

echo "=========================================="
echo "网络模式: $NET_MODE"
echo "内核: $KERNEL_IMAGE"
echo "退出方式: Ctrl+A 然后按 X"
echo "=========================================="

# 启动 QEMU
qemu-system-x86_64 \
    -kernel "$KERNEL_IMAGE" \
    -initrd "$INITRD_IMAGE" \
    -append "$CMDLINE" \
    $NET_ARGS \
    -m "$MEMORY" \
    -smp "$SMP" \
    -nographic