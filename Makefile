.POSIX:
export ROOTDIR ?= $(eval ROOTDIR := $(shell git rev-parse --show-toplevel))$(ROOTDIR)
include $(ROOTDIR)/make.mk

.DEFAULT_GOAL := build

# Upstream version from the topmost debian/changelog entry.
I3LOCK_COLOR_VERSION ?= $(eval I3LOCK_COLOR_VERSION := $(shell sed -n '1s/^i3lock-color .\([^-]*\)-.*$$/\1/p' debian/changelog))$(I3LOCK_COLOR_VERSION)
BUILD_IMAGE ?= ubuntu:26.04

ASDF_VERSION ?= v0.20.0

.PHONY: prepare prepare/asdf
prepare: sudo
	@command -v asdf >/dev/null 2>&1 || $(MAKE) prepare/asdf
	@awk '!/^#/ && NF {print $$1}' .tool-versions | \
		while read t; do asdf plugin add "$$t" 2>/dev/null || true; done
	@rcfile=$$(mktemp); \
		{ asdf install 2>&1; echo $$? >$$rcfile; } | grep --line-buffered -v 'is already installed' || true; \
		rc=$$(cat $$rcfile); rm -f $$rcfile; exit $$rc
prepare/asdf:
	@command -v brew >/dev/null 2>&1 && brew install asdf || { \
		o=$$(uname | tr A-Z a-z); a=$$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/'); \
		curl -fsSL "https://github.com/asdf-vm/asdf/releases/download/$(ASDF_VERSION)/asdf-$(ASDF_VERSION)-$$o-$$a.tar.gz" \
			| $(SUDO) tar -xz -C /usr/local/bin asdf; \
	}

.PHONY: configure
configure:
	@for cmd in $(DOCKER) $(GIT) $(SHFMT); do \
		command -v $$cmd >/dev/null 2>&1 || { echo "$$cmd is missing, run \`make prepare\`"; exit 1; }; \
	done

.PHONY: build
build: configure
	@mkdir -p dist
	@$(DOCKER) run --rm -v $(ROOTDIR):/repo:ro -v $(ROOTDIR)/dist:/out \
		$(BUILD_IMAGE) sh /repo/scripts/build-package.sh $(I3LOCK_COLOR_VERSION) binary

.PHONY: source
source: configure
	@mkdir -p dist
	@$(DOCKER) run --rm -v $(ROOTDIR):/repo:ro -v $(ROOTDIR)/dist:/out \
		$(BUILD_IMAGE) sh /repo/scripts/build-package.sh $(I3LOCK_COLOR_VERSION) source

.PHONY: format
format: configure
	@$(SHFMT) -w scripts

.PHONY: lint
lint: source
	@$(SHFMT) -d scripts
	@$(DOCKER) run --rm -v $(ROOTDIR)/dist:/dist:ro $(BUILD_IMAGE) sh -c '\
		export DEBIAN_FRONTEND=noninteractive && \
		apt-get update -qq && \
		apt-get install -qq -y --no-install-recommends lintian >/dev/null && \
		lintian -i /dist/i3lock-color_$(I3LOCK_COLOR_VERSION)-*.dsc'

.PHONY: clean
clean:
	@rm -rf dist

.PHONY: purge
purge: clean
	@$(GIT) clean -fxd
