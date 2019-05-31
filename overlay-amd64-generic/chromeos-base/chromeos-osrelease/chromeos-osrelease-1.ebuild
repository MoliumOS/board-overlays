# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit osreleased

DESCRIPTION="OS Release"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
S="${WORKDIR}"

src_install() {
	do_osrelease_field "ID" "moliumos"
	do_osrelease_field "ID_LIKE" "chromiumos"
	do_osrelease_field "NAME" "Molium OS"
	do_osrelease_field "GOOGLE_CRASH_ID" "MoliumOS"
}
