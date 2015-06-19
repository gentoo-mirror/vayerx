# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
USE_RUBY="ruby19"

inherit ruby-fakegem eutils

DESCRIPTION="Simple client for imgsrc.ru photo-hosting."
HOMEPAGE="https://github.com/vayerx/imgsrc"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~x86"
IUSE=""

RDEPEND="
	>=dev-ruby/libxml-2.2
	>=dev-ruby/optiflag-0.7
	>=dev-ruby/parseconfig-1.0.4
"
