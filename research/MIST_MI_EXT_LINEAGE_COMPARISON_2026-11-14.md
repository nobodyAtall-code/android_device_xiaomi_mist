# Mist mi_ext compared with actual Xiaomi LineageOS trees — 14 November 2026

## Question

Does modern Xiaomi LineageOS ignore `mi_ext`, add it to normal generated dynamic partitions, or preserve the existing image? **There is no single universal answer**, and the exact product/stock partition assumptions matter. These examples were checked in their source files, not merely copied from generic Android references.

## Case 1 — Xiaomi 18 Pro Max (madrid), unofficial LineageOS 24.0, Android 17

Source: [IronShing/android_device_xiaomi_madrid](https://github.com/IronShing/android_device_xiaomi_madrid/tree/lineage-24.0). Its [BoardConfig.mk](https://github.com/IronShing/android_device_xiaomi_madrid/blob/lineage-24.0/BoardConfig.mk) declares `qti_dynamic_partitions` for the seven ordinary Lineage partitions `system system_ext product vendor vendor_dlkm system_dlkm odm`. It does **not** list `mi_ext` among generated Lineage partition images or in its `AB_OTA_PARTITIONS` subset.

Crucially, the repo's [scripts/build_super.sh](https://github.com/IronShing/android_device_xiaomi_madrid/blob/lineage-24.0/scripts/build_super.sh) **explicitly preserves the stock `mi_ext_a.img`** alongside stock `vendor`, `odm`, both DLKM images and `mi_product` while combining new Lineage `system`, `system_ext` and `product` into an offline rebuilt `super`. It creates slot-A entries with original images and zero-size slot-B entries using `lpmake` and virtual A/B metadata. Thus **absence of mi_ext in BoardConfig's generated partition list does not mean its partition is deleted from the final super**.

**Evidence quality:** This repo explicitly labels itself **early bring-up, not yet booted**, with only selected userspace images built. Its offline super repacking method is a helpful strategy reference, **not** a validated A/B OTA or reliable device boot reference. Do not copy Madrid's partition numbers, `lpmake` options, stock image set or unsigned-flash assumptions onto Mist without Mist-specific checks.

## Case 2 — official LineageOS 24.0 Xiaomi SM8450 common tree

Source: [LineageOS/android_device_xiaomi_sm8450-common BoardConfigCommon.mk](https://github.com/LineageOS/android_device_xiaomi_sm8450-common/blob/lineage-24.0/BoardConfigCommon.mk).

Its source declares `BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions` and a normal six-image `BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := odm product system system_ext vendor vendor_dlkm`. The `AB_OTA_PARTITIONS` list includes ordinary boot/Android/vendor images but not `mi_ext`. This shows **an official modern Lineage-managed group can omit mi_ext**, but by itself does **not establish** that the exact SM8450 stock firmware has the same mi_ext partition/layout as Mist, or that LineageOS preserves an existing mi_ext in an OTA. Never transfer those group sizes or assume this proves mi_ext deletion for Mist.

## Case 3 — Xiaomi 17 Ultra / nezha development documentation (not LineageOS official)

Source: [mweinbach/lineage-os-xiaomi17u](https://github.com/mweinbach/lineage-os-xiaomi17u), including [work history](https://github.com/mweinbach/lineage-os-xiaomi17u/blob/main/docs/workspace-status-history-20260905.md) and [boot contract](https://github.com/mweinbach/lineage-os-xiaomi17u/blob/main/docs/boot-contract.md). This project documents original stock `mi_ext` in first-stage fstab and image producers for a **custom Evolution/Lineage-based workflow**. It treats `mi_ext` as an explicit image/packaging dependency and reports selected component validations. This is **not** evidence of a complete official LineageOS OTA/boot result, nor a source of transplantable partition limits.

## Mist: what our own original firmware actually establishes

From independently verified [Mist complete stock research](https://github.com/nobodyAtall-code/copilot_project/blob/main/research/mist-full-stock-firmware-findings-2026-11-14.md):

- Eight active original EROFS partitions in `super`, including `mi_ext_a` **1,108,955,136 bytes**.
- Per-slot group max `10,190,061,568` bytes; A allocated `6,533,066,752` bytes; B entries presently unallocated.
- The **stock first-stage fstab** explicitly mounts `mi_ext` at `/mnt/vendor/mi_ext` with `nofail`, binds it to `/mi_ext`, and specifies numerous overlays onto `/product`, `/system`, and `/system_ext`. Whether those overlays should survive a custom Lineage userspace requires file-level review.
- Stock `vbmeta` descriptor analysis contains metadata for the original system/vendor images, but authentic AVB re-signing and runtime trust need separate checks.

## Correction to the earlier Mist assumption

**Withdrawn:** the userdebug-only BoardConfig block `MIST_ENABLE_OFFLINE_SUPER_LAYOUT` that reserved original `mi_ext` bytes by subtracting its full logical image size from the group maximum. That arithmetic is true but is **not a tested Android OTA/partition preservation strategy**. It was introduced prematurely without comparing current Xiaomi Lineage device trees. Removed from `BoardConfig.mk` in commit `34a0e05`. Default configuration was never enabled by that block.

**Engineering decision still open:** do we build only userspace images and assemble a **complete stock-preserving Mist offline super** (similar to Madrid, but with verified original Mist geometry and AVB checks), or construct integrated Lineage vendor/system/ODM/DLKM images with explicit management of `mi_ext` and snapshot/OTA semantics? Select an approach based on the actual LineageOS target, available artifact producers, and first-stage/AVB policy. Avoid guessing that removing an image from `BOARD_*_PARTITION_LIST` preserves it on an update.

## Next work that requires actual validation

1. Decode specific original `mi_ext` file contents and identify which mounted overlays or services remain needed after replacing `system/product/system_ext`.
2. Use verified stock `lpdump` metadata and the exact original `mi_ext_a.img`/hash if constructing an **offline** stock-preserving `super` specimen. This is not an instruction to flash it.
3. Determine AVB chain, slot-B retention, virtual A/B snapshots and OTA payload semantics before generating installable packages.
4. Validate original stock sepolicy and mounted paths against actual Lineage packages, never blindly copying the compiled stock policy.

Do not claim that any of these references establishes Mist boot, safe flashing, or A/B OTA completion.
