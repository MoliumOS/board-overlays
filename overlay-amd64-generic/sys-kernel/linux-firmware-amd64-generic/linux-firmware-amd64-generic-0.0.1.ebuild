# Copyright (c) 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="2ebc5d92b4cf7f151c0aefaf09b798f15ddeaf3f"
CROS_WORKON_TREE="b3284ca6e9401a3b02b10ebfd24ab055d90acf53"
CROS_WORKON_PROJECT="chromiumos/third_party/linux-firmware"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Firmware images from the upstream linux-fimware package"
HOMEPAGE="https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/"

SLOT="0"
KEYWORDS="*"

IUSE_LINUX_FIRMWARE=(
    rtl8188ee
)
IUSE="${IUSE_LINUX_FIRMWARE[@]/#/linux_firmware_}"
LICENSE="
    linux_firmware_rtl8188ee? ( no-source-code )
"
DEPEND="
    sys-kernel/linux-firmware
"
RDEPEND="${DEPEND}"

RESTRICT="binchecks strip test"

FIRMWARE_INSTALL_ROOT="/lib/firmware"

use_fw() {
	use linux_firmware_$1
}

doins_subdir() {
	# Avoid having this insinto command affecting later doins calls.
	local file
	for file in "${@}"; do
		(
		insinto "${FIRMWARE_INSTALL_ROOT}/${file%/*}"
		doins "${file}"
		)
	done
}

src_install() {
	local x
	insinto "${FIRMWARE_INSTALL_ROOT}"
	use_fw rtl8188ee && doins_subdir rtlwifi/rtl8188efw.bin
}
