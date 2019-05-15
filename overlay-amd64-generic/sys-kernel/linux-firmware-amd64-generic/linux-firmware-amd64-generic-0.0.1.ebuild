# Copyright (c) 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"
CROS_WORKON_COMMIT="941f56995d2b7de0075362547e6fdb9da6d4d87e"
CROS_WORKON_TREE="eb0d001c1edf66275df96e64b7e89a4fe4258e35"
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
