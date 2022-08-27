FROM alpine:3.16.2
ENV TMUX_VERSION=3.3a
ENV NCURSES_VERSION=6.3
ENV LIBEVENT_VERSION=2.1.12
ENV INSTALL_PREFIX=/usr/local
ENV ZIG_VERSION=0.10.0-dev.3685+dae7aeb33
ARG HOST=x86_64
ENV TARGET=${HOST}-linux-musl

RUN apk add --no-cache alpine-sdk ncurses bison xz
ENV PATH=$PATH:/opt/zig
ENV CC="zig cc --target=${TARGET}"
WORKDIR /opt/zig
RUN curl -sSLf -o - https://ziglang.org/builds/zig-linux-x86_64-${ZIG_VERSION}.tar.xz | tar xJf - --strip-component=1

WORKDIR /work/libevent
RUN curl -sSLf -o - https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable/libevent-${LIBEVENT_VERSION}-stable.tar.gz | tar xzf - --strip-component=1
RUN ./configure --prefix=${INSTALL_PREFIX} --disable-shared --disable-openssl --host=${HOST}
RUN make && make install

WORKDIR /work/ncurses
RUN curl -sSLf -o - http://ftp.gnu.org/gnu/ncurses/ncurses-${NCURSES_VERSION}.tar.gz | tar xzf - --strip-component=1
RUN ./configure --prefix=${INSTALL_PREFIX} \
    --without-tests \
    --disable-stripping \
    --without-tests \
    --without-progs \
    --without-manpages \
    --host=${HOST} \
    --with-default-terminfo-dir=/usr/share/terminfo \
    --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo"
RUN make && make install

WORKDIR /work/tmux
RUN curl -sSLf -o - https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz | tar xzf - --strip-component=1
RUN CFLAGS="-I${INSTALL_PREFIX}/include" \
    LDFLAGS="-L${INSTALL_PREFIX}/lib" \
    CPPFLAGS="-I${INSTALL_PREFIX}/include" \
    LIBEVENT_LIBS="-L${INSTALL_PREFIX}/lib -levent" \
    LIBNCURSES_CFLAGS="-I${INSTALL_PREFIX}/include/ncurses" \
    LIBNCURSES_LIBS="-L${INSTALL_PREFIX}/lib -lncurses" \
    LIBTINFO_CFLAGS="-I${INSTALL_PREFIX}/include/ncurses" \
    ./configure --prefix=${INSTALL_PREFIX} --enable-static --host=${HOST}
RUN make && make install
