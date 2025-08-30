#!/bin/bash -eu
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error when substituting.

build_package ()
{
  PACKAGE=$1

  cd $PACKAGE

  # Install build dependencies
  mk-build-deps -i -r -t "apt-get --no-install-recommends -y " -s sudo
  sudo apt-get remove -y $PACKAGE-build-deps

  # Build the package
  dpkg-buildpackage

  # Get binary package name
  VERSION=$(dpkg-parsechangelog -S Version)
  ARCH=$(sed -n 's/^Architecture: *//p' debian/control)
  if [ $ARCH = any ]
  then
    ARCH=$(dpkg-architecture -q DEB_BUILD_ARCH)
  fi
  DEB=${PACKAGE}_${VERSION}_$ARCH.deb

  # Install the binary package
  cd ..
  sudo dpkg -i $DEB
}

build_package binutils-m68k-atari-mintelf
build_package mintbin-m68k-atari-mintelf
build_package pkgconf-m68k-atari-mintelf
build_package gcc-m68k-atari-mintelf
build_package mintlib-m68k-atari-mintelf
build_package fdlibm-m68k-atari-mintelf
build_package gemlib-m68k-atari-mintelf
build_package ncurses-m68k-atari-mintelf
build_package zlib-m68k-atari-mintelf
build_package zstd-m68k-atari-mintelf
build_package gmp-m68k-atari-mintelf
build_package expat-m68k-atari-mintelf
build_package cross-mintelf-essential
build_package cflib-m68k-atari-mintelf
build_package gemma-m68k-atari-mintelf
build_package ldg-m68k-atari-mintelf
build_package readline-m68k-atari-mintelf
build_package mpfr-m68k-atari-mintelf
build_package sdl-m68k-atari-mintelf
build_package openssl-m68k-atari-mintelf
