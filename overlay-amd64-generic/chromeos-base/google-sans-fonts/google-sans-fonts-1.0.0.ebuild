# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit font git-r3

DESCRIPTION="Google Sans Fonts"

EGIT_REPO_URI="https://github.com/somulimo/google-sans-fonts.git"
EGIT_BRANCH="master"
EGIT_COMMIT="7227e4529894b406277cf60cc27607d23b4ecde9"

LICENSE="no-source-code"
SLOT="0"
KEYWORDS="*"
IUSE=""

FONT_SUFFIX="ttf"
FONT_S="${S}"
FONTDIR="/usr/share/fonts/google-sans"


# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
    # call src_install() in font.eclass.
    font_src_install
}
