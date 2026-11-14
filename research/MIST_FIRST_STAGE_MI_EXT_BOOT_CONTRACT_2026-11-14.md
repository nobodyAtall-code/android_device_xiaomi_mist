# Mist clean Lineage first-stage mount contract — verified evidence (2026-11-14)

## Exact source inputs

- Original firmware: `OS3.0.304.0.WPUMIXM`. Complete stock research run [43579076486](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/job/132399705358) succeeded. Original [22-report artifact](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/artifacts/14107138565) contains `full-super-metadata.json` and `full-stock-ramdisks.json`.
- Current `BoardConfig.mk` declares physical `super` size **10,200,547,328** and per-slot `qti_dynamic_partitions` group maximum **10,190,061,568**. Those match the original metadata, including 3 matching metadata slots. The seven generated partitions are `system system_ext product vendor odm vendor_dlkm system_dlkm`; no Lineage `mi_ext.img`.
- From the **actual stock vendor_boot ramdisk**, `first_stage_ramdisk/fstab.default` has **54 parsed mount entries**; 24 lines reference `mi_ext`, including the initial `mi_ext` EROFS/EXT4 mounts, bind and 22 overlay mount rules. `first_stage_ramdisk/fstab.emmc` has **23 mount entries**, with **zero** `mi_ext` references and no overlay entries. These are **two stock alternatives**: their presence alone does not establish which is selected by kernel bootconfig/init on the actual UFS model.
- Stock first-stage fstab is not the same as `vendor_a/etc/fstab.default` or the staged `rootdir/etc/fstab.mist`. The stock ramdisk also supplies `modules.load` and `modules.load.recovery`, and cannot be discarded without preserving its hardware bring-up requirements.

## What the actual device tree does

- `device.mk` currently says `PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false`.
- `BoardConfig.mk` sets `BOARD_PREBUILT_VENDOR_BOOTIMAGE := device/xiaomi/mist-kernel/vendor_boot.img`.
- The edited `rootdir/etc/fstab.mist` has **no** `mi_ext` entries and contains each of the seven first-stage logical mounts in EROFS/EXT4 form. **But it is staged, not installed in stock vendor_boot.** Therefore the clean super BoardConfig **does not** by itself remove original `mi_ext` fstab and overlays from the image to be booted.

## Next source-safe gating action

The read-only [copilot checker](https://github.com/nobodyAtall-code/copilot_project/blob/main/scripts/check_mist_first_stage_mount_contract.py) checks the original saved `full-stock-ramdisks.json`, this device tree and the staged fstab without fetching firmware or modifying boot images. The checker records which stock fstab files carry `mi_ext`, confirms staged mount list and flags that boot still uses a stock prebuilt image.

For local verification inside your Linux checkout, first extract the **existing** artifact JSON from its downloaded archive, then:

```bash
cd ~/android/lineage
python3 /path/to/check_mist_first_stage_mount_contract.py \
  --device-tree device/xiaomi/mist \
  --stock-ramdisk-report /path/to/full-stock-ramdisks.json \
  --out /tmp/mist-first-stage-contract.json
```

The checker was added but **not executed against a live checkout** as part of the remote GitHub commit. Do not label it passed without a run.

## Hard decisions before installing a custom vendor_boot

1. Determine the first-stage fstab selection using verified bootconfig/init and `androidboot.fstab_suffix`/device-specific logic. Do not assume fstab.emmc is used because the device has UFS.
2. Review stock `vendor/etc/init` references and overlays against the clean Lineage target; keep necessary hardware/firmware mounts and encryption intact.
3. Build a **complete** vendor_boot ramdisk retaining exact stock 291 modules and critical first-stage init needs, while replacing only verified fstab references.
4. Validate signing/AVB, SELinux, VINTF and the target OTA metadata before flashing. Until those are proven, retain the verified stock prebuilt fallback and do not enable an incomplete vendor ramdisk.

This report is a compatibility analysis, not a claim of successful device boot.

## Stock bootconfig extraction added — targeted, no firmware re-download

The existing [`inspect_mist_vendor_boot_bootconfig.py`](https://github.com/nobodyAtall-code/copilot_project/blob/main/scripts/inspect_mist_vendor_boot_bootconfig.py) reads only the **204-byte** vendor_boot v4 bootconfig at the offset identified by the original stock boot parser, under a strict built-in original image SHA256 check:
`f0d692792cacff3026876edbd68aed5d23be7e1acef3e6028ccd5fff21ae5acb`.
The original ramdisk has one **10,992,661-byte legacy-LZ4 fragment** (header v4, page size 4096), alongside the original 11 vendor DTB structures. No image rewrite is performed.

On the user's existing Linux workspace, after the script is synced:

```bash
cd ~/android/lineage
python3 /path/to/copilot_project/scripts/inspect_mist_vendor_boot_bootconfig.py \
  --vendor-boot device/xiaomi/mist-kernel/vendor_boot.img \
  --output /tmp/mist-vendor-boot-bootconfig.json
```

The script emits bootconfig keys that could affect `fstab_suffix`, hardware and boot-device selection, but does **not** claim a selected fstab merely because a key is present or absent. Additional runtime/kernel command-line and `fs_mgr` selection evidence remains necessary. An unverified image is rejected unless an explicit development override is used.

**Source-backed inference:** `fstab.emmc` contains only EXT4 entries for the seven logical partitions, whereas verified stock `super` images are all EROFS. Therefore a successfully booted stock EROFS system cannot normally have mounted those partitions using the EXT4-only alternative unmodified. `fstab.default` is the more plausible actual stock path, but this is an inference rather than direct evidence of the bootloader's selector.

No custom vendor_boot was constructed or made bootable by this change. Keep stock prebuilt as fallback.

## Verified local bootconfig output (14 November)

The device owner ran the SHA-guarded reader against their existing stock `vendor_boot.img` in `~/android/lineage`. **SHA256 exact match:** `f0d692792cacff3026876edbd68aed5d23be7e1acef3e6028ccd5fff21ae5acb`; `bootconfig_bytes=204`, `bootconfig_offset=15392768`, v4 header, single legacy-LZ4 ramdisk fragment 10,992,661 bytes. Bootconfig explicitly contains `androidboot.hardware=qcom` and **no `androidboot.fstab_suffix`**. The checker correctly reported `fstab_selected_confirmed=false`. Do not infer the fstab selected merely from absent suffix; inspect runtime `ro.boot.*`, first-stage init and bootloader/kernel cmdline when available.

Next safe live device query if the device is running and ADB is authorized: `adb shell getprop ro.boot.fstab_suffix`, `adb shell getprop ro.boot.hardware`, `adb shell cat /proc/cmdline`, `adb shell cat /proc/bootconfig` and `adb shell mount`. These are read-only and distinguish actual on-device inputs from the static bootconfig. Do **not** edit vendor_boot or enable flashing from this evidence.
