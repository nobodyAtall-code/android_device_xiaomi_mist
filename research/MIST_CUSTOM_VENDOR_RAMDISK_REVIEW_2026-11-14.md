# Mist clean first-stage vendor ramdisk preparation — REVIEW ONLY

## Implemented patcher (14 November 2026)

Control repository: [`scripts/prepare_mist_clean_vendor_ramdisk.py`](https://github.com/nobodyAtall-code/copilot_project/blob/main/scripts/prepare_mist_clean_vendor_ramdisk.py).

This is **real offline CPIO patching, not just research**. It checks the exact original OS3.0.304.0.WPUMIXM `vendor_boot.img` SHA256 `f0d692792cacff3026876edbd68aed5d23be7e1acef3e6028ccd5fff21ae5acb`, parses the original Android vendor_boot v4 ramdisk fragment, legacy-LZ4-decompresses it, verifies the original SHA256 of `first_stage_ramdisk/fstab.default` (`cfc3c5b837d6b1491126667eff591efcc23f888548bdcd5839216f630b942516`), and replaces **only that regular CPIO member** with `device/xiaomi/mist/rootdir/etc/fstab.mist`.

It retains every other CPIO member **as the original raw record bytes** (including file mode, uids/gids, symlinks, module binaries and module load lists), retaining archive ordering. After rebuilding, it parses the archive again, compares every unaffected CPIO member against its original record, recompresses it as legacy-LZ4 and byte-for-byte verifies a decompression roundtrip. The **original** `vendor_boot.img` remains untouched. This tool deliberately **does not repack an Android boot image** or change the build-system `BOARD_PREBUILT_VENDOR_BOOTIMAGE`.

The patcher checks for all seven logical Lineage mounts and refuses any `mi_ext` mount entries in the replacement fstab. Original stock runtime already confirmed `ro.boot.fstab_suffix=default` (physical device ADB evidence). No change to `fstab.emmc` is made: it is not selected by current stock runtime.

### Run locally using existing stock image (no firmware redownload)

```bash
cd ~/android/lineage
mkdir -p /tmp/mist-bootcheck
BASE="https://raw.githubusercontent.com/nobodyAtall-code/copilot_project/main/scripts"
curl -fL "$BASE/inspect_mist_boot_chain.py" -o /tmp/mist-bootcheck/inspect_mist_boot_chain.py
curl -fL "$BASE/prepare_mist_clean_vendor_ramdisk.py" -o /tmp/mist-bootcheck/prepare_mist_clean_vendor_ramdisk.py

python3 /tmp/mist-bootcheck/prepare_mist_clean_vendor_ramdisk.py \
  --vendor-boot device/xiaomi/mist-kernel/vendor_boot.img \
  --fstab device/xiaomi/mist/rootdir/etc/fstab.mist \
  --output-dir /tmp/mist-vendor-ramdisk-review

cat /tmp/mist-vendor-ramdisk-review/mist-vendor-ramdisk-review.json
```

Requires `lz4` executable installed on Linux. The `--output-dir` must not contain old results. The script was committed but **has not been run against the user's local stock image** in this chat: do not report runtime validation PASS before reviewing the JSON.

### Critical gates before generating a bootable image

1. Original `vendor_boot` format requires careful reconstruction of the vendor_boot v4 header, vendor ramdisk table, bootconfig, original vendor DTBs, alignment and any signature/size constraints. The fragment is **not** a valid standalone flash image.
2. The original `fstab.default` contains Xiaomi `mi_ext` overlays; staged clean fstab removes these. Verify original product/vendor init RC and sepolicy file contexts for any references, mount order and hardware service behavior. The script checks identical CPIO entries, **not runtime dependency correctness**.
3. Original `vendor_boot` includes hundreds of stock kernel modules and their load order. CPIO byte preservation alone does not prove module ABI or boot success with any different kernel; retain the exact verified prebuilt kernel until analyzed.
4. Validate original AVB chain and re-signing, virtual A/B `update_engine` metadata and COW snapshots, VINTF and SELinux compilation. Do not flash without these.

**The intended output is a non-flashable review artifact** named `mist-vendor-ramdisk-REVIEW-ONLY.cpio.lz4`, plus `mist-vendor-ramdisk-review.json`. It is intentionally not integrated into `BOARD_PREBUILT_VENDOR_BOOTIMAGE`.
