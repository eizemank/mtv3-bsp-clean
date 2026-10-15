# 00 — Overview

## What "mtv3" is

`mtv3` (Zarnitza RV1126) is a **product board** derived from Firefly's RV1126/RV1109
AI-camera reference SDK. It is *configuration + patches* on top of an unmodified Firefly
release — not a fork of the whole SDK. The board is identical in spirit to the Firefly
reference; the deltas are: a board config, a kernel device tree + defconfig, a u-boot
defconfig, a custom buildroot package selection, and host-build fixes.

## How the SDK is assembled

The tree is managed by Google's `repo` tool (Firefly's fork). A *manifest* lists ~60 git
repositories and pins them all to one release tag. `repo sync` checks them out into a
single working tree:

```
rv1126_sdk_ai/                 # not a git repo itself — a repo workspace
├── .repo/                     # manifest + per-project git mirrors
├── buildroot/                 # rootfs build system        (git repo)
├── kernel/                    # Linux kernel               (git repo)
├── u-boot/                    # bootloader                 (git repo)
├── rkbin/                     # prebuilt loaders/SPL blobs  (git repo)
├── device/rockchip/           # board configs + build.sh   (git repo)
├── app/*  external/*          # Rockchip/Firefly apps+libs (git repos)
└── tools/  docs/  prebuilts/  # host tools, docs, toolchains
```

Key consequence: **the top directory has no `.git`**. Every `git` command (and every
patch in this bundle) operates inside a specific sub-repo (`buildroot/`, `kernel/`, …).

## The mtv3 delta, by repo

| Repo            | What mtv3 changes |
|-----------------|-------------------|
| `device/rockchip` | board config `mtv3-rv1126.mk`, partition table `parameter-mtv3.txt`, OEM scripts `oem/oem_mtv3/*` |
| `kernel`        | DTS `rv1126-mtv3` + `rv1126_mtv3_*.dtsi`, `rv1126_mtv3_defconfig`, sensor/mmc tweaks |
| `u-boot`        | `rv1126_mtv3_defconfig`, `rv1126-mtv3.dts`, SPL tweak |
| `rkbin`         | custom SPL blob `rv1126_spl_mtv3.bin` |
| `buildroot`     | board buildroot config `rockchip_rv1126_rv1109_mtv3`, host-build fixes (efl/expat/fakeroot/squashfs), removed opencv, plus bluez-alsa/wpa_supplicant/rknpu/rkwifibt edits |

## Two ways to maintain it

1. **Patch overlay (this bundle).** Keep all repos on the Firefly tag, apply the delta
   patches. Simple to start; good for archiving the exact state. Covered in
   [02-apply-patches.md](02-apply-patches.md). Downside: patches must be re-applied / kept
   in sync by hand.

2. **Forks + own manifest (recommended for ongoing work).** Commit the delta onto a
   `rv1126_rv1109/mtv3` branch in your own forks, and point a private manifest at those
   branches. Then `repo sync` reproduces the patched tree with zero manual steps. Covered
   in [04-fork-and-manifest.md](04-fork-and-manifest.md).

Start with (1) to validate the build, then graduate to (2) for the real product repo.
