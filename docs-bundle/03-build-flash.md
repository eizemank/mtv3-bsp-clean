# 03 — Build, pack, and flash

Run from the SDK top dir, after [02-apply-patches.md](02-apply-patches.md).

## 1. Select the mtv3 board

The build is driven by the `device/rockchip/.BoardConfig.mk` symlink. Point it at mtv3:

```bash
./build.sh mtv3-rv1126.mk      # switch to the mtv3 board config
# or interactively:
# ./build.sh lunch
```

Confirm:

```bash
./build.sh                          # prints "Target BoardConfig: .../mtv3-rv1126.mk"
realpath device/rockchip/.BoardConfig.mk
```

What the board config selects ([mtv3-rv1126.mk](../../device/rockchip/rv1126_rv1109/mtv3-rv1126.mk)):

| Var | Value |
|-----|-------|
| `RK_KERNEL_DTS`     | `rv1126-mtv3` |
| `RK_KERNEL_DEFCONFIG` | `rv1126_mtv3_defconfig` |
| `RK_UBOOT_DEFCONFIG`  | `rv1126_mtv3` |
| `RK_CFG_BUILDROOT`    | `rockchip_rv1126_rv1109_mtv3` |
| `RK_PARAMETER`        | `parameter-mtv3.txt` |
| `RK_OEM_DIR`          | `oem_mtv3` |
| `RK_PACKAGE_FILE`     | `rv1126_rv1109-package-file-uvc` |
| `RK_PRODUCT_MODEL`    | `CAM_CRV1126S2U` |

## 2. Build

Full build end-to-end (recommended first time):

```bash
./build.sh allsave      # u-boot + kernel + buildroot rootfs, then collect images
```

Or component-by-component:

```bash
./build.sh uboot
./build.sh kernel
./build.sh rootfs       # buildroot, config rockchip_rv1126_rv1109_mtv3
```

## 3. Assemble the firmware

```bash
./mkfirmware.sh         # gather boot/kernel/rootfs/parameter into rockdev/
./build.sh updateimg    # build rockdev/update.img (uses rv1126_rv1109-package-file-uvc)
```

Outputs land in `rockdev/`: `boot.img`, `rootfs.img`, `oem.img`, `userdata.img`,
`parameter.txt`, `update.img`, and the loader.

## 4. Flash

USB into MaskROM / loader mode, then:

```bash
# whole image
./rkflash.sh update            # or: upgrade_tool uf rockdev/update.img

# or individual partitions
./rkflash.sh boot
./rkflash.sh rootfs
```

On Windows use `RKDevTool` with `rockdev/` and the generated `parameter.txt`.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `can't open file "package/opencv/Config.in"` | opencv include not removed — see [02-apply-patches.md](02-apply-patches.md) gotchas |
| host package fails to compile (efl/expat/fakeroot) | the buildroot host-build fix patches weren't applied |
| `not a git repository` running git at top dir | run git inside a sub-repo (`buildroot/`, `kernel/`, …) — the top dir is a `repo` workspace, not a git repo |
| wrong board built | re-check `realpath device/rockchip/.BoardConfig.mk` |
