# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit font git-r3

DESCRIPTION="Monotype Fonts"

EGIT_REPO_URI="https://github.com/somulimo/monotype-fonts.git"
EGIT_BRANCH="master"
EGIT_COMMIT="e416f355097a979a4ad99cd2196a4c1e1908e8be"

LICENSE="no-source-code"
SLOT="0"
KEYWORDS="*"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${S}"
FONTDIR="/usr/share/fonts/monotype"


# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
    # call src_install() in font.eclass.
    font_src_install
}
