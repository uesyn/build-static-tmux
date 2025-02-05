FROM alpine as tmux
ENV TMUX_VERSION=3.3a
RUN apk add curl bash git alpine-sdk libevent-static ncurses-static autoconf automake libevent-dev ncurses-dev byacc utf8proc-dev
RUN curl -L -o tmux.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
RUN tar xzvf tmux.tar.gz && \
    cd tmux-${TMUX_VERSION} && \
    curl -sSfL https://raw.githubusercontent.com/z80oolong/tmux-eaw-fix/master/tmux-${TMUX_VERSION}-fix.diff | patch -u && \
    ./configure --enable-static --enable-utf8proc && \
    make && \
    make install

FROM scratch
COPY --from=tmux /usr/local/bin/tmux /tmux
