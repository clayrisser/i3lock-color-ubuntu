#!/bin/sh
# Build the i3lock-color Debian source or binary package inside a container.
#
# Usage (via the root Makefile):
#   docker run --rm \
#     -v <repo>:/repo:ro \
#     -v <repo>/dist:/out \
#     ubuntu:26.04 sh /repo/scripts/build-package.sh <upstream-version> [source|binary]
#
# Build dependencies are resolved from debian/control with `apt-get build-dep`
# so this script never has to repeat the dependency list.
set -e

version="$1"
mode="${2:-binary}"
[ -n "$version" ] || {
	echo "usage: build-package.sh <upstream-version> [source|binary]" >&2
	exit 1
}

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
	build-essential ca-certificates curl devscripts dpkg-dev fakeroot

mkdir -p /build
cd /build
# Reuse an already-downloaded tarball from the output directory so repeat
# builds neither re-download nor fail when GitHub's asset host is unhappy.
if [ -f "/out/i3lock-color_${version}.orig.tar.gz" ]; then
	cp "/out/i3lock-color_${version}.orig.tar.gz" .
else
	curl -fsSL --retry 5 --retry-all-errors -o "i3lock-color_${version}.orig.tar.gz" \
		"https://github.com/Raymo111/i3lock-color/archive/refs/tags/${version}.tar.gz"
fi
tar -xzf "i3lock-color_${version}.orig.tar.gz"
cd "i3lock-color-${version}"
cp -r /repo/debian .

apt-get build-dep -y ./

if [ "$mode" = source ]; then
	dpkg-buildpackage -S -us -uc -d
else
	dpkg-buildpackage -b -us -uc -d
fi

cd /build
for f in i3lock-color[-_]*; do
	[ -f "$f" ] && cp "$f" /out/
done
ls -la /out
