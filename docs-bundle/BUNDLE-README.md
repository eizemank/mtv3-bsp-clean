# mtv3 BSP — reproduce from scratch

This bundle reproduces the **mtv3** (Zarnitza RV1126) board support package on top of the
stock **Firefly RV1126/RV1109 AI-camera SDK**, using only:

1. the public Firefly sources (pulled with `repo`), pinned to one release tag, and
2. the delta patches in this folder.

Nothing here depends on a pre-modified tree — follow the docs in order and you get a
flashable image.

## Baseline (the "original" everything is diffed against)

| Item              | Value |
|-------------------|-------|
| repo tool         | `https://gitlab.com/firefly-linux/git-repo.git` |
| manifests repo    | `https://gitlab.com/firefly-linux/manifests.git` (branch `master`) |
| manifest file     | `rv1126_rv1109_linux_ai_camera_release.xml` |
| pinned release    | tag `rv1126_rv1109_ai/linux_release_v2.3.3b` (each repo's `m/*` ref) |
| SoC / board       | RV1126 / Zarnitza mtv3 |
| board config      | `device/rockchip/rv1126_rv1109/mtv3-rv1126.mk` |
| buildroot config  | `rockchip_rv1126_rv1109_mtv3` |
| kernel DTS        | `rv1126-mtv3` (defconfig `rv1126_mtv3_defconfig`) |
| u-boot defconfig  | `rv1126_mtv3` |
| product model     | `CAM_CRV1126S2U` |

## Docs (read in order)

| File | Purpose |
|------|---------|
| [docs/00-overview.md](docs/00-overview.md)            | What mtv3 is, layout, and the two ways to maintain it |
| [docs/01-bootstrap.md](docs/01-bootstrap.md)          | Install `repo`, init + sync the Firefly baseline |
| [docs/02-apply-patches.md](docs/02-apply-patches.md)  | Branch off baseline and apply the mtv3 delta |
| [docs/03-build-flash.md](docs/03-build-flash.md)      | Select the board, build, pack `update.img`, flash |
| [docs/04-fork-and-manifest.md](docs/04-fork-and-manifest.md) | Durable setup: own forks + own manifest (no loose patches) |
| [docs/05-vision-software.md](docs/05-vision-software.md)     | Add the separate vision software to the image |

## How the delta is split

The mtv3 delta is kept in two forms so the patches stay free of board-specific content:

1. **`mtv3-files/`** — the board-specific files as **real files** (DTS/DTSI, mtv3/zar
   defconfigs, sensor driver, SPL blobs, OEM scripts, board config). Copied into the tree,
   not patched. See [mtv3-files/README.md](mtv3-files/README.md).
2. **`*.patch`** — only **generic edits to upstream Firefly source** (host-build fixes,
   package add/remove, etc.). No mtv3 references.

### Patches (apply at each repo root, `git diff --binary` vs the baseline tag)

| Repo            | Patch | Scope |
|-----------------|-------|-------|
| buildroot       | `buildroot.patch` (45 files; split in `buildroot/`) | efl/expat/fakeroot/squashfs/python-cython host fixes, opencv removal, opencv3 + contrib aruco, bluez-alsa/wpa_supplicant/rknpu/rkwifibt, board overlays |
| device/rockchip | `device_rockchip.patch` (3 files) | `build.sh`, two cam `*.mk` edits |
| kernel          | `kernel.patch` (10 files) | mmc stub, dtc lexer, CMA 128M (`rv1126.dtsi`), rkcif no-sensor guard, rkispp clkgate/NR/sharp fixes + `force_tile` param (+ debug prints) |
| u-boot          | — | files-only (DTS/DTSI/defconfig in `mtv3-files/`) |
| rkbin           | — | files-only (SPL blobs in `mtv3-files/`) |
| camera_engine_rkaiq | — | files-only (OV13850 IQ xml in `mtv3-files/`) |
| docs            | `docs.patch` | repo symlinks only — usually skip |

`apply.sh` automates the whole thing: branch → copy `mtv3-files/` → apply patches →
integration glue. `COMMANDS.md` has the manual commands.

> Removed on purpose (not in patches, not in `mtv3-files/`): u-boot `tee.bin.gz` /
> `tee.digest` / `spl.c` debug print, and 9 Firefly buildroot defconfig edits — all
> reverted to upstream. Details in [mtv3-files/README.md](mtv3-files/README.md).
