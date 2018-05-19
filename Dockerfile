FROM ubuntu:16.04

RUN apt-get update -y && apt-get install -y \
  make \
  libc6-dev \
  clang-3.8 \
  curl \
  libedit-dev \
  libpython2.7 \
  libicu-dev \
  libssl-dev \
  libxml2 \
  tzdata \
  git \
  libcurl4-openssl-dev \
  pkg-config \
  sudo \
  locales \
  python \
  vim \
  cmake \
  build-essential \
  ruby-dev \
  && update-alternatives --quiet --install /usr/bin/clang clang /usr/bin/clang-3.8 100 \
  && update-alternatives --quiet --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100 \
  && rm -r /var/lib/apt/lists/*    

# Swift Installation
# Everything up to here should cache nicely between Swift versions, assuming dev dependencies change little
ARG SWIFT_PLATFORM=ubuntu16.04
ARG SWIFT_BRANCH=swift-4.1.1-release
ARG SWIFT_VERSION=swift-4.1.1-RELEASE

ENV SWIFT_PLATFORM=$SWIFT_PLATFORM \
    SWIFT_BRANCH=$SWIFT_BRANCH \
    SWIFT_VERSION=$SWIFT_VERSION

# Download GPG keys, signature and Swift package, then unpack, cleanup and execute permissions for foundation libs
RUN SWIFT_URL=https://swift.org/builds/$SWIFT_BRANCH/$(echo "$SWIFT_PLATFORM" | tr -d .)/$SWIFT_VERSION/$SWIFT_VERSION-$SWIFT_PLATFORM.tar.gz \
    && curl -fSsL $SWIFT_URL -o swift.tar.gz \
    && curl -fSsL $SWIFT_URL.sig -o swift.tar.gz.sig \
    && export GNUPGHOME="$(mktemp -d)" \
    && set -e; \
        for key in \
      # pub   rsa4096 2017-11-07 [SC] [expires: 2019-11-07]
      # 8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4
      # uid           [ unknown] Swift Automatic Signing Key #2 <swift-infrastructure@swift.org>
          8513444E2DA36B7C1659AF4D7638F1FB2B2B08C4 \
      # pub   4096R/91D306C6 2016-05-31 [expires: 2018-05-31]
      #       Key fingerprint = A3BA FD35 56A5 9079 C068  94BD 63BC 1CFE 91D3 06C6
      # uid                  Swift 3.x Release Signing Key <swift-infrastructure@swift.org>
          A3BAFD3556A59079C06894BD63BC1CFE91D306C6 \
      # pub   4096R/71E1B235 2016-05-31 [expires: 2019-06-14]
      #       Key fingerprint = 5E4D F843 FB06 5D7F 7E24  FBA2 EF54 30F0 71E1 B235
      # uid                  Swift 4.x Release Signing Key <swift-infrastructure@swift.org>          
          5E4DF843FB065D7F7E24FBA2EF5430F071E1B235 \
        ; do \
          gpg --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
        done \
    && gpg --batch --verify --quiet swift.tar.gz.sig swift.tar.gz \
    && tar -xzf swift.tar.gz --directory / --strip-components=1 \
    && rm -r "$GNUPGHOME" swift.tar.gz.sig swift.tar.gz \
    && chmod -R o+r /usr/lib/swift 

# Print Installed Swift Version
RUN swift --version

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
