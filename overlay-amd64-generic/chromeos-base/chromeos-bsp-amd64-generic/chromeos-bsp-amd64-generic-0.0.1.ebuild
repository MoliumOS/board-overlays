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

# Havege RNG populator
RDEPEND="
    ${RDEPEND}
    sys-apps/haveged
"

DEPEND="${RDEPEND}"
