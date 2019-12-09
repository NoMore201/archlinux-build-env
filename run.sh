#!/bin/bash

function run_as_user {
	CMD=$1
	/usr/bin/su -c "$CMD" \
		-s /bin/bash \
		-g builder builder
}



# check if variables are set
if [ -z ${PACKAGE_NAME} ]; then
	echo "PACKAGE_NAME: not specified"
	exit 1
fi
if [ -z ${REPO_SOURCE} ]; then
	echo "REPO_SOURCE: not specified (\"aur\" or \"official\")"
	exit 1
fi

if [ ${REPO_SOURCE} = "aur" ]; then
	run_as_user "git clone https://aur.archlinux.org/${PACKAGE_NAME}.git"
	cd $PACKAGE_NAME
	if [ ! -f PKGBUILD ]; then
		echo "No repo found for $PACKAGE_NAME"
		exit 1
	fi
fi
if [ ${REPO_SOURCE} = "official" ]; then
	run_as_user "asp update && asp checkout ${PACKAGE_NAME}"
	cd $PACKAGE_NAME/trunk
	if [ ! -f PKGBUILD ]; then
		echo "No repo found for $PACKAGE_NAME"
		exit 1
	fi
fi

# install dependencies in a subshell
(
source PKGBUILD
EXTRA_DEPENDS="${depends_x86_64[@]} ${depends_i686[@]}"
pacman -Syu --noconfirm --needed --asdeps \
	"${makedepends[@]}" \
	"${depends[@]}" \
	$EXTRA_DEPENDS
)

# build package
run_as_user "makepkg --nocheck --skippgpcheck --noconfirm"
cp *.pkg.tar.xz $OUTPUT_DIR
