# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit systemd

DESCRIPTION="A simple entropy daemon using the HAVEGE algorithm"
HOMEPAGE="http://www.issihosts.com/haveged/"
SRC_URI="http://www.issihosts.com/haveged/${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="*"
IUSE="selinux static-libs"

DEPEND=""
RDEPEND="
    selinux? ( sec-policy/selinux-entropyd )
"

# threads are broken right now, but eventually
# we should add $(use_enable threads)
src_configure() {
    econf \
        $(use_enable static-libs static) \
        --bindir=/usr/sbin \
        --enable-nistest \
        --disable-threads
}

src_install() {
    default

    insinto /etc/init
    newins "${FILESDIR}"/haveged.conf haveged.conf
}
