# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit go-module

RESTRICT="mirror"
EGO_PN="github.com/${PN}/${PN}"
EGO_VENDOR=(
	"github.com/alexbrainman/sspi 4729b3d4d8581b2db83864d1018926e4154f9406"
	"github.com/avast/retry-go v2.4.2"
	"github.com/dpotapov/go-spnego c2c609116ad04b25367e2789f273aaf8d1c263da"
	"github.com/git-lfs/gitobj v1.4.1"
	"github.com/git-lfs/go-netrc e0e9ca483a18"
	"github.com/git-lfs/go-ntlm c5056e7fa066"
	"github.com/git-lfs/wildmatch v1.0.4"
	"github.com/inconshreveable/mousetrap v1.0.0"
	"github.com/jcmturner/gofork v1.0.0"
	"github.com/jcmturner/gokrb5 v7.3.0"
	"github.com/kr/pty v1.1.8"
	"github.com/mattn/go-isatty v0.0.4"
	"github.com/olekukonko/ts 78ecb04241c0"
	"github.com/pkg/errors c605e284fe17"
	"github.com/rubyist/tracerx 787959303086"
	"github.com/spf13/cobra v0.0.3"
	"github.com/spf13/pflag v1.0.3"
	"github.com/ssgelm/cookiejarparser v1.0.1"
	"github.com/stretchr/testify v1.2.2"
	"github.com/xeipuuv/gojsonpointer 4e3ac2762d5f"
	"github.com/xeipuuv/gojsonreference bd5ef7bd5415"
	"github.com/xeipuuv/gojsonschema 6b67b3fab74d"
	"golang.org/x/net 83d349e8ac1aeaa6e5b8669cbd094dccb2a7661d github.com/golang/net"
	"golang.org/x/sync 37e7f081c4d4c64e13b10787722085407fe5d15f github.com/golang/sync"
	"golang.org/x/sys 97732733099d6a942a73b889770774366de963ed github.com/golang/sys"
	"gopkg.in/jcmturner/goidentity.v3 v3.0.0 github.com/jcmturner/goidentity"
	"gopkg.in/jcmturner/gokrb5.v7 v7.3.0 github.com/jcmturner/gokrb5"
	"gopkg.in/jcmturner/rpc.v1 v1.1.0 github.com/jcmturner/rpc"
)

SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	$(go-module_vendor_uris)"

DESCRIPTION="Command line extension and specification for managing large files with Git"
HOMEPAGE="https://git-lfs.github.com/"
KEYWORDS="~amd64"

LICENSE="MIT BSD BSD-2 BSD-4 Apache-2.0"
SLOT="0"
IUSE="+doc"

DEPEND="doc? ( app-text/ronn )"

RDEPEND="dev-vcs/git"

src_compile() {
	GOCACHE="${T}/go-cache" go build -work -o "${PN}" git-lfs.go || die

	if use doc; then
		ronn docs/man/*.ronn || die "man building failed"
	fi
}

src_install() {
	dobin git-lfs
	use doc && doman docs/man/*.1
}
