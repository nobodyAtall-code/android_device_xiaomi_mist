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

## Integration blockers — preserve evidence and order

1. **Boot chain:** inspect stock `init_boot.img`, `vendor_boot.img` ramdisk entries and bootconfig; verify selected vendor DTB and DTBO overlay, stock `vendor_dlkm` / `system_dlkm` modules and exact module load order. Source: [boot-chain report](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-lp-boot-chain-verified-2026-11-13.md). Do not substitute arbitrary stock images in Lineage packaging without AVB and slot analysis.
2. **Mounts and encryption:** reconstruct a device-specific first-stage fstab from the **complete** stock `vendor_a/etc/fstab.default` file, preserving actual block devices, fs options and F2FS wrapped-key metadata encryption. The [stock config report](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/generated/mist-stock-config.md) summarizes mountpoints/flags only: it is *not* a complete fstab and must not be copied verbatim. Review Xiaomi-specific `mi_ext`/overlay mounts separately.
3. **Dynamic groups/OTA:** independent Python/Go cross-check confirms eight populated logical images, but AOSP liblp/lpdump membership, group maxima, empty slot, snapshot and `mi_ext` OTA semantics remain unverified. Do not guess `BOARD_*_PARTITION_LIST` or dynamic group maxima.
4. **AVB/recovery:** inspect chained descriptors, vbmeta system, rollback, signing / development keys and recovery paths before enabling generated images.
5. **Vendor:** match stock VINTF declarations with real service ELF/init RC, audit framework/APEX vs stock library SONAMEs, resolve KeyMint service registration, RIL/IMS, audio, camera, power, sensors, fingerprint, graphics and Wi-Fi. Source: [ELF triage](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-elf-soname-triage-2026-11-13.md). Do not blindly publish every blob.
6. **SELinux:** derive actual file contexts and service/attribute mappings from stock + the chosen Lineage HAL implementation; do not silence denials with permissive domains.

## Build gate

The latest local `m -j2 nothing` **passed on 14 November 2026** after stock/platform sensors and vibrator install conflicts were fixed, and an earlier `m -j2 bootimage` produced a parseable image using the **stock prebuilt** kernel. Neither proves a complete system, runtime linker closure, VINTF/SELinux compatibility or bootability. Do not begin a multi-hour full build or flash before source-backed integration changes are reviewed.

Research scripts, Actions workflows and temporary archives belong **only** in [copilot_project](https://github.com/nobodyAtall-code/copilot_project); this production tree keeps only reviewed source and documentation. Work only on the existing `main` branch.
