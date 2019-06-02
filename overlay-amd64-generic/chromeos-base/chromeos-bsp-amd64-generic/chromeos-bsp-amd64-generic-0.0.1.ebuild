# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit appid
inherit cros-unibuild

DESCRIPTION="Pulls in any necessary ebuilds as dependencies or portage actions."

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64 x86"
IUSE=""
S="${WORKDIR}"

# Add dependencies on other ebuilds from within this board overlay
RDEPEND="
    chromeos-base/chromeos-config
"

# Software TPM
RDEPEND="
    ${RDEPEND}
    app-crypt/swtpm
"

# For my sanity
RDEPEND="
    ${RDEPEND}
    app-editors/nano
"

# Additional Chrome OS
RDEPEND="
    ${RDEPEND}
    chromeos-base/chromeos-osrelease
    chromeos-base/google-sans-fonts
    chromeos-base/monotype-fonts
    chromeos-base/pepper-flash
"

# Havege RNG populator
RDEPEND="
    ${RDEPEND}
    sys-apps/haveged
"

# Additional kernel firmware
RDEPEND="
    ${RDEPEND}
    sys-kernel/linux-firmware-amd64-generic
"

DEPEND="${RDEPEND}"

src_install() {
    doappid "{2AF924A7-982F-42B3-B8FE-B063CCD5A4C4}" "CHROMEBOX"
}
