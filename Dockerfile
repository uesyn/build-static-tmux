FROM ubuntu:20.04
ENV DEBIAN_FRONTEND noninteractiv
ENV TERM=xterm-256color
WORKDIR /work
COPY ./build-for-linux.sh .

RUN apt update && apt install -y git curl wget libevent-dev ncurses-dev build-essential bison pkg-config
RUN ./build-for-linux.sh