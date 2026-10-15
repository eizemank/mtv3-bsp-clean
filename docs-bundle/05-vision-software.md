# 05 — Add the vision software

The vision software is a **separate concern** from the embedded BSP: its own git repo, its
own version tags and CI. It is pulled into the workspace as one more `repo` project and
built into the rootfs as a buildroot package.

## 1. Keep it in its own repo

```
gitlab.com/eqvasset/mtv3-vision        # the vision app/library, standalone
```

Add it to your manifest (already shown in [04-fork-and-manifest.md](04-fork-and-manifest.md)):

```xml
<project name="vision/mtv3-vision" remote="eqvasset" revision="main" path="app/vision"/>
```

After `repo sync` it lands at `app/vision/`.

## 2. Wire it into the rootfs (recommended: a buildroot package)

Create `buildroot/package/mtv3-vision/`:

`Config.in`
```kconfig
config BR2_PACKAGE_MTV3_VISION
	bool "mtv3-vision"
	help
	  Zarnitza mtv3 vision/AI application.
```

`mtv3-vision.mk`
```make
MTV3_VISION_VERSION = 1.0
MTV3_VISION_SITE = $(TOPDIR)/../app/vision
MTV3_VISION_SITE_METHOD = local
MTV3_VISION_DEPENDENCIES = rknpu2 rkmedia        # adjust to real deps

define MTV3_VISION_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) CROSS_COMPILE=$(TARGET_CROSS)
endef

define MTV3_VISION_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/mtv3-vision $(TARGET_DIR)/usr/bin/mtv3-vision
endef

$(eval $(generic-package))
```

Register it: add to `buildroot/package/Config.in` (near the other rockchip apps):
```kconfig
	source "package/mtv3-vision/Config.in"
```

Enable it in the board buildroot config:
```bash
cd buildroot
make rockchip_rv1126_rv1109_mtv3_defconfig
make menuconfig          # turn on "mtv3-vision", save
make savedefconfig       # writes back to configs/rockchip_rv1126_rv1109_mtv3_defconfig
```

> Use `_SITE_METHOD = local` so buildroot builds the in-tree `app/vision/` checkout — the
> source stays versioned in its own repo, not vendored into buildroot.

## 3. Alternative: standalone build into the OEM overlay

If the vision stack uses a different toolchain or release cadence, build it separately and
drop the artifacts into the OEM partition instead of buildroot:

```
device/rockchip/rv1126_rv1109/oem_mtv3/   # RK_OEM_DIR; contents -> oem.img
```

Place binaries/configs/startup scripts here; they are packaged into `oem.img` by
`./build.sh allsave` with no buildroot changes. Simpler, but not part of the unified build.

## Which approach?

| | buildroot package | OEM overlay |
|-|-------------------|-------------|
| Built by `./build.sh rootfs` | yes | no (built separately) |
| Same toolchain as rootfs | yes | not required |
| Dependency tracking | yes (buildroot) | manual |
| Best when | vision shares the buildroot toolchain | vision has its own build/toolchain |

Default to the **buildroot package**; fall back to the **OEM overlay** only if the vision
build can't live inside buildroot.
