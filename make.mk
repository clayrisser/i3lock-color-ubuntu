MAKEFLAGS += --no-print-directory

# Recipes spawn fresh non-interactive shells that do not source the user's
# rc files, so the asdf shim dir is not on PATH unless we add it here.
export PATH := $(or $(ASDF_DATA_DIR),$(HOME)/.asdf)/shims:$(PATH)

# Tool defaults -- overridable via env.
GIT ?= git
DOCKER ?= docker
SHFMT ?= shfmt

SUDO ?= $(eval SUDO := $(shell command -v sudo >/dev/null && echo sudo))$(SUDO)

.PHONY: FORCE
FORCE:

.PHONY: sudo
sudo:
	@$(SUDO) true
