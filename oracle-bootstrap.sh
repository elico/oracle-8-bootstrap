#!/usr/bin/env bash

KEYS_URL="https://gist.githubusercontent.com/elico/4bef9019a48488e6cda188c504e887f2/raw/2e66166a2c5487568d66a7d7763ce05b89576302/authorized_keys"

ANSIBLE_TMP="/ansible-install-tmp"
mkdir ${ANSIBLE_TMP}
TMPDIR="${ANSIBLE_TMP}"

export ANSIBLE_TMP
export TMPDIR

dnf install -y rsync python3-pip vim curl wget net-tools git open-vm-tools sudo mlocate bash-completion oracle-epel-release-el8

## Making sure that the pacakge exits before installing
dnf install -y hyperv-daemons fish htop ruby ruby-devel ruby-irb rubygems rubygem-json tmux p7zip p7zip-plugins make procmail

mkdir -p /root/.ssh
if [ -f "/root/.ssh/authorized_keys" ];then
  wget "${KEYS_URL}" -O /root/.ssh/eliezer_keys
  cat /root/.ssh/eliezer_keys >> /root/.ssh/authorized_keys
else
  wget "${KEYS_URL}" -O /root/.ssh/authorized_keys
fi

chmod 600 /root/.ssh/authorized_keys

chown -R root:root /root

chmod 700 /root/.ssh

python3 -m pip install --upgrade pip

python3 -m pip install wheel

python3 -m pip install ansible

echo 'export PATH=$PATH:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin' |tee -a /etc/bashrc

echo -e "syntax on" |tee -a ~/.vimrc
echo -e "color desert" |tee -a ~/.vimrc
