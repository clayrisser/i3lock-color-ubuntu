CWD := $(shell pwd)
NAME := i3lock-color
REPO := https://github.com/eBrnd/i3lock-color.git
VERSION := 2.11
PPA := ppa:codejamninja/jam-os

.PHONY: all
all: clean

.PHONY: clean
clean:
	@rm -rf build/.git
	@git clean -fXd

.PHONY: clone
clone: build.tar.gz
build.tar.gz:
	@git clone $(REPO) build
	@cd build && echo `git log -1 --pretty=%B` > ../message
	@rm -rf build/.git
	@tar -czvf build.tar.gz build
	@rm -rf build

setup: clone build_$(VERSION).orig.tar.gz
build_$(VERSION).orig.tar.gz:
	@(sleep 5; xdotool key s)&
	@(sleep 8; xdotool key y)&
	@bzr dh-make build $(VERSION) build.tar.gz
	@rm -rf build/debian
	@cp -r src/debian build/debian
	@cd build && bzr add .
	@cd build && bzr commit -m "`cat ../message`"
	@rm message

.PHONY: test
test: setup
	@cd build && bzr builddeb -- -us -uc
	@lesspipe *.deb
	# @lintian *.dsc
	@lintian *.deb

.PHONY: build
build: test
	@cd build && bzr builddeb -- -nc -us -uc
	@cd build && bzr builddeb -S

.PHONY: publish
publish: build
	@dput $(PPA) $(NAME)_$(VERSION)-1_source.changes
