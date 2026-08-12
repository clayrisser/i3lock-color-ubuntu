# i3lock-color-ubuntu

> Debian/Ubuntu packaging for [i3lock-color](https://github.com/Raymo111/i3lock-color)

![](assets/i3lock-color-ubuntu.png)

## Why this repository still exists

`i3lock-color` is **not** in the Debian or Ubuntu archive. Verified on
2026-08-12 against Ubuntu 24.04 (noble), Ubuntu 26.04 LTS (resolute), Debian 13
(trixie) and Debian unstable (sid): `apt-cache policy i3lock-color` returns
nothing in every one of them, and `apt-cache search i3lock` only turns up
`i3lock` and `i3lock-fancy`. The archive `i3lock` package is plain upstream
i3lock, which has none of the colour, blur or bar-indicator options this fork
adds.

So this packaging is still the only apt-installable route to i3lock-color on
Debian and Ubuntu, and it is worth maintaining.

## Relationship to the i3lock package

Upstream installs `/usr/bin/i3lock`, `/usr/share/man/man1/i3lock.1`,
`/etc/pam.d/i3lock` and the `i3lock` shell completions — the exact paths owned
by the archive `i3lock` package. i3lock-color is a drop-in replacement, so the
package declares `Conflicts`, `Replaces` and `Provides` on `i3lock`. Installing
it removes `i3lock`, and anything that depends on `i3lock` stays satisfied.

## Building

Everything builds inside a container; the only thing needed on the host is
Docker.

```sh
make          # binary package (.deb) into dist/
make source   # source package (.dsc, .debian.tar.xz) into dist/
make lint     # source package + lintian
make clean    # remove dist/
```

The build image defaults to `ubuntu:26.04`. Build for a different release by
overriding it, and adjust the changelog distribution to match:

```sh
make BUILD_IMAGE=ubuntu:24.04
make BUILD_IMAGE=debian:trixie
```

`scripts/build-package.sh` fetches the upstream tarball for the version in the
top `debian/changelog` entry, resolves the build dependencies straight from
`debian/control` with `apt-get build-dep`, and runs `dpkg-buildpackage`. A
tarball already sitting in `dist/` is reused rather than re-downloaded.

## Installing

```sh
sudo apt install ./dist/i3lock-color_*.deb
```

## Updating to a new upstream release

1. `uscan --report` (or check
   <https://github.com/Raymo111/i3lock-color/tags>) for a newer tag.
2. Add a changelog entry: `dch -v <version>-1 "New upstream release"`.
3. `make lint && make` and check the result.

## Layout

| path                      | purpose                                        |
| ------------------------- | ---------------------------------------------- |
| `debian/`                 | the Debian packaging                           |
| `scripts/build-package.sh`| containerized build entry point                |
| `Makefile`, `make.mk`     | build orchestration                            |

## License

The packaging is [MIT licensed](LICENSE). Upstream i3lock-color is BSD-3-clause;
see `debian/copyright` for the full breakdown.

[Jam Risser](https://codejam.ninja) © 2018
