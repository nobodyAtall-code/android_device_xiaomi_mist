#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/mist

# Stock mist uses dynamic logical partitions in physical super.
# Exact group/mi_ext OTA composition remains an independent engineering gate.
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Virtual A/B is present on the stock device. Additional OTA, init, kernel
# and HAL configuration must be sourced from mist firmware before bring-up.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
