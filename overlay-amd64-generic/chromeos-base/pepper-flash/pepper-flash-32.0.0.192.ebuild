# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit git-r3

DESCRIPTION="Pepper Flash Player"
HOMEPAGE="https://get.adobe.com/flashplayer/"

EGIT_REPO_URI="https://github.com/somulimo/pepper-flash.git"
EGIT_BRANCH="master"
EGIT_COMMIT="8d1d93a86e18f60637f72277ac60e6ff3bfe094f"

LICENSE="no-source-code"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
    chromeos-base/chromeos-chrome
"
DEPEND="${RDEPEND}"

src_install() {
    exeinto /opt/google/chrome/pepper
    doexe libpepflashplayer.so

    insinto /opt/google/chrome/pepper
    doins "${FILESDIR}"/pepper-flash.info
}
