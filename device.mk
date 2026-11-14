#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/mist

# Stock Mist uses dynamic logical partitions in physical super.
# BoardConfig.mk now declares seven standard Lineage-generated partitions,
# explicitly excluding stock Xiaomi mi_ext. This is a build-image layout,
# NOT proof that target-slot OTA metadata drops mi_ext or that first-stage
# stock vendor_boot (which still references mi_ext) will work unchanged.
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Virtual A/B is present on the stock device. Additional OTA, init, kernel
# and HAL configuration must be sourced from mist firmware before bring-up.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)

# Preserve verified stock vendor_boot during initial bring-up.
# Do not rebuild an incomplete vendor ramdisk from staged snapshots.
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false


# Core device capability declarations backed by curated Bluetooth and radio
# service sources in vendor/xiaomi/mist. These are framework feature XMLs,
# not HAL implementations. Do not advertise unverified camera/biometric/NFC.
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.bluetooth_le.xml \
    frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/android.hardware.telephony.gsm.xml
