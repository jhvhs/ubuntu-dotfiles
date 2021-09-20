#!/usr/bin/env bash

set -e

main() {
  prepare_dirs
  install_packages
  lastpass_login
  setup_files
  install_VPN
  install_jetbrains
  configure_docker_creds_helper
}

prepare_dirs() {
  mkdir -p ~/.local/share/lpass
  mkdir -p ~/.local/bin
}

setup_files() {
  if ! grep SSH_AUTH_SOCK ~/.pam_environment; then
    cat .pam_environment >> ~/.pam_environment
  fi

  if ! grep direnv ~/.profile; then
    echo 'eval "$(direnv hook bash)"' >> ~/.profile
  fi

  install git-login ~/.local/bin/
  install good-morning ~/.local/bin/
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.profile
  source ~/.profile

  mkdir -p ~/.config/systemd/user
  cp services/* ~/.config/systemd/user/
}

install_VPN() {
  if [[ ! -x gpu ]]; then
    echo "Installing GlobalProtect"
    # shellcheck disable=SC2164
    mkdir -p /var/tmp/GP-Linux
    wget -q --no-check-certificate "$(lpass show gp-linux-url --note)" -O /var/tmp/GP-Linux/gpinstall.sh
    pushd /var/tmp/GP-Linux
      chmod 755 gpinstall.sh
      ./gpinstall.sh
    popd

    if sudo systemctl status systemd-resolved &> /dev/null; then
      echo Disable annoying DNS behaviour interfering with VPN
      sudo systemctl disable systemd-resolved
      sudo systemctl stop systemd-resolved
      sudo mv default.resolve.conf /etc/resolv.conf
    fi

    if [[ "$(lsb_release -cs)" == "focal" ]] && ! grep default_conf /etc/ssl/openssl.cnf >/dev/null; then
      echo Rewriting OpenSSL configuration of Ubuntu 20.04
      cat tmp.openssl.top /etc/ssl/openssl.cnf tmp.openssl.bottom > ~/tmp.openssl.cnf
      sudo mv ~/tmp.openssl.cnf /etc/ssl/openssl.cnf
    fi

    gpu --connect
  fi
}

install_packages() {
  echo "Installing system packages"
  sudo apt update
  sudo apt install -y apt-transport-https build-essential ca-certificates ctags curl direnv fd-find neovim python3-pip ripgrep tig firefox tree lastpass-cli tmux pass golang-ginkgo-dev

  echo "Installing docker"
  curl https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-add-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'
  sudo apt update
  sudo apt install -y docker-ce
  sudo usermod -aG docker "$(whoami)"

  echo "Installing homebrew packages"
  if [[ ! -x brew ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "/home/$(whoami)/.profile"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    brew bundle
  fi
}

lastpass_login() {
  if ! lpass status > /dev/null 2>&1; then
    echo "Please enter your LastPass username to login:"
    read -r username
    lpass login "$username"
  fi
}

install_jetbrains() {
  echo "Installing Jetbrains Projector"
  if [[ ! -x projector ]]; then
    sudo apt install -y python3 python3-pip
    sudo apt install -y python3-cryptography
    python3 -m pip install -U pip

    sudo apt install less libxext6 libxrender1 libxtst6 libfreetype6 libxi6 -y
    pip3 install projector-installer --user
    source ~/.profile

    echo Installing GoLand...
    projector install GoLand
    trap cleanup_crt EXIT
    mkdir -p "/tmp/$(whoami)/crt"
    lpass show jb.workstation.crt --notes > "/tmp/$(whoami)/crt/jb.crt"
    lpass show jb.workstation.key --notes > "/tmp/$(whoami)/crt/jb.key"
    projector install-certificate GoLand --certificate "/tmp/$(whoami)/crt/jb.crt" --key "/tmp/$(whoami)/crt/jb.key"

    echo Enable the GoLand password using the following prompt
    projector config edit GoLand
  fi
}

cleanup_crt() {
  rm -rf "/tmp/$(whoami)/crt"
}

configure_docker_creds_helper() {
  echo Configuring docker credentials helper
  gpg --full-generate-key
  echo "run 'pass init <key ID from above>'"
}

main
