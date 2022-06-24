FROM debian as builder
ENV DEBIAN_FRONTEND noninteractive
COPY build-static-tmux.sh /bin/build-static-tmux.sh
RUN apt update
RUN apt install -y wget libevent-dev ncurses-dev build-essential bison pkg-config
RUN /bin/build-static-tmux.sh

FROM scratch
COPY --from=builder /tmp/tmux-static/bin/tmux.linux-amd64.gz  /
COPY --from=builder /tmp/tmux-static/bin/tmux.linux-amd64.stripped.gz /
