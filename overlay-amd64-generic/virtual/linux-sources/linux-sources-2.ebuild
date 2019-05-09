# Copyright 2019 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Chrome OS Kernel virtual package"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

IUSE_KERNEL_VERS=(
    kernel-4_19
)
IUSE="kernel_sources ${IUSE_KERNEL_VERS[*]}"
REQUIRED_USE="?? ( ${IUSE_KERNEL_VERS[*]} )"

RDEPEND="
    !sys-kernel/chromeos-kernel-4_19
    kernel-4_19? ( sys-kernel/chromiumos-kernel-4_19-amd64-generic[kernel_sources=] )
"

# Add blockers so when migrating between USE flags, the old version gets
# unmerged automatically.
RDEPEND+="
    $(for v in "${IUSE_KERNEL_VERS[@]}"; do echo "!${v}? ( !sys-kernel/chromiumos-${v}-amd64-generic )"; done)
"

# Default to the 4.14 kernel if none has been selected.
RDEPEND_DEFAULT="sys-kernel/chromiumos-kernel-4_19-amd64-generic"
# Here be dragons!
RDEPEND+="
    $(printf '!%s? ( ' "${IUSE_KERNEL_VERS[@]}")
    ${RDEPEND_DEFAULT}
    $(printf '%0.s) ' "${IUSE_KERNEL_VERS[@]}")
"
