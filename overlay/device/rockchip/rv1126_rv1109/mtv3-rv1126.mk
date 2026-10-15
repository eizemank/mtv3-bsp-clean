#!/bin/bash

# Target chip
export RK_CHIP=RV1126
# Target arch
export RK_ARCH=arm
# Uboot defconfig
export RK_UBOOT_DEFCONFIG=rv1126_mtv3
# Loader update spl from Uboot
export RK_LOADER_UPDATE_SPL=true
# Uboot image format type: fit(flattened image tree)
export RK_UBOOT_FORMAT_TYPE=fit
# Kernel defconfig
export RK_KERNEL_DEFCONFIG=rv1126_mtv3_defconfig
# Kernel defconfig fragment
export RK_KERNEL_DEFCONFIG_FRAGMENT=
# EMMC EVB BOARD Kernel dts
export RK_KERNEL_DTS=rv1126-mtv3
# Logic/npu/vepu merge emmc board kernel dts
#export RK_KERNEL_DTS=rv1126-ai-cam-ddr3-v1
# NPU 800m+ logic separate from npu/vepu emmc board kernel dts
#export RK_KERNEL_DTS=rv1126-ai-cam-plus
# boot image type
export RK_BOOT_IMG=zboot.img
# kernel image path
export RK_KERNEL_IMG=kernel/arch/arm/boot/zImage
# parameter for GPT table
export RK_PARAMETER=parameter-mtv3.txt
# Buildroot config
export RK_CFG_BUILDROOT=rockchip_rv1126_rv1109_mtv3
# Recovery config
export RK_CFG_RECOVERY=
# Recovery image format type: fit(flattened image tree)
export RK_RECOVERY_FIT_ITS=boot4recovery.its
# ramboot config
export RK_CFG_RAMBOOT=
# Pcba config
export RK_CFG_PCBA=
# Build jobs
export RK_JOBS=12
# target chip
export RK_TARGET_PRODUCT=rv1126_rv1109
# Set rootfs type, including ext2 ext4 squashfs
export RK_ROOTFS_TYPE=ext4
# rootfs image path
export RK_ROOTFS_IMG=rockdev/rootfs.${RK_ROOTFS_TYPE}
# Set ramboot image type
export RK_RAMBOOT_TYPE=
# Set oem partition type, including ext2 squashfs
# ext4: kernel CONFIG_EXT4_USE_FOR_EXT2=y, so the /etc/fstab ext2 entry mounts ext4 fine
export RK_OEM_FS_TYPE=ext4
# OEM build on buildroot
export RK_OEM_BUILDIN_BUILDROOT=YES
# Set userdata partition type, including ext2, fat
export RK_USERDATA_FS_TYPE=ext2
#OEM config
export RK_OEM_DIR=oem_mtv3
# Mount /oem and /userdata by direct device node (this board's u-boot does not
# populate /dev/block/by-name/, so fstab by-name mounts are skipped -> empty /oem).
# Layout is fixed by parameter-mtv3.txt: p7=oem, p8=userdata.
export RK_OEM_NODE=/dev/mmcblk0p7
export RK_USERDATA_NODE=/dev/mmcblk0p8
#userdata config
export RK_USERDATA_DIR=userdata_normal
#misc image43
export RK_MISC=wipe_all-misc.img
#choose enable distro module
export RK_DISTRO_MODULE=
# Define package-file for update.img
export RK_PACKAGE_FILE=rv1126_rv1109-package-file-uvc
# update spl
export RK_LOADER_UPDATE_SPL=true
# PRODUCT MODEL
export RK_PRODUCT_MODEL=CAM_CRV1126S2U
