all:
	echo OK

install-gns3-deps:
	dnf install -y "oracle-epel-release-el8"
	dnf group install -y "Virtualization Host"
	dnf group install -y "Development Tools"
	dnf group install -y "Security Tools"
	dnf group install -y "System Tools"
	dnf config-manager --set-enabled ol8_codeready_builder
	dnf config-manager --set-enabled ol8_kvm_appstream
	dnf install -y python3-devel elfutils-libelf-devel libpcap-devel python3-pyqt5-sip python3-qt5 xterm cmake
	dnf install -y bash-completion libguestfs-bash-completion virt-v2v-bash-completion mailx
	dnf update -y

install-docker:
	dnf install -y dnf-utils zip unzip
	dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
	dnf remove -y runc
	dnf install -y docker-ce --nobest
	systemctl enable docker.service
	systemctl start docker.service
	systemctl status docker.service| tee -a /dev/null
	docker info
	docker version

install-gns3: disable-selinux open-firewall-ports install-gns3-deps install-docker create-gns3-user
	git clone --depth 1 https://github.com/GNS3/gns3-server.git
	git clone --depth 1 https://github.com/GNS3/gns3-gui.git
	git clone --depth 1 https://github.com/GNS3/vpcs.git
	git clone --depth 1 https://github.com/GNS3/dynamips.git
	git clone --depth 1 https://github.com/GNS3/ubridge.git
	cd gns3-server && pip3 install -r requirements.txt && python3 setup.py install
	cd gns3-gui && pip3 install -r requirements.txt && python3 setup.py install
	cd vpcs/src && ./mk.sh && cp -v vpcs /usr/local/bin/vpc
	cd dynamips && mkdir build && cd build && cmake .. && make && make install
	cd ubridge && make && make install
	ln -s /usr/libexec/qemu-kvm /usr/bin/qemu-kvm;true
	cd gns3-server/init && cp gns3.service.systemd /etc/systemd/system/gns3.service
	chown root:root /etc/systemd/system/gns3.service
	sed -i -e "s@^ExecStart=.*@ExecStart=/usr/local/bin/gns3server@g" /etc/systemd/system/gns3.service
	systemctl daemon-reload
	systemctl enable gns3.service
	systemctl start gns3.service

create-gns3-user:
	useradd gns3;true
	usermod -a -G qemu gns3;true
	usermod -a -G kvm gns3;true
	usermod -a -G libvirt gns3;true
	usermod -a -G docker gns3;true

disable-selinux:
	setenforce 0
	sed -i -e "s@^SELINUX=.*@SELINUX=disabled@g" /etc/selinux/config

open-firewall-ports:
	firewall-cmd --add-port=3080/tcp;true
	firewall-cmd --add-port=3080/tcp --permanent;true
	firewall-cmd --add-port=5900-6000/tcp;true
	firewall-cmd --add-port=5900-6000/tcp --permanent;true

check-virtualization:
	bash check-virtualization.sh
