#!/bin/bash

if [[ "$(whoami)" != "root" ]]
then
    echo "ERROR: Must run with sudo."
    exit 1
fi

SOURCE_BASE=${1:-NULL}
TARGET_BASE=${2:-NULL}

if [ ! -f "${SOURCE_BASE}" ]
then
    echo "ERROR: Not a valid source image."
    exit 1
fi

if [ ! -f "${TARGET_BASE}" ]
then
    echo "ERROR: Not a valid target image."
    exit 1
fi

CHRONOS_HOME=/home/chronos
BACKUP_MOUNT=${CHRONOS_HOME}/backup
SOURCE_MOUNT=${CHRONOS_HOME}/source
TARGET_MOUNT=${CHRONOS_HOME}/target

rm -rf ${CHRONOS_HOME}
mkdir -p ${BACKUP_MOUNT}
mkdir -p ${SOURCE_MOUNT}
mkdir -p ${TARGET_MOUNT}

SOURCE_FILE=${SOURCE_BASE}
TARGET_FILE=molium2chrome.bin
cp ${TARGET_BASE} ${TARGET_FILE}

echo "Mount source image as RO ..."
SOURCE_IMAGE=`losetup --find --partscan --show "${SOURCE_FILE}"`
echo "Source image mounted at ${SOURCE_IMAGE} ..."
mount "${SOURCE_IMAGE}"p3 ${SOURCE_MOUNT} -o ro
if [ ! $? -eq 0 ]
then
    echo "ERROR: ${SOURCE_FILE} does not have a system partition"
    exit 1
fi

echo "Mount target image as RW ..."
TARGET_IMAGE=`losetup --find --partscan --show "${TARGET_FILE}"`
echo "Target image mounted at ${TARGET_IMAGE} ..."
mount "${TARGET_IMAGE}"p3 ${TARGET_MOUNT} -o rw
if [ ! $? -eq 0 ]
then
    echo "ERROR: ${TARGET_FILE} does not have a system partition"
    exit 1
fi


echo "Backing up essential target files ..."
BACKUP_DRIVERS=(
    etc/fonts/conf.d/10-sub-pixel-rgb.conf
    etc/fonts/conf.d/11-lcdfilter-default.conf
    etc/shadow
    usr/bin/allow_sata_min_power
    usr/lib64/dri/i965_dri.so
    usr/lib64/dri/kms_swrast_dri.so
    usr/lib64/dri/nouveau_dri.so
    usr/lib64/dri/r300_dri.so
    usr/lib64/dri/r600_dri.so
    usr/lib64/dri/swrast_dri.so
    usr/lib64/va/drivers/i965_drv_video.so
    usr/share/power_manager/legacy_power_button
)

BACKUP_HAVEGED=(
    etc/init/haveged.conf
    usr/lib64/libhavege.so
    usr/lib64/libhavege.so.1
    usr/lib64/libhavege.so.1.1.0
    usr/sbin/haveged
)

BACKUP_SWTPM=(
    etc/init/swtpm.conf
    etc/swtpm-localca.options
    etc/swtpm-localca.conf
    etc/swtpm_setup.conf
    usr/bin/swtpm
    usr/bin/swtpm_bios
    usr/bin/swtpm_cuse
    usr/bin/swtpm_ioctl
    usr/bin/swtpm_setup
    usr/bin/swtpm_setup.sh
    usr/lib64/libseccomp.so
    usr/lib64/libseccomp.so.2
    usr/lib64/libseccomp.so.2.3.3
    usr/lib64/libtpms.so
    usr/lib64/libtpms.so.0
    usr/lib64/libtpms.so.0.7.0
    usr/lib64/swtpm/libswtpm_libtpms.so
    usr/lib64/swtpm/libswtpm_libtpms.so.0
    usr/lib64/swtpm/libswtpm_libtpms.so.0.0.0
    usr/share/swtpm/swtpm-create-tpmca
    usr/share/swtpm/swtpm-localca
)

for FILE in ${BACKUP_DRIVERS[@]} ${BACKUP_HAVEGED[@]} ${BACKUP_SWTPM[@]}
do
    mkdir -p ${BACKUP_MOUNT}/$(dirname ${FILE})
    cp -P ${TARGET_MOUNT}/${FILE} ${BACKUP_MOUNT}/${FILE}
done

BACKUP_FOLDERS=(
    boot
    lib/firmware
    lib/modules
)

for FOLDER in ${BACKUP_FOLDERS[@]}
do
    mkdir -p ${BACKUP_MOUNT}/$(dirname ${FOLDER})
    cp -P -R ${TARGET_MOUNT}/${FOLDER}/ ${BACKUP_MOUNT}/$(dirname ${FOLDER})/
done

echo "Clean the target system partition ..."
rm -rf ${TARGET_MOUNT}/*

echo "Copy the source system partition to the target system partition ..."
cp -a ${SOURCE_MOUNT}/* ${TARGET_MOUNT}

echo "Remove unneeded files ..."
REMOVE_FILES=(
    etc/camera/camera_characteristics.conf
    etc/cras/board.ini
    etc/cras/dsp.ini
    etc/cras/kbl_r5514_5663_max
    etc/fonts/conf.d/10-no-sub-pixel.conf
    etc/gesture/50-touchpad-cmt-eve.conf
    etc/init/arc-camera.conf
    etc/init/chromeos-disk-firmware-update.conf
    etc/init/cr50-metrics.conf
    etc/init/cr50-result.conf
    etc/init/cr50-update.conf
    etc/init/cros-camera.conf
    etc/init/cros-camera-algo.conf
    etc/init/cros-ec-accel.conf
    etc/init/iwlwifi-dump-processor.conf
    etc/init/temp_logger.conf
    etc/modprobe.d/alsa-skl.conf
    etc/udev/hwdb.d/61-eve-keyboard.hwdb
    etc/shadow
    lib/firmware
    lib/modules
    lib/udev/rules.d/50-camera.rules
    lib/udev/rules.d/61-eve-keyboard.rules
    lib/udev/rules.d/85-iwl-fw-dump.rules
    lib/udev/rules.d/93-powerd-tags-keyboard-side-buttons.rules
    lib/udev/rules.d/99-cr50.rules
    lib/udev/rules.d/99-cros-ec-accel.rules
    lib/udev/accelerometer-init.sh
    lib/udev/light-init.sh
    opt/google/cr50
    opt/google/disk
    opt/google/dsm
    opt/google/kbl-rt5514-hotword-support
    opt/google/touch
    opt/intel
    root/.force_update_firmware
    usr/bin/arc_camera_service
    usr/bin/cros_camera_algo
    usr/bin/cros_camera_service
    usr/bin/iwlwifi_dump_processor
    usr/bin/st_flash
    usr/lib64/dri/i965_dri.so
    usr/lib64/va/drivers/iHD_drv_video.so
    usr/sbin/board-postinst
    usr/sbin/board-setgoodfirmware
    usr/sbin/chromeos-disk-firmware-update.sh
    usr/sbin/chromeos-firmwareupdate
    usr/sbin/chromeos-setgoodfirmware
    usr/sbin/cros_spi_descriptor
    usr/sbin/ec_battery_wa
    usr/sbin/wacom_flash
    usr/share/alsa/ucm/kbl_r5514_5663_max
    usr/share/chromeos-assets/autobrightness
    usr/share/chromeos-assets/genius_app/embedded_device_content
    usr/share/chromeos-assets/regulatory_labels
    usr/share/cros/cr50-get-name.sh
    usr/share/cros/cr50-reset.sh
    usr/share/cros/cr50-set-board-id.sh
    usr/share/cros/cr50-update.sh
    usr/share/cros/cr50-verify-ro.sh
    usr/share/policy/cros-camera.policy
    usr/share/policy/cros-camera-algo.policy
    usr/share/policy/fw_parser.policy
    usr/share/power_manager/board_specific
    usr/share/power_manager/allow_docked_mode
    usr/share/power_manager/has_ambient_light_sensor
    usr/share/power_manager/has_keyboard_backlight
)

for FILE in ${REMOVE_FILES[@]}
do
    if [ -e "${TARGET_MOUNT}/${FILE}" ]
    then
        rm -rf ${TARGET_MOUNT}/${FILE}
    else
        echo "WARNING: ${FILE} not found!"
    fi
done

echo "Restore target backup files ..."
RESTORE_FOLDERS=`ls -1 ${BACKUP_MOUNT}`
for FOLDER in ${RESTORE_FOLDERS[@]}
do
    cp -P -R ${BACKUP_MOUNT}/${FOLDER} ${TARGET_MOUNT}/
done

echo "Disable SELinux ..."
sed -i \
    -e "s|SELINUX=enforcing|SELINUX=permissive|" \
        ${TARGET_MOUNT}/etc/selinux/config

echo "Ensure all changes are saved to image ..."
sync

echo "Unmount system partitions ..."
umount ${SOURCE_MOUNT}
umount ${TARGET_MOUNT}

echo "Unmount system images ..."
for LOOP in $(losetup --list --output BACK-FILE --noheadings)
do
    if [[ "${LOOP}" =~ "${SOURCE_FILE}" ]] || [[ "${LOOP}" =~ "${TARGET_FILE}" ]]
    then
        losetup --detach $(losetup --associated ${LOOP} | cut -d ':' -f 1)
    fi
done

echo "Done!"
