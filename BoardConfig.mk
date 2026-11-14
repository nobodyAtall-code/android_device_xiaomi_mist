#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/mist

# Verified on the stock device (Android 16, OS3.0.304.0.WPUMIXM).
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := kryo300

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic

TARGET_BOARD_PLATFORM := parrot
# SM4450/parrot Qualcomm common-board integration; cross-checked against
# sm4450-development/device_xiaomi_sky (branch 16), not Sky-specific hardware.
BOARD_USES_QCOM_HARDWARE := true
TARGET_BOOTLOADER_BOARD_NAME := mist
TARGET_NO_BOOTLOADER := true

BOARD_BOOT_HEADER_VERSION := 4
BOARD_KERNEL_PAGESIZE := 4096
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

# Stock init_boot.img also uses Android boot header v4; stock init and
# vendor ramdisks use LZ4-legacy. Structural validation: research workflow
# 43266837030. This does not validate a repacked LineageOS boot chain.
BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)
BOARD_RAMDISK_USE_LZ4 := true

# Exact physical super partition size: stock fastboot and MD5-verified raw
# super.img agree (runs 43229081227 and 43265353383).
# This is NOT the per-slot qti_dynamic_partitions group maximum.
BOARD_SUPER_PARTITION_SIZE := 10200547328

# Observed physical partition sizes; these are not dynamic-group sizes.
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600

# Stock fstab.default provides EROFS entries for these dynamic partitions
# (with EXT4 fallback entries). Use stock-backed EROFS for initial images;
# this does not validate super/OTA partition groups or mounting at runtime.
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_USES_METADATA_PARTITION := true
TARGET_USERIMAGES_USE_F2FS := true

TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# Pending: lpdump group data, AVB chain, boot/vendor_boot ramdisks, VINTF,
# sepolicy, kernel packaging and exact OTA partition list.

# Exact stock kernel payload extracted from MD5-verified Android 16 boot.img.
# Temporary bring-up: not a verified LineageOS kernel build.
TARGET_PREBUILT_KERNEL := device/xiaomi/mist-kernel/kernel

# Exact SHA256-verified stock OS3.0.304.0.WPUMIXM vendor_boot image.
# Use untouched stock DTBs, 291 embedded modules, fstab and init rc
# instead of creating a nonfunctional empty custom vendor ramdisk.
# This is an initial bring-up baseline, not validated custom boot.
BOARD_PREBUILT_VENDOR_BOOTIMAGE := device/xiaomi/mist-kernel/vendor_boot.img

# Stock OS3.0.304.0.WPUMIXM DTBO, SHA256-verified.
# Use original 22-entry overlay table with stock vendor_boot DTBs.
# No custom overlay assembly or device boot compatibility claim.
BOARD_PREBUILT_DTBOIMAGE := device/xiaomi/mist-kernel/dtbo.img
