# Mist verified stock partition layout — OS3.0.304.0.WPUMIXM

Source: [complete stock firmware workflow 43579076486](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/job/132399705358), [22-file original metadata artifact](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/artifacts/14107138565) and [curated technical findings](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-full-stock-firmware-findings-2026-11-14.md).

## Confirmed liblp layout

- Physical `super`: **10,200,547,328 bytes**.
- `qti_dynamic_partitions_a` group maximum: **10,190,061,568 bytes**; allocated **6,533,066,752** bytes.
- `qti_dynamic_partitions_b` group maximum: **10,190,061,568 bytes**; allocated **0 bytes**.
- `default` group: 0 bytes. Three checked metadata slots, all primary and backup copies identical. Original Python and pinned independent Go group/size comparisons passed.
- **Do not sum the A and B group maxima into a single simultaneous image budget.** They are separate slot group limits.

| Logical partition | Stock size (bytes) | Verified filesystem |
| --- | ---: | --- |
| `odm_a` | 17,195,008 | EROFS |
| `product_a` | 3,339,325,440 | EROFS |
| `system_a` | 719,495,168 | EROFS |
| `system_dlkm_a` | 15,286,272 | EROFS |
| `system_ext_a` | 637,571,072 | EROFS |
| `vendor_a` | 669,220,864 | EROFS |
| `vendor_dlkm_a` | 26,017,792 | EROFS |
| `mi_ext_a` | 1,108,955,136 | EROFS |

## First-stage mount and OTA impact

The stock `boot/stock_snapshot/first_stage_ramdisk/fstab.default` includes all eight slot-select logical mounts, including `mi_ext` at `/mnt/vendor/mi_ext`, bound at `/mi_ext`. Stock first-stage mount treats `mi_ext` as `nofail`; proprietary Xiaomi product/system overlays reference its contents. This is *not* equivalent to a standard LineageOS image partition and cannot simply be dropped from a stock OTA-layout proof. Determine whether an unofficial Lineage build should preserve stock `mi_ext` unchanged, handle it as a firmware-required partition, or explicitly remove the dependency under a separately validated upgrade path.

The stock `system` AVB keys, `vbmeta` versus `vbmeta_system` groups, `metadata` and F2FS wrapped-key `userdata` mounts must remain coordinated with the boot chain. Current `rootdir/etc/fstab.mist` is a **staged comparison file, not installed**. The original stock `vendor_boot`, `dtbo`, and kernel remain the controlled bring-up fallback.

## Production configuration gate

`BoardConfig.mk` already contains the verified physical `BOARD_SUPER_PARTITION_SIZE`. However, a complete `BOARD_SUPER_PARTITION_GROUPS`, per-group size, `BOARD_*_PARTITION_LIST`, OTA payload partition list, product/build ownership for `mi_ext`, snapshot/COW budget, AVB signing semantics and virtual A/B payload integration must be **designed together**. Do not copy stock group maximum blindly into a Lineage dynamic group and do not add an image recipe for `mi_ext` without a packaging/upgrade plan.

Verified source images are not evidence of Lineage-generated images, successful first-stage mount, AVB validity, or OTA install. Preserve the exact stock metadata above and test only after a reviewed product decision.

## Other stock evidence from the same run

- 3,911 ELF records; 460 `.ko` modules: 192 `system_dlkm`, 268 `vendor_dlkm`. Four `vermagic` families; seven vendor modules show `6.6.98`.
- 136 VINTF XML, 269 init RC; five Camera/KeyMint/QSEE stock executable labels match real files in both original firmware and curated vendor tree.
- SELinux policy compilation and neverallows, linker namespace resolution, source-built module ABI, VINTF compatibility, custom OTA and device boot are **not verified**.

This file is an engineering source-of-truth record; it does not enable new product package installations or a firmware flash.

## Staged LineageOS 23.2 offline-only BoardConfig implementation (14 November)

Commit `5573208` added `MIST_ENABLE_OFFLINE_SUPER_LAYOUT=true` opt-in to `BoardConfig.mk`, limited to `userdebug` research builds. That path sets `BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions`, includes the seven normally generated Lineage partitions (`odm product system system_dlkm system_ext vendor vendor_dlkm`), and caps their *combined size* at **9,081,106,432 bytes**. This number is the original per-slot super group maximum minus all **1,108,955,136** bytes of original `mi_ext_a`; it is a **conservative experimental budget**, not the original stock group maximum.

**Default normal builds remain unchanged.** This experiment does not create, preserve or migrate `mi_ext`, does not declare a working A/B OTA payload list, does not validate slot B partition layout, nor modify AVB/first-stage mount. The reserved budget alone cannot preserve `mi_ext` across slot switching. Do not flash, OTA or represent the prototype as final `BoardConfig` integration. Use only to test future build-system layout closure, after confirming no duplicate definitions from platform configuration.

## Correction after comparing actual contemporary Xiaomi LineageOS trees

The former opt-in `MIST_ENABLE_OFFLINE_SUPER_LAYOUT` research block was **withdrawn** in commit `34a0e05`: it was an untested assumption that a budget subtraction was an adequate preservation strategy. It was never active by default. Current [source-backed Xiaomi mi_ext comparison](MIST_MI_EXT_LINEAGE_COMPARISON_2026-11-14.md) finds that a newer unofficial LineageOS 24.0 Xiaomi `madrid` tree explicitly packs original stock `mi_ext` inside offline `super` despite omitting it from its BoardConfig generated partition list. Official LineageOS SM8450 common BoardConfig omits `mi_ext` from its generated list, but there is no proof that is transferable to Mist's stock boot/overlay and OTA layout. The previously documented offline experiment is historical, not an active configuration or recommendation.
