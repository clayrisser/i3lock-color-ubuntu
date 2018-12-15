#!/bin/bash

version=$1

git clean -fXd

git clone https://github.com/eBrnd/i3lock-color.git build
cd build
message=$(git log -1 --pretty=%B)
cd ..
rm -rf build/.git
tar -czvf build.tar.gz build
rm -rf build

bzr dh-make build $version build.tar.gz

rm -rf build/debian
cp -r debian build/debian

cd build
bzr add .
bzr commit -m "$message"
bzr builddeb -- -us -uc
cd ..

lesspipe *.deb
lintian *.dsc
lintian *.deb

cd build
bzr builddeb -- -nc -us -uc
bzr builddeb -S
cd ..
