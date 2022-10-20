ARG DEBIAN_VERSION=11
FROM debian:${DEBIAN_VERSION} as tmux
ENV TMUX_VERSION=3.3a
RUN apt update && \
    apt install -y --no-install-recommends \
        curl \
	ca-certificates \
	apt-utils \
	libevent-dev ncurses-dev build-essential bison pkg-config
RUN curl -L -o tmux.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz && \
    tar xzvf tmux.tar.gz && \
    cd tmux* && \
    ./configure --enable-static && \
    make && make install

FROM scratch
COPY --from=tmux /usr/local/bin/tmux /tmux
