# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils

DESCRIPTION="Shadowgrounds Survivor - data portion"
HOMEPAGE="http://shadowgroundssurvivor.com/"
SRC_URI="survivorUpdate1.run"

LICENSE="frozenbyte-eula"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
RESTRICT="fetch strip"

RDEPEND=""

S=${WORKDIR}

pkg_nofetch() {
	einfo "Fetch ${SRC_URI} and put it into ${DISTDIR}"
	einfo "See http://www.humblebundle.com/ for more info."
}

src_unpack() {
	unzip -q "${DISTDIR}/${A}"
}

src_install() {
	local dir="/usr/share/survivor"

	ebegin "Copying files from package ..."
		dodir "${dir}"/data
		dodir "${dir}"/survival
		cp -r data{1,2,3,4,5}.fbz data survival "${D}${dir}" || die "cp failed"
	eend 0
}
