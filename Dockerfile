FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y \
  sudo \
  locales \
  git \
  python \
  curl \
  vim \
  pkg-config \
  cmake \
  build-essential \
  ruby-dev

# Install rmate
RUN curl -Lo /bin/rmate https://raw.github.com/textmate/rmate/master/bin/rmate
RUN chmod a+x /bin/rmate

# Setup home environment
RUN useradd dev
RUN echo "dev:docker" | chpasswd
RUN usermod -a -G sudo dev
RUN mkdir /home/dev && chown -R dev: /home/dev
RUN mkdir -p /home/dev/bin /home/dev/lib /home/dev/include
RUN locale-gen
RUN localedef -i en_US -f UTF-8 en_US.UTF-8
ENV PATH /home/dev/bin:$PATH
ENV PKG_CONFIG_PATH /home/dev/lib/pkgconfig
ENV LD_LIBRARY_PATH /home/dev/lib

# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
# This is probably a Docker bug.
RUN mkdir /var/shared/
RUN touch /var/shared/placeholder
RUN chown -R dev:dev /var/shared
VOLUME /var/shared


WORKDIR /home/dev
ENV HOME /home/dev
ADD vimrc /home/dev/.vimrc
ADD vim /home/dev/.vim
ADD bash_profile /home/dev/.bashrc
ADD gitconfig /home/dev/.gitconfig
ADD colors /home/dev/.colors
ADD exports /home/dev/.exports
ADD aliases /home/dev/.aliases
ADD bash_prompt /home/dev/.bash_prompt

# Link in shared parts of the home directory
RUN ln -s /var/shared/.ssh
RUN ln -s /var/shared/.bash_history
RUN ln -s /var/shared/.maintainercfg

RUN chown -R dev: /home/dev
USER dev
