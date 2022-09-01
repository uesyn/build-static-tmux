#!/bin/bash

set -e -o pipefail

export TMUX_VERSION=3.3a
export BREW_PREFIX=$(brew --prefix)
export SCRIPT_ROOT="$(cd $(dirname $0); pwd)"

rm -rf libevent
mkdir -p libevent
cd libevent
export LIBEVENT_VERSION=2.1.12
curl -sSLf -o - https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz | tar xzf - --strip-component=1
./configure --prefix=${SCRIPT_ROOT}/opt --disable-shared --disable-openssl CFLAGS="-arch arm64 -arch x86_64"
make && make install
cd ..

export NCURSES_VERSION=6.3
rm -rf ncurses
mkdir -p ncurses
cd ncurses
curl -sSLf -o - http://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz | tar xzf - --strip-component=1
./configure --prefix=${SCRIPT_ROOT}/opt \
--without-tests \
--without-progs \
--without-database \
--without-manpages \
--with-default-terminfo-dir=/usr/share/terminfo \
--with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo" \
CFLAGS="-arch arm64 -arch x86_64"
make && make install
cd ..

rm -rf tmux
mkdir -p tmux
cd tmux
curl -sSLf -o - https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz | tar xzf - --strip-component=1
#./configure --prefix=${BREW_PREFIX} --disable-utf8proc \
./configure --prefix=${SCRIPT_ROOT} --disable-utf8proc \
  CFLAGS="-I${SCRIPT_ROOT}/opt/include -arch arm64 -arch x86_64" \
  LDFLAGS="-L${SCRIPT_ROOT}/opt/lib" \
  CPPFLAGS="-I${SCRIPT_ROOT}/opt/include" \
  LIBEVENT_LIBS="-L${SCRIPT_ROOT}/opt/lib -levent" \
  LIBEVENT_CFLAGS="-I${SCRIPT_ROOT}/opt/include" \
  LIBNCURSES_CFLAGS="-I${SCRIPT_ROOT}/opt/include" \
  LIBNCURSES_LIBS="-L${SCRIPT_ROOT}/opt/lib -lncurses" \
  LIBTINFO_CFLAGS="-I${SCRIPT_ROOT}/opt/include/ncurses" \
  LIBTINFO_LIBS="-L${SCRIPT_ROOT}/opt/lib -ltinfo" --enable-static
make
cd ..
