#!/bin/bash

if [[ "$(whoami)" != "root" ]]
then
    echo "ERROR: Must run with sudo."
    exit 1
fi

SOURCE_FILE=${1:-NULL}
TARGET_FILE=${2:-NULL}

if [ ! -f "${SOURCE_FILE}" ]
then
    echo "ERROR: Not a valid source image."
    exit 1
fi

if [ ! -f "${TARGET_FILE}" ]
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

echo "Mount source image as RO ..."
SOURCE_IMAGE=`losetup --find --partscan --show "${SOURCE_FILE}"`
mount "${SOURCE_IMAGE}"p3 ${SOURCE_MOUNT} -o loop,ro
if [ ! $? -eq 0 ]
then
    echo "ERROR: ${SOURCE_FILE} does not have a system partition"
fi

echo "Mount target image as RW ..."
TARGET_IMAGE=`losetup --find --partscan --show "${TARGET_FILE}"`
mount "${TARGET_IMAGE}"p3 ${TARGET_MOUNT} -o loop,rw
if [ ! $? -eq 0 ]
then
    echo "ERROR: ${TARGET_FILE} does not have a system partition"
fi


echo "Backing up essential target files ..."
BACKUP_DRIVERS=(
    etc/fonts/conf.d/10-sub-pixel-rgb.conf
    etc/fonts/conf.d/11-lcdfilter-default.conf
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
    etc/dptf
    etc/gesture/50-touchpad-cmt-eve.conf
    etc/init/chromeos-disk-firmware-update.conf
    etc/init/cr50-metrics.conf
    etc/init/cr50-result.conf
    etc/init/cr50-update.conf
    etc/init/cros-ec-accel.conf
    etc/init/dptf.conf
    etc/init/ecloggers.conf
    etc/init/timberslide.conf
    etc/init/iwlwifi-dump-processor.conf
    etc/udev/hwdb.d/61-eve-keyboard.hwdb
    lib/udev/accelerometer-init.sh
    lib/udev/light-init.sh
    lib/udev/rules.d/61-eve-keyboard.rules
    lib/udev/rules.d/85-iwl-fw-dump.rules
    lib/udev/rules.d/99-cr50.rules
    lib/udev/rules.d/99-cros-ec-accel.rules
    opt/google/cr50
    opt/google/touch
    opt/intel
    root/.force_update_firmware
    usr/bin/esif_ufd
    usr/bin/timberslide
    usr/bin/iwlwifi_dump_processor
    usr/lib64/Dptf.so
    usr/lib64/DptfPolicyActive.so
    usr/lib64/DptfPolicyCritical.so
    usr/lib64/DptfPolicyPassive.so
    usr/lib64/esif_cmp.so
    usr/lib64/esif_ws.so
    usr/sbin/board-postinst
    usr/sbin/board-setgoodfirmware
    usr/sbin/chromeos-disk-firmware-update.sh
    usr/sbin/chromeos-firmwareupdate
    usr/sbin/chromeos-setgoodfirmware
    usr/sbin/cros_spi_descriptor
    usr/sbin/ec_battery_wa
    usr/sbin/gsctool
    usr/sbin/usb_updater
    usr/sbin/wacom_flash
    usr/share/alsa/ucm/kbl_r5514_5663_max
    usr/share/chromeos-assets/autobrightness/model_params.json
    usr/share/cros/cr50-get-name.sh
    usr/share/cros/cr50-reset.sh
    usr/share/cros/cr50-set-board-id.sh
    usr/share/cros/cr50-update.sh
    usr/share/cros/cr50-verify-ro.sh
    usr/share/power_manager/board_specific
    usr/share/power_manager/has_ambient_light_sensor
    usr/share/power_manager/has_keyboard_backlight
)

for FILE in ${REMOVE_FILES[@]}
do
    rm -rf ${TARGET_MOUNT}/${FILE}
done

REMOVE_FOLDERS=(
    lib/modules
    lib/firmware
    usr/lib64/dri
    usr/lib64/va/drivers
)

for FOLDER in ${REMOVE_FOLDERS[@]}
do
    rm -rf ${TARGET_MOUNT}/${FOLDER}
done


echo "Restore target backup files ..."
RESTORE_FOLDERS=`ls -1 ${BACKUP_MOUNT}`
for FOLDER in ${RESTORE_FOLDERS[@]}
do
    cp -P -R ${BACKUP_MOUNT}/${FOLDER} ${TARGET_MOUNT}/
done

echo "Disable SELinux ..."
sed -i -e "s|SELINUX=enforcing|SELINUX=permissive|" ${TARGET_MOUNT}/etc/selinux/config

# Ensure all changes are saved
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

# Remove the working directory
# rm -rf ${CHRONOS_HOME}

echo "Done!"
