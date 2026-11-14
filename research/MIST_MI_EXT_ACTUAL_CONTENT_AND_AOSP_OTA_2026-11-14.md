# Mist mi_ext — original file inventory and Lineage removal feasibility (2026-11-14)

## What was actually inspected

Source: original OS3.0.304.0.WPUMIXM firmware, checksum-verified and mounted in [full-ROM Actions run 43579076486](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/job/132399705358). **The actual artifact** [14107138565](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486/artifacts/14107138565) was retrieved, and its `all-files.tsv` was analyzed for `mi_ext_a` entries. This report is grounded in file paths/sizes, not guesses about raw file contents. The original `mi_ext_a` partition is EROFS, logical image size **1,108,955,136 bytes**. Its file-inventory entries are **150** (some are zero-byte placeholders). Do not equate summing apparent file lengths with used allocated partition extents.

| Root category inside mi_ext_a | Indexed entries |
|---|---:|
| `product/etc` | 61 |
| `product/opcust` | 22 |
| `product/priv-app` | 19 |
| `product/data-app` | 11 |
| `product/app` | 10 |
| `product/ai` | 9 |
| `product/overlay` | 6 |
| `etc/init` | 4 |
| Other file entries | 8 |

### Specific stock files worth engineering review

- Telephony/GMS RROs: `product/overlay/GmsTelephonyOverlay.apk`, `GmsTelecommOverlay.apk`, `MiuiTelephonyResCustOverlay.apk`, `MiuiStkResOverlay.apk`. APK path presence **does not prove** that LineageOS needs the same overlays; resource package targets and values need inspection before migration.
- Regional features: `product/etc/cust_features/cust_sim_features.xml`, `product/etc/cust_features/cust_features.xml`, country/operator subdirectories, `product/etc/sysconfig/carrier_apps_state.xml`, `product/etc/permissions/signature-permissions-mx_virtualsim.xml`. Many of these can be proprietary HyperOS/Google application features rather than baseband requirements.
- Init/props: `etc/build.prop`, `etc/init/init.miui.mi_ext.rc`, `init.miui.customized.id.rc` and two Xiaomi/Google revenue/client-ID RC files. The **content** and service dependencies of these RCs have not yet been inspected.
- The remaining large files are mainly stock Xiaomi/Google applications, AI plugins, regional assets and permission XMLs; do not copy these into Lineage just because stock ships them.
- In the complete indexed mi_ext file list, **no `.ko`, native `.so`, modem `.mbn` or named hardware calibration blob is visible**. This is a path-based negative observation, not proof that no package contains embedded data or that no other partition depends on a mi_ext path.

## AOSP OTA behavior: what the explanation gets right and wrong

Official AOSP docs:
- [Dynamic partition implementation](https://source.android.com/docs/core/ota/dynamic_partitions/implement): dynamic partitions can be created, resized or deleted during an update.
- [A/B OTA flow](https://source.android.com/docs/core/ota/dynamic_partitions/ab_launch): update_engine removes **target-slot** groups from copied metadata and reconstructs them from `dynamic_partition_metadata` in the payload while keeping source-slot extents.
- [DynamicPartitionMetadata proto](https://android.googlesource.com/platform/system/update_engine/+/HEAD/update_metadata.proto): **an existing group absent from the OTA manifest is not updated**, and its partitions are not automatically removed.
- [Virtual A/B overview](https://source.android.com/docs/core/ota/virtual_ab): snapshots and merging are involved; it is not sufficient to assert that omitting a partition from a BoardConfig automatically removes it from every active map.

Therefore a **clean LineageOS build without mi_ext is a viable strategy to test**, not a guaranteed present fact about a Mist boot/OTA that has never happened. Actual removal depends on the built payload/target metadata, source/target groups, snapshot behavior and recovery/first-stage boot path. `BOARD_GOOGLE_DYNAMIC_PARTITIONS_PARTITION_LIST` is not an established Mist-specific variable here: current Lineage Qualcomm examples use `BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST` with `BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions`.

## First-stage boot caveat

Original [stock fstab snapshot](../boot/stock_snapshot/first_stage_ramdisk/fstab.default) mounts `mi_ext` on `/mnt/vendor/mi_ext` as `logical,first_stage_mount,nofail`, binds it to `/mi_ext`, and contains multiple Xiaomi-specific overlay mounts onto `/product`, `/system` and `/system_ext`. This original file lives in the **stock vendor_boot ramdisk**; the staged `rootdir/etc/fstab.mist` is **not installed**. Removing `mi_ext` from an uninstalled staged fstab does not remove original first-stage mount behavior from the reused stock `vendor_boot.img`. Stock `nofail` reduces the risk of first-stage mount failure, but does not establish that all downstream overlays, init services, security policy and app dependencies are harmless.

## Recommended Mist-specific engineering direction (not yet implemented)

1. **Prefer a clean Lineage group that does not generate mi_ext**, subject to validating actual firmware-provided requirements listed above. This is consistent with modern Qualcomm Lineage BoardConfig patterns, but not a verified boot result.
2. Review **actual content** of candidate telephony RROs, regional features and `mi_ext` RC files before extracting or migrating any. Keep only proven dependencies; do not import HyperOS application suite or account identifiers.
3. Build and inspect the target-slot update payload/dynamic-partition metadata before asserting that target `mi_ext` is deleted. Do not conflate target metadata update with immediately erasing the active source slot.
4. Plan replacement of stock `vendor_boot`/fstab and AVB integration; source mounting from preserved stock ramdisk may retain stale Xiaomi overlay references even if the new target omits `mi_ext`.
5. Do not flash or rely on old `MIST_ENABLE_OFFLINE_SUPER_LAYOUT` (removed). Final group sizing, snapshot/COW budget, complete image ownership and OTA integration still need build-system validation.

**Resolution of competing claims:** Original stock-preserving `super` reconstruction (as done by the unbooted Xiaomi Madrid experiment) remains *one possible offline method*, not a mandatory best practice. Clean omission and selective migration of verified stock dependencies are now the preferred integration hypothesis for Mist; neither path has yet been proved to boot or upgrade safely.
