# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit git-r3

DESCRIPTION="Chrome OS-specific assets"

EGIT_REPO_URI="https://github.com/moliumos/chromeos-assets.git"
EGIT_BRANCH="master"
EGIT_COMMIT="67d83d77ebaf04317fa9c8c88798c1636f12dd0a"

LICENSE="no-source-code"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_install() {
    insinto /usr/share/chromeos-assets/wallpaper
    doins -r wallpaper/*
}
