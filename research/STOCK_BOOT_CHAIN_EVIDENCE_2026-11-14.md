# Mist stock boot-chain evidence — 14 November 2026

Source firmware: Xiaomi OS3.0.304.0.WPUMIXM (Android 16). This is an **offline, read-only source-inventory result**, **not an assertion of bootability**.

## Verified evidence

- [Stock ramdisk audit run 43540094714](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43540094714): SHA256-verified seven original stock boot images; the stock vendor_boot ramdisk has 302 CPIO members; init_boot has 17 members.
- Stock vendor_boot includes `first_stage_ramdisk/fstab.default` and `first_stage_ramdisk/fstab.emmc`, as well as `lib/modules/modules.load`, `lib/modules/modules.load.recovery` and `lib/modules/modules.blocklist`.
- [Boot module closure run 43540343960](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43540343960): 287 unique module basenames referenced by stock normal and recovery load lists; 181 basenames present in the verified archived vendor/odm/vendor_dlkm/system_dlkm source; 106 archive-unmatched basenames.
- [Embedded module reconciliation run 43540630241](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43540630241): SHA256-verified stock vendor_boot contains **291 .ko paths**. The 106 previously archive-unmatched basenames were **all present in vendor_boot**; 0 remain unaccounted for by basename. 181 archive-sourced basenames are also present in vendor_boot. This establishes filename coverage, **not** kernel module dependency, signature, ABI/vermagic, board revision or load order compatibility.
- Production `rootdir/etc/fstab.mist` is staged and **not yet copied into the ramdisk**. Previous audit compared mountpoint sets and reported 37 stock default and 14 emmc mountpoints missing from staged fstab; those include Xiaomi-specific mountpoints and overlays and should not be copied uncritically.

## Unresolved integration gates

1. Decide whether the Lineage boot process requires vendor_boot repacking at all and ensure first-stage `fstab` is placed at the correct location with correct fs_mgr and AVB flags.
2. Inspect stock `modules.dep`, `modules.alias`, `modules.options` and `modules.blocklist`; test transitive load-order/depends relationships and kernel version/vermagic against the exact published stock prebuilt kernel.
3. Validate `vendor_boot` ramdisk fragment table semantics, dtb/dtbo selection and recovery boot behavior, not just names.
4. Preserve stock signature provenance; validate AVB partition chains/rollback indices and appropriate vbmeta handling before generating flashable boot images.
5. Validate SELinux policy, init service ownership and KeyMint before a boot attempt.

## Safety

Do **not** enable staged fstab, replace vendor_boot, or start a full ROM build solely from these reports. No runtime tests or flash tests have occurred. GitHub Actions scripts and the full JSON provenance remain in `nobodyAtall-code/copilot_project`; **no action workflow belongs in this device repository**.
