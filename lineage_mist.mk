#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/mist

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

$(call inherit-product, $(DEVICE_PATH)/device.mk)
# The curated Mist stock HAL package list is required for this product.
# Fail product configuration if the vendor checkout is missing rather than
# silently producing an image without its declared proprietary services.
$(call inherit-product, vendor/xiaomi/mist/mist-vendor.mk)

PRODUCT_NAME := lineage_mist
PRODUCT_DEVICE := mist
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := 26081RA18G
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
