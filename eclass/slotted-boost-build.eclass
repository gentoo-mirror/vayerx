# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit eutils flag-o-matic multilib python-any-r1 toolchain-funcs versionator

MY_PV="$(replace_all_version_separators _)"

DESCRIPTION="A system for large project software construction, which is simple to use and powerful."
HOMEPAGE="http://www.boost.org/doc/tools/build/index.html"
SRC_URI="mirror://sourceforge/boost/boost_${MY_PV}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="~x86 ~amd64"
IUSE="examples python test"

RDEPEND="!<dev-libs/boost-1.34.0
	!<=dev-util/boost-build-1.35.0-r1"
DEPEND="${RDEPEND}
	python? ( ${PYTHON_DEPS} )
	test? ( sys-apps/diffutils )"

REQUIRED_USE="test? ( python )"

S="${WORKDIR}/boost_${MY_PV}/tools/build/v2"

MAJOR_PV="$(replace_all_version_separators _ ${SLOT})"

src_unpack() {
	tar xjpf "${DISTDIR}/${A}" boost_${MY_PV}/tools/build/v2 || die "unpacking tar failed"
}

src_prepare() {
	for patch in "${BOOST_BUILD_PATCHES[@]}"; do
		epatch "${FILESDIR}/${PN}-${patch}"
	done

	# Remove stripping option
	# Fix python components build on multilib systems, bug #496446
	cd "${S}/engine" || die
	sed -i \
		-e 's|-s\b||' \
		-e "/libpython/s/lib ]/$(get_libdir) ]/" \
		build.jam || die "sed failed"

	# Force regeneration
	rm jambase.c || die

	# This patch allows us to fully control optimization
	# and stripping flags when bjam is used as build-system
	# We simply extend the optimization and debug-symbols feature
	# with empty dummies called 'none'
	cd "${S}" || die
	sed -i \
		-e 's/\(off speed space\)/\1 none/' \
		-e 's/\(debug-symbols      : on off\)/\1 none/' \
		tools/builtin.jam || die "sed failed"
}

src_configure() {
	if use python; then
		# replace versions by user-selected one (TODO: fix this when slot-op
		# deps are available to always match the best version available)
		sed -i \
			-e "s|2.7 2.6 2.5 2.4 2.3 2.2|${EPYTHON#python}|" \
			engine/build.jam || die "sed failed"
	fi
}

src_compile() {
	cd engine || die

	local toolset

	if [[ ${CHOST} == *-darwin* ]]; then
		toolset=darwin
	else
		# Using boost's generic toolset here, which respects CC and CFLAGS
		toolset=cc
	fi

	# For slotting
	sed -i \
		-e "s|/usr/share/boost-build|/usr/share/boost-build-${MAJOR_PV}|" \
		Jambase || die "sed failed"

	CC=$(tc-getCC) ./build.sh ${toolset} -d+2 $(use_with python python "${EROOT}"/usr) || die "building bjam failed"
}

src_install() {
	newbin engine/bin.*/bjam bjam-${MAJOR_PV}
	newbin engine/bin.*/b2 b2-${MAJOR_PV}

	insinto /usr/share/boost-build-${MAJOR_PV}
	doins -r "${FILESDIR}/site-config.jam" \
		boost-build.jam bootstrap.jam build-system.jam user-config.jam *.py \
		build kernel options tools util

	rm "${ED}/usr/share/boost-build-${MAJOR_PV}/build/project.ann.py" || die "removing faulty python file failed"
	if ! use python; then
		find "${ED}/usr/share/boost-build-${MAJOR_PV}" -iname "*.py" -delete || die "removing experimental python files failed"
	fi

	dodoc {changes,hacking,release_procedure,notes/build_dir_option,notes/relative_source_paths}.txt

	if use examples; then
		dodoc -r example
		docompress -x "/usr/share/doc/${PF}/example"
	fi

	use python && python_optimize /usr/share/boost-build-${MAJOR_PV}
}

src_test() {
	cd test || die

	export TMP="${T}"

	DO_DIFF="${PREFIX}/usr/bin/diff" ${PYTHON} test_all.py

	if [[ -s test_results.txt ]]; then
		eerror "At least one test failed: $(<test_results.txt)"
		die "tests failed"
	fi
}
