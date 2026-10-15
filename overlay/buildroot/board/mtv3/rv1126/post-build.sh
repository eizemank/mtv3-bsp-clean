#!/bin/sh
# board/mtv3/rv1126/post-build.sh — BR2_ROOTFS_POST_BUILD_SCRIPT платы MTV3.
# Buildroot вызывает его после сборки всех пакетов: $1 = TARGET_DIR (будущий rootfs).
# Кладёт в rootfs тракт mtv3-vision: автостарт S60mtv3, скрипты из board/mtv3-rv1126
# и собранные mtv3_cam_daemon / mainCV. Источник — репозиторий mtv3-vision:
# $MTV3_REPO (в контейнере mtv3-rv1126-sdk это /work/mtv3-vision).
#
# Первая сборка rootfs идёт ДО сборки mainCV (ему нужен staging из этой же сборки),
# поэтому отсутствие бинарников — предупреждение, а не ошибка: после mtv3-cmake и
# mtv3-daemon повторить `./build.sh rootfs`, buildroot перезапустит только этот шаг.
set -eu

TARGET_DIR=$1
REPO=${MTV3_REPO:-/work/mtv3-vision}
BOARD=$REPO/board/mtv3-rv1126
APP=$REPO/cpp/SeeSharp/build-rv1126
MODELS=$REPO/common/models
log() { echo "mtv3 post-build: $*"; }

if [ ! -d "$BOARD" ]; then
    log "mtv3-vision not found at $REPO (set MTV3_REPO) — rootfs without SeeSharp"
    exit 0
fi

# автостарт и скрипты платы
install -D -m 0755 "$BOARD/S60mtv3" "$TARGET_DIR/etc/init.d/S60mtv3"
for f in init_mp.sh mtv3_network.sh mtv3_usb_gadget.sh; do
    install -D -m 0755 "$BOARD/$f" "$TARGET_DIR/usr/bin/$f"
done

# демон камеры
if [ -x "$BOARD/mtv3_cam_daemon" ]; then
    install -D -m 0755 "$BOARD/mtv3_cam_daemon" "$TARGET_DIR/usr/bin/mtv3_cam_daemon"
else
    log "WARNING: $BOARD/mtv3_cam_daemon not built (mtv3-daemon); S60mtv3 will have nothing to start"
fi

# приложение SeeSharp + конфиг + модели
mkdir -p "$TARGET_DIR/opt/seesharp"
if [ -x "$APP/mainCV" ]; then
    install -m 0755 "$APP/mainCV" "$TARGET_DIR/opt/seesharp/mainCV"
    install -m 0644 "$APP/config.json" "$TARGET_DIR/opt/seesharp/config.json"
    for f in "$MODELS"/*.rknn "$MODELS"/*.names "$MODELS"/*.classes.json; do
        [ -f "$f" ] && install -m 0644 "$f" "$TARGET_DIR/opt/seesharp/"
    done
    log "installed mainCV, config.json, $(ls "$TARGET_DIR/opt/seesharp" | wc -l) files in /opt/seesharp"
else
    log "WARNING: $APP/mainCV not built (mtv3-cmake); rootfs without SeeSharp application"
fi

# S60mtv3 сам останавливает ispserver/aiserver/uvc_app; автозапуск aicamera.sh в
# oem_mtv3/RkLunch.sh уже выключен, второй камерный стек не стартует.
exit 0
