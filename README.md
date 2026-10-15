# mtv3-bsp (clean, v2) — изменения платы MTV3 поверх Firefly SDK v2.3.3b

Источник: `~/Work/Zarnitza/sw/mtv3-patches` (комплект от 14.10.2026: `mtv3-files/` + generic
`*.patch` + `docs/`), база — тег `rv1126_rv1109_ai/linux_release_v2.3.3b`. Здесь оставлены
только изменения самой платы MTV3 в раскладке инструмента `mtv3-bsp`
(`mtv3-vision/board/mtv3-rv1126/docker/mtv3-bsp.sh`): `mtv3-bsp apply` накладывает `overlay/`
и `patches/` на чистое дерево SDK. Правки под сборку на Ubuntu 20.04 удалены: образ
`mtv3-rv1126-sdk` (Ubuntu 18.04) их не требует.

Проверено 15.10.2026: `mtv3-bsp apply` на дереве из upstream-файлов тега; результат
побайтно совпадает с полными файлами из `mtv3-files/`; патчи ядра 0005 + review
воспроизводят исходный `kernel.patch`; бинарный rkbin-патч накладывается.

Что изменилось относительно комплекта от 29.06.2025: переименования (`mtv3-rv1126.mk`,
`rv1126-mtv3.dts`, `rv1126_mtv3_defconfig`, `rv1126_mtv3` для U-Boot, `oem_mtv3`), dts
ревизии REV2 по аудиту netlist/BOM (Wi-Fi/BT включены, LED ACTIVE_HIGH, окна vdd_npu/vepu,
питание PHY, GMAC-клоки), в dts оставлена одна камера OV13850 (вторая закомментирована),
настоящие правки драйвера ov13850 вместо отладочных, патчи rkcif/rkispp/CMA, IQ-файл OV13850,
UVC-стек в buildroot-defconfig, OEM-базы `sysconfig*`.

## Оставлено

### overlay/ — новые файлы платы (копируются 1:1)

| Путь в SDK | Назначение |
|---|---|
| `device/rockchip/rv1126_rv1109/mtv3-rv1126.mk` | BoardConfig: `rv1126_mtv3` (U-Boot), `rv1126_mtv3_defconfig` + `rv1126-mtv3` (ядро), `rockchip_rv1126_rv1109_mtv3` (buildroot), `parameter-mtv3.txt`, `oem_mtv3`, OEM ext4, `RK_LOADER_UPDATE_SPL=true` |
| `device/rockchip/rv1126_rv1109/parameter-mtv3.txt` | таблица разделов eMMC (rootfs `mmcblk0p6`, oem p7, userdata p8) |
| `device/rockchip/oem/oem_mtv3/*` | OEM-раздел: `RkLunch.sh`, `aicamera.sh`, `usb_config.sh`, стоп-скрипты, базы `sysconfig*.db/json` для dbserver/uvc_app |
| `kernel/arch/arm/boot/dts/rv1126-mtv3.dts` | device tree платы, ревизия REV2 |
| `kernel/arch/arm/configs/rv1126_mtv3_defconfig` | конфигурация ядра (bcmdhd встроен, BT HCI UART, OV13850, CIF/ISP/ISPP) |
| `u-boot/arch/arm/dts/rv1126-mtv3.dts`, `u-boot/configs/rv1126_mtv3_defconfig` | U-Boot платы |
| `buildroot/configs/rockchip_rv1126_rv1109_mtv3_defconfig` | rootfs: UVC AI-camera стек, rkmedia, rknpu, opencv3 |
| `external/camera_engine_rkaiq/iqfiles/AVL_isp20/ov13850_OV13850-CAM1_default.xml` | IQ-файл (калибровка ISP) для OV13850, в upstream отсутствует |

### patches/ — изменения существующих файлов (`git am`)

| Патч | Что делает |
|---|---|
| `kernel/0001-ARM-dts-rockchip-build-rv1126-mtv3.dtb` | регистрация `rv1126-mtv3.dtb` в `arch/arm/boot/dts/Makefile` |
| `kernel/0002-media-i2c-ov13850-HDR-cfg-ioctls-and-enum_frame_interval` | ov13850: ioctl `RKMODULE_GET/SET_HDR_CFG` (NO_HDR), `enum_frame_interval` не отвергает чужой media-bus code |
| `kernel/0003-ARM-dts-rv1126-enlarge-default-CMA-pool-to-128-MiB` | CMA 8 → 128 МиБ в `rv1126.dtsi` (буферы ISP/ISPP/NPU) |
| `kernel/0004-media-rkcif-bail-out-of-set_fmt-when-no-sensor-is-linked` | rkcif: выход вместо NULL-разыменования, если сенсор не подключён |
| `kernel/0005-media-rkispp-disable-all-clock-gates-and-set-nobig_en` | rkispp: `GATE_DIS_ALL` при soft reset, явный `nobig_en=1` для малых кадров |
| `u-boot/0001-rockchip-rv1126-u-boot.dtsi-Zarnitza-MTV3-board` | переписанный общий `rv1126-u-boot.dtsi` (RK809-2, eMMC первым, SPL-узлы) |
| `u-boot/0002-rockchip-rv1126.dtsi-emmc-drop-use-v2-tuning` | eMMC без `rockchip,use-v2-tuning` |
| `buildroot/0001-package-opencv3-build-opencv_contrib-aruco-module` | opencv_contrib aruco для opencv3 3.3.0 (= `opencv3-aruco.mk.add` из mtv3-vision) |

## review/ — относится к MTV3, решить отдельно (по умолчанию не применяется)

| Патч | Почему под вопросом |
|---|---|
| `kernel/rkispp-DEBUG-force_tile-and-prints.patch` | отладка rkispp: module_param `force_tile`, `pr_info` при смене tile, `pr_err` с адресом `tmp_yuv`. Накладывается поверх 0005 |
| `rkbin/rv1126-spl-mtv3-blobs.patch` | бинарные `rv1126_spl_mtv3.bin` (новый) и перезаписанный `rv1126_spl_v1.08.bin`; те же блобы, что в июне. При `RK_LOADER_UPDATE_SPL=true` SPL берётся из U-Boot, ни один `.ini` на `rv1126_spl_mtv3.bin` не ссылается |
| `buildroot/wpa_supplicant-2.10.patch` | обновление wpa_supplicant 2.6 → 2.10; Wi-Fi в defconfig MTV3 не включён |
| `buildroot/fs-overlay-sysv-wpa_supplicant.conf.patch` | шаблон SSID/PASSWORD в общем overlay всех плат |

## Удалено

**Правки под хост Ubuntu 20.04** (в Docker-образе на Ubuntu 18.04 не нужны):
`device/rockchip/common/build.sh` (`-fcommon`, `-DYY_NO_INPUT`); `kernel/scripts/dtc/dtc-lexer.l`
и сгенерированный `lex.yy.c`; заглушка `drivers/mmc/core/mmc_blk_data_stub.c` вместо
прошивочного объекта `mmc_blk_data`; `buildroot/package/fakeroot` 1.33; `package/squashfs`
патч `-fno-common`; `package/python-cython` сборка host-cython через python3; `package/efl`,
`package/expat`; `.gitignore`.

**Не относится к MTV3:** `cam-crv1109s2u-uvcc.mk`, `cam-crv1126s2u-uvcc-BE-45.mk`;
`kernel/arch/arm64/boot/dts/rockchip/rv1126*` (пять файлов для arm64: не собираются, их
`#include "rv1126-mtv3-base.dtsi"` ссылается на несуществующие имена, arm-dts их не включает);
удаление `package/opencv` и строки в `package/Config.in` (в upstream пакет цел, Kconfig не
ломается); `package/bluez-alsa`, `package/rockchip/rknpu` (1.7.0, NPU_ARC), `package/rockchip/rkwifibt`;
`board/firefly/*`, `ff_export_rootfs_buildroot`, `fs-overlay-recovery/etc/fstab`; `docs.patch`.

`docs-bundle/` — документация из исходного комплекта (английская, с примером форков и
собственного манифеста), сохранена для справки; её раздел про хост-фиксы устарел для Docker-среды.

## Что проверить при первом применении

1. `RK_OEM_NODE` и `RK_USERDATA_NODE` в `mtv3-rv1126.mk` читает не `build.sh`, а
   `buildroot/package/rockchip/rkscript/rkscript.mk` при генерации `/etc/fstab`
   (`BR2_PACKAGE_RKSCRIPT=y` приходит из `base.config`). Работает только при сборке rootfs через
   `./build.sh rootfs` (BoardConfig экспортируется в окружение make); при прямом `make` в
   buildroot переменных нет и fstab получит `/dev/block/by-name/...`. Сами by-name-ссылки
   создаёт udev-правило `61-partition-init.rules` из rkscript, для этого нужен eudev
   (`base_extra.config`, он же включён в defconfig явно) и GPT с именами разделов из
   `parameter-mtv3.txt`. Так что при собранном через build.sh образе by-name должен работать и
   без NODE-переменных; они — страховка.
   Отдельно: `RK_OEM_BUILDIN_BUILDROOT=YES` означает, что `oem.img` собирает buildroot-пакет
   `rk_oem` из `BR2_PACKAGE_RK_OEM_RESOURCE_DIR`, а не `mkfirmware.sh` из `RK_OEM_DIR`. В исходном
   комплекте этот путь указывал на `oem_ipc_firefly`, и скрипты из `oem/oem_mtv3/` в прошивку не
   попадали. Исправлено 15.10.2026: в defconfig здесь `RESOURCE_DIR` переключён на `oem_mtv3`
   (та же правка внесена в `mtv3-patches/mtv3-files`).
2. В исходном комплекте шесть строк `rockchip_rv1126_rv1109_mtv3_defconfig` начинались с `;`
   (попытка выключить rkaiq). Kconfig их игнорировал, а `BR2_PACKAGE_RKMEDIA_USE_AIQ=y` всё равно
   выбирает `CAMERA_ENGINE` → `RKAIQ`, так что rkaiq собирался со всеми IQ-файлами `*/*.xml`.
   Исправлено 15.10.2026: rkaiq включён явно, `IQFILE="AVL_isp20/ov13850_OV13850-CAM1_default.xml"`
   (имя под dts: сенсор, `camera-module-name`, lens), rkisp_demo и установка в rootfs выключены
   штатным синтаксисом. Та же правка в `mtv3-patches/mtv3-files`.
3. `BR2_PACKAGE_OPENCV3_LIB_PYTHON=y` требует python для target; по опыту проекта python3 в
   buildroot 2018.02 собирается с конфликтами (см. `board/mtv3-rv1126/README.md`).
4. `oem_mtv3/RkLunch.sh`: автозапуск `/oem/aicamera.sh` закомментирован с пометкой TEMP
   (шторм перезапусков при ошибке rkaiq). `S60mtv3` из mtv3-vision запускает свой тракт
   (`mtv3_cam_daemon` + `mainCV`), оба одновременно не нужны.
5. Патч opencv3/aruco ждёт `buildroot/dl/opencv_contrib-3.3.0.tar.gz`, скачать вручную
   (команда в комментарии патча).
6. В `mtv3-rv1126.mk` остались `RK_PRODUCT_MODEL=CAM_CRV1126S2U` и `RK_PACKAGE_FILE=rv1126_rv1109-package-file-uvc`.
7. `rv1126-u-boot.dtsi` правится целиком; при обновлении SDK конфликтует первым.
