# Mist AVB signing and boot acceptance contract

Status: **source evidence verified; no trusted custom signing chain or flash-ready images**.

## Verified stock inputs

Original Xiaomi Global `OS3.0.304.0.WPUMIXM`, complete mounted stock firmware
audit [run 43579076486](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43579076486)
and original actual AOSP `avbtool` audit
[run 43614661004](https://github.com/nobodyAtall-code/copilot_project/actions/runs/43614661004).
Original seven stock boot images match recorded SHA256. Original
`vbmeta.img` and `vbmeta_system.img` each passed their
`SHA256_RSA2048` RSA vbmeta *structure signature* checks; the full
descriptor/hashtree chain remains incomplete because the necessary original
images and/or expected chain parameters were not all supplied. Stock
`vendor_boot.img` and `dtbo.img` have standalone `Algorithm: NONE`
metadata and verified hash descriptors; that does **not** make their
contents independent of the signed top-level vbmeta chain.

## Stock vbmeta partition topology — original SHA-locked evidence

Parsed from original `full-avb-dtbo-dtb.json` in artifact `14107138565`:

| Stock top-level vbmeta chain partition | Rollback index location | Embedded expected public key SHA256 |
| --- | ---: | --- |
| `boot` | 3 | `c5d3c71bc70d58e3e0409ca9d9b34c0dbac1d2f09a5de948a4b8f090f1926965` |
| `recovery` | 1 | Same |
| `vbmeta_system` | 2 | Same |

Top-level stock vbmeta also contains hash descriptors for
`countrycode`, `dtbo`, `init_boot`, `pvmfw`, and `vendor_boot`, and
**five hashtree descriptors**. The `vbmeta_system` image has **three
hashtree descriptors**. In this inventory, hashtree partition names
were not parsed, so do not invent their partition membership or claim
their contents have been verified.

### Consequences for custom images

* Replacing `init_boot`, `vendor_boot`, `dtbo`, `boot` or any
  partition protected by the stock vbmeta descriptor chain changes a
  covered digest/hashtree; retaining the stock signed vbmeta cannot
  authenticate arbitrary modified bytes.
* Stock chained public-key SHA256 is a fingerprint of a **public**
  verification key, not the private signing key. Original signing private
  keys are unavailable in the verified inputs. **Do not** attempt to
  reuse stale stock RSA signatures, patch verified bytes in place, or
  claim an edited `vendor_boot.img` is flash-safe.
* A developer AVB chain requires a separately generated private key, an
  appropriate bootloader trust/lock-state policy, correct rollback
  locations, image sizes and partition descriptors, and verification
  of **every** updated image and target-slot AVB/OTA metadata. A
  development key is not automatically trusted by a locked Xiaomi
  bootloader.
* The stock filesystem's `mi_ext` is mounted and `fstab.default`
  is selected on the physical stock phone; a clean seven-partition
  Lineage super group is a **proposed** migration that still needs
  bootloader trust, first-stage overlay and virtual A/B validation.
* Preserve the currently SHA256-verified original stock
  `vendor_boot.img` as a **read-only reference**. Do not flash a
  custom `init_boot`, `vendor_boot`, `vbmeta` or `super` until
  signed acceptance and rollback policies are established.

## Exact pending gates

1. Complete stock AVB hash and chained-partition verification using
   original images and `avbtool --follow_chain_partitions` while
   preserving stock public key trust boundaries.
2. Obtain the stock hashtree-covered original logical partition images
   (not just size/file inventories) to verify expected root hashes.
3. Verify target device lock state and supported developer signing
   method with read-only commands before any write/flash attempt.
4. Produce a complete custom `vendor_boot` containing validated
   first-stage fstab and hardware module/DTB requirements; **unsigned
   assembly is only an isolated research candidate**.
5. Independently verify signed custom image/descriptor coverage, VINTF,
   init/SELinux, snapshot/OTA and real device boot.

No step above is satisfied merely by passing a source-only audit.
