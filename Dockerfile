from ubuntu:14.04

run apt-get update -y && apt-get install -y \
  git \
  python \
  curl \
  vim \
  pkg-config \
  cmake \
  build-essential \
  ruby-dev

# Install rmate
run curl -Lo /bin/rmate https://raw.github.com/textmate/rmate/master/bin/rmate
run chmod a+x /bin/rmate

# Setup home environment
run useradd dev
run echo "dev:docker" | chpasswd
run usermod -a -G sudo dev
run mkdir /home/dev && chown -R dev: /home/dev
run mkdir -p /home/dev/bin /home/dev/lib /home/dev/include
run localedef -i en_US -f UTF-8 en_US.UTF-8
env PATH /home/dev/bin:$PATH
env PKG_CONFIG_PATH /home/dev/lib/pkgconfig
env LD_LIBRARY_PATH /home/dev/lib

# Create a shared data volume
# We need to create an empty file, otherwise the volume will
# belong to root.
# This is probably a Docker bug.
run mkdir /var/shared/
run touch /var/shared/placeholder
run chown -R dev:dev /var/shared
volume /var/shared


workdir /home/dev
env HOME /home/dev
add vimrc /home/dev/.vimrc
add vim /home/dev/.vim
add bash_profile /home/dev/.bashrc
add gitconfig /home/dev/.gitconfig
add colors /home/dev/.colors
add exports /home/dev/.exports
add aliases /home/dev/.aliases
add bash_prompt /home/dev/.bash_prompt

# Link in shared parts of the home directory
run ln -s /var/shared/.ssh
run ln -s /var/shared/.bash_history
run ln -s /var/shared/.maintainercfg

run chown -R dev: /home/dev
user dev
