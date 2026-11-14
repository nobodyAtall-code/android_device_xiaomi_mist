# Redmi Note 17 5G (mist) — LineageOS 23.2 device integration

Target: Xiaomi Global `OS3.0.304.0.WPUMIXM` (Android 16), Qualcomm SM4450 (`parrot`). This repository is **not boot-ready**.

## Kernel strategy

Use the already SHA256-verified stock Mist prebuilt `device/xiaomi/mist-kernel/kernel` temporarily. Compiling `android_kernel_xiaomi_mist` is **deferred**, because matching Xiaomi MIHW dependencies are unavailable. Do not replace the prebuilt, assume module ABI compatibility, or flash anything based on the successful `m nothing`/bootimage target alone.

## Source-backed inventory (13 November 2026)

- `BoardConfig.mk`: stock physical boot/init_boot/vendor_boot/dtbo/recovery/super sizes, header v4, stock kernel prebuilt, initial file system types.
- `device.mk`: virtual A/B and dynamic partition inheritance; full OTA group definition **not yet established**.
- `lineage_mist.mk`: basic Lineage product and vendor inheritance.
- `proprietary-files.txt`: **42 verified paths matching all 42 active proprietary source files referenced by vendor `Android.bp`** (as of 14 November 2026). This closes the extraction-manifest drift for currently installed modules; it is **not** the complete stock vendor payload or runtime dependency closure.
- No completed device init, fstab, recovery/vendorramdisk packaging, AVB chain, VINTF compatibility matrix, SEPolicy or full vendor closure.

## Shared SM4450 platform reference (14 November 2026)

Compared with [sm4450-development/device_xiaomi_sky, branch 16](https://github.com/sm4450-development/device_xiaomi_sky/tree/16) and [vendor_xiaomi_sky, branch 16](https://github.com/sm4450-development/vendor_xiaomi_sky/tree/16), using original mist Android 16 stock init, service and VINTF evidence.

**Adopted:** common Qualcomm SM4450/parrot board feature `BOARD_USES_QCOM_HARDWARE := true` in `BoardConfig.mk`.

**Not portable from Sky:** its Android 13-origin kernel 5.10, smaller 6.98 GB super, EXT4 partition layout, camera sensor calibration, HIDL audio 7.0, fingerprint daemon, ravelin device SKU and SELinux/AVB assumptions. Mist's original stock is Android 16, 6.6.118 module family, ~10.20 GB super and EROFS logical partitions.

[Full 12-subsystem source comparison and actual Mist stock service paths](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-vs-sky-sm4450-integration-2026-11-14.md). Do not treat the cross-device comparison as implemented RIL/audio/fingerprint, VINTF, SELinux or boot-complete.

## Integration blockers — preserve evidence and order

1. **Boot chain:** inspect stock `init_boot.img`, `vendor_boot.img` ramdisk entries and bootconfig; verify selected vendor DTB and DTBO overlay, stock `vendor_dlkm` / `system_dlkm` modules and exact module load order. Source: [boot-chain report](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-lp-boot-chain-verified-2026-11-13.md). Do not substitute arbitrary stock images in Lineage packaging without AVB and slot analysis.
2. **Mounts and encryption:** reconstruct a device-specific first-stage fstab from the **complete** stock `vendor_a/etc/fstab.default` file, preserving actual block devices, fs options and F2FS wrapped-key metadata encryption. The [stock config report](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/generated/mist-stock-config.md) summarizes mountpoints/flags only: it is *not* a complete fstab and must not be copied verbatim. Review Xiaomi-specific `mi_ext`/overlay mounts separately.
3. **Dynamic groups/OTA:** [full verified Mist stock layout](research/STOCK_PARTITION_LAYOUT_2026-11-14.md) establishes all eight exact logical image sizes, both 10,190,061,568-byte per-slot maxima, A-group 6,533,066,752-byte allocation, empty B group and three matching liblp metadata copies, independently verified in Go. Remaining uncertainty is **how to implement Lineage product/OTA ownership of `mi_ext`, snapshot/COW budgets, AVB and first-stage mounting**—not what the original partition metadata says. Do not enable an arbitrary `BOARD_*_PARTITION_LIST`.
4. **AVB/recovery:** inspect chained descriptors, vbmeta system, rollback, signing / development keys and recovery paths before enabling generated images.
5. **Vendor:** match stock VINTF declarations with real service ELF/init RC, audit framework/APEX vs stock library SONAMEs, resolve KeyMint service registration, RIL/IMS, audio, camera, power, sensors, fingerprint, graphics and Wi-Fi. Source: [ELF triage](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-elf-soname-triage-2026-11-13.md). Do not blindly publish every blob.
6. **SELinux:** derive actual file contexts and service/attribute mappings from stock + the chosen Lineage HAL implementation; do not silence denials with permissive domains.

## Build gate

The latest local `m -j2 nothing` **passed on 14 November 2026** after stock/platform sensors and vibrator install conflicts were fixed, and an earlier `m -j2 bootimage` produced a parseable image using the **stock prebuilt** kernel. Neither proves a complete system, runtime linker closure, VINTF/SELinux compatibility or bootability. Do not begin a multi-hour full build or flash before source-backed integration changes are reviewed.

Research scripts, Actions workflows and temporary archives belong **only** in [copilot_project](https://github.com/nobodyAtall-code/copilot_project); this production tree keeps only reviewed source and documentation. Work only on the existing `main` branch.

## Verified full-stock evidence (14 November 2026)

The [complete stock firmware research](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-full-stock-firmware-findings-2026-11-14.md) passed on [run 43579076486](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486). All eight EROFS partitions were mounted and inspected: 3,911 ELF records, 460 partition modules, 136 VINTF XML, 269 init RC and 15 image records. Stock SELinux file labels for Camera/KeyMint/QSEE match their actual vendor executable paths; **SELinux source compilation remains outstanding**. Four stock `.ko` vermagic families prevent treating all modules as interchangeable without ABI/load-order verification. The current device source is not boot-complete and its first-stage fstab remains uninstalled.


## Modern Xiaomi mi_ext source comparison (14 November 2026)

A code-level comparison of an unofficial LineageOS 24.0 Xiaomi 18 Pro Max (`madrid`) tree, official LineageOS 24.0 SM8450 common BoardConfig and a Xiaomi 17 Ultra bring-up shows **no universal mi_ext policy**. Madrid's unbooted offline super-image recipe explicitly includes stock `mi_ext`, even though it is not a Lineage-generated BoardConfig image. Because the earlier seven-partition minus-mi_ext arithmetic was not a working partition-preservation/OTA plan, the `MIST_ENABLE_OFFLINE_SUPER_LAYOUT` prototype was **removed** from BoardConfig in commit `34a0e05`. See [source comparisons and limitations](research/MIST_MI_EXT_LINEAGE_COMPARISON_2026-11-14.md). Normal build behavior remains as before, and no A/B OTA layout is yet approved.

## Current clean seven-partition BoardConfig (14 November 2026)

Commit [dac744c](https://github.com/nobodyAtall-code/android_device_xiaomi_mist/commit/dac744ccc66b7cf66745c63f7e24aa274a886cbf) **actively configures** `BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions`, source-verified per-slot group ceiling **10,190,061,568 bytes**, and `odm product system system_dlkm system_ext vendor vendor_dlkm`. **No `mi_ext` image is generated or listed.** This supersedes the older, withdrawn 9,081,106,432-byte opt-in prototype. `device.mk` remains a virtual-A/B inheritance baseline; no final `AB_OTA_PARTITIONS` list, generated payload/target metadata, snapshot budget, AVB re-signing or custom vendor_boot/fstab migration is yet validated.

Stock `mi_ext_a` has 150 indexed entries dominated by apps, regional/operator settings and telephony RROs; no native `.so`, `.ko` or modem `.mbn` paths were inventoried. These path findings are not proof that each XML/APK may be deleted without examining its content. Stock reused `vendor_boot` still contains first-stage mi_ext mounts and Xiaomi overlays; do not conflate clean generated partition list with complete removal of old boot references. See [Mist-specific original partition inventory/AOSP OTA review](research/MIST_MI_EXT_ACTUAL_CONTENT_AND_AOSP_OTA_2026-11-14.md).

A standalone offline source/metadata verifier is kept in [copilot_project/scripts/validate_mist_lineage_super_layout.py](https://github.com/nobodyAtall-code/copilot_project/blob/main/scripts/validate_mist_lineage_super_layout.py). It accepts the already-produced `full-super-metadata.json` and this device tree, **without redownloading the ROM**. Passing this check is only evidence of BoardConfig values, not proof of successful image generation or OTA.
