# Mist stock `mi_ext` to LineageOS transition — source-backed decision

**Status: unresolved runtime integration; not a boot failure proven by fstab alone.**

Original stock source: Xiaomi Global OS3.0.304.0.WPUMIXM, `vendor_boot.img` SHA256
`f0d692792cacff3026876edbd68aed5d23be7e1acef3e6028ccd5fff21ae5acb`.
Primary recorded evidence: `copilot_project/research/generated/mist-stock-config.json`,
`vendor_a/etc/fstab.default`; independently normalized but **not installed**
`boot/stock_snapshot/first_stage_ramdisk/fstab.default`.

## Stock fstab dependencies

* Two conditional `mi_ext` filesystem entries (EROFS, EXT4) at
  `/mnt/vendor/mi_ext`, each with
  `wait,slotselect,avb=vbmeta,logical,first_stage_mount,nofail`.
* One `/mnt/vendor/mi_ext` to `/mi_ext` bind mount with `wait,nofail`.
* **22** stock overlay filesystem mounts with `check,nofail`.
  **21** reference `/mnt/vendor/mi_ext`, while the
  `/system/framework` overlay depends only on Xiaomi `/product/pangu`
  and `/system/framework` source paths.
* Overlay targets:
  `/product/overlay`, `/product/app`, `/product/priv-app`,
  `/product/lib`, `/product/lib64`, `/product/bin`,
  `/product/framework`, `/product/media`, `/product/opcust`,
  `/product/data-app`, `/product/etc/sysconfig`,
  `/product/etc/permissions`, `/product/usr`,
  `/product/etc/precust_theme`, `/product/etc/preferred-apps`,
  `/product/etc/security`, `/system/app`, `/system/priv-app`,
  `/system/framework`, `/system/etc/sysconfig`,
  `/system/etc/permissions`, `/system_ext/etc/permissions`.

## Engineering implications

1. `nofail` marks failures as nonfatal for the **individual** mount;
   this does not establish that all init services, HAL binaries, permissions,
   libraries or the entire stock boot pipeline will tolerate missing content.
2. Lineage BoardConfig intentionally generates seven logical partitions and
   **does not** create a synthetic `mi_ext` partition. The stock original
   `vendor_boot` is retained byte-for-byte (AVB-preserving baseline).
3. **Do not** remove, rewrite, or overlay the stock vendor ramdisk based on a
   normalized staging snapshot. Modification invalidates stock descriptor
   digest unless the new image is re-signed under a bootloader-accepted AVB
   chain and correctly integrated into OTA.
4. Before declaring the seven-partition target boot-ready, inventory the
   original `mi_ext` content (especially proprietary services, overlays,
   platform permission XML, and dynamic library dependencies), decide which
   files are required in product/system_ext/vendor, validate SELinux labels,
   and perform runtime checks on an authorized test device.
5. Stock virtual A/B source/target partition-group migration still requires
   explicit snapshot/COW and AVB rollback evaluation; stock `mi_ext`
   may exist in a prior-slot layout even when absent in the target.
6. This is **not** a recommendation to modify `fstab.default` or flash a
   custom `vendor_boot`. Keep original AVB and partition images unchanged.

## Source-only completed work

The stock `mi_ext` presence, both filesystem alternatives, overlay count,
and exact `nofail` flags have been checked against parsed original firmware
configuration. No build, device boot, signature acceptance or OTA test has
occurred for the proposed partition omission.
