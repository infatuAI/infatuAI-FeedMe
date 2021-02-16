FROM gentoo/portage:latest as portage
FROM gentoo/stage3-amd64:latest as gentoo
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo
LABEL maintainer=hello@drewpotter.com

ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB:en
ENV LC_ALL C
RUN echo eselect locale list
RUN . /etc/profile
RUN locale

RUN emerge sudo
RUN emerge dev-vcs/git
RUN emerge sys-fs/inotify-tools
RUN emerge =dev-lang/elixir-1.11.3

WORKDIR /postgres
RUN wget https://ftp.postgresql.org/pub/source/v13.2/postgresql-13.2.tar.gz
RUN tar -xvf postgresql-13.2.tar.gz
RUN cd postgresql-13.2 \
    && ./configure --prefix=/usr \
    && make \
    && make install \
    && make clean

WORKDIR /node
RUN wget http://nodejs.org/dist/v15.6.0/node-v15.6.0.tar.gz
RUN tar -xvf node-v15.6.0.tar.gz
RUN ls node-v15.6.0
RUN cd node-v15.6.0 \
    && ./configure --prefix=/usr \
    && make -j8 install  \
    && make clean

RUN wget https://www.npmjs.org/install.sh | sh

RUN npm install webpack webpack-cli -g

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install hex phx_new 1.5.7 --force

EXPOSE 4000