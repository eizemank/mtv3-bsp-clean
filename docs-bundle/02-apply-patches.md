# 02 — Apply the mtv3 delta

Run this on the **clean** baseline from [01-bootstrap.md](01-bootstrap.md). The patches
will *not* apply onto a tree that already contains the changes — apply them once, on a
pristine sync.

The mtv3 delta comes in two parts:

- **`mtv3-files/`** — board-specific files (DTS/DTSI, mtv3 defconfigs, `ov13850.c`
  sensor driver, `rv1126-u-boot.dtsi`, SPL blobs, OEM scripts, board config). Copied in.
- **`*.patch`** — generic edits to upstream Firefly source only. Applied with `git apply`.

For every repo the flow is:

1. create branch `rv1126_rv1109/firefly` at the exact pinned commit (the baseline),
2. create the product branch `rv1126_rv1109/mtv3` off it,
3. copy the matching `mtv3-files/` content into the tree,
4. `git apply` the delta patch (skip for `u-boot`/`rkbin` — files only),
5. apply the integration glue, then commit.

## One-shot (all repos)

```bash
# from the SDK top dir; point at wherever this bundle lives
bash /path/to/mtv3-patches/apply.sh "$PWD"
```

`apply.sh` refuses to run in a dirty repo and writes `*.rej` files if a hunk fails.

## Manual, per repo (buildroot shown)

```bash
cd buildroot

# 1) baseline branch = the commit repo pinned
git checkout -B rv1126_rv1109/firefly \
  "$(git for-each-ref --format='%(refname)' 'refs/remotes/m/*' | head -1)"
#   equivalently:
#   git checkout -B rv1126_rv1109/firefly refs/tags/rv1126_rv1109_ai/linux_release_v2.3.3b

# 2) product branch
git checkout -B rv1126_rv1109/mtv3 rv1126_rv1109/firefly

# 3) copy this repo's board files (from the top dir, once for all repos)
#    cp -av /path/to/mtv3-patches/mtv3-files/. <SDK_TOP>/

# 4) apply the generic delta + commit
git apply --binary --whitespace=nowarn /path/to/mtv3-patches/buildroot.patch
git add -A
git commit -m "mtv3: apply BSP delta vs Firefly v2.3.3b"
```

Repeat for the other repos:

| Repo            | Patch | Files only (mtv3-files/) |
|-----------------|-------|--------------------------|
| `buildroot`     | `buildroot.patch` | 1 mtv3 buildroot defconfig |
| `device/rockchip` | `device_rockchip.patch` | board `.mk`, `parameter-mtv3.txt`, OEM scripts |
| `kernel`        | `kernel.patch` | mtv3 DTS/DTSI, `rv1126_mtv3_defconfig`, `ov13850.c` |
| `u-boot`        | — | `rv1126-mtv3.dts`, `rv1126-u-boot.dtsi`, `rv1126.dtsi`, `rv1126_mtv3_defconfig` |
| `rkbin`         | — | SPL blobs only |
| `docs`          | `docs.patch` — `repo` symlinks; skip unless needed | — |

### Integration glue (one manual edit)

The patches are intentionally mtv3-free, so one shared-file edit is applied by hand
(also done automatically by `apply.sh`):

```bash
# kernel: register the device tree
sed -i 's#\(\trv1126-sphericalipc-ddr3-v10.dtb \\\)#\1\n\trv1126-mtv3.dtb \\#' \
  kernel/arch/arm/boot/dts/Makefile
```

## Reviewing buildroot in pieces

`buildroot.patch` touches 43 files (all generic — no board configs). The `buildroot/`
subfolder splits it 1:1:

| Patch | Concern |
|-------|---------|
| `pkg-package-efl.patch`, `pkg-package-expat.patch`, `pkg-package-fakeroot.patch`, `pkg-package-squashfs.patch` | host-build fixes (`squashfs` = GCC 10 `-fno-common` link fix)  |
| `pkg-package-opencv.patch` | removes opencv **and** its `package/Config.in` include line (self-contained) |
| `pkg-package-bluez-alsa.patch`, `pkg-package-wpa_supplicant.patch`, `pkg-package-rockchip-rknpu.patch`, `pkg-package-rockchip-rkwifibt.patch` | other package edits |
| `board.patch`, `gitignore.patch` | board overlay files, gitignore |

The board buildroot defconfigs are in `mtv3-files/buildroot/configs/`, not here.

## Gotchas

- **opencv removal:** must include the `package/Config.in` line removal, or buildroot's
  Kconfig aborts with `can't open file "package/opencv/Config.in"`. `pkg-package-opencv.patch`
  and the full `buildroot.patch` already contain this.
- **Mode warnings** (`100755 / expected 100644`) are cosmetic; the patch still applies.
- **kernel artifacts:** `kernel.patch` still carries generated `scripts/dtc/lex.yy.c`. Drop
  it from the commit if you don't want it tracked.
- **full-file replacements:** `ov13850.c` and `rv1126-u-boot.dtsi` in `mtv3-files/` overwrite
  upstream. On a future Firefly rebase, re-diff them against the new upstream.

Next: [03-build-flash.md](03-build-flash.md).
