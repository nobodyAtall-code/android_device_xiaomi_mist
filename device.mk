#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/mist

# Virtual A/B is present on the stock device. Additional OTA, init, kernel
# and HAL configuration must be sourced from mist firmware before bring-up.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/launch_with_vendor_ramdisk.mk)
