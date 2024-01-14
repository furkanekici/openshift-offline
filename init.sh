#!/bin/bash

# Disable firewalld
systemctl disable firewalld

# Disable SELinux
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

# Install tar and createrepo
cd /root/packages/tar
rpm -ivh *.rpm
cd /root/packages/createrepo
rpm -ivh *.rpm
cd /root/packages/openssl
rpm -ivh *.rpm

# Create local repositories
createrepo /root/packages/docker
createrepo /root/packages/jq
createrepo /root/packages/vim
createrepo /root/packages/skopeo

# Add local repository to DNF
dnf config-manager --add-repo=file:///root/packages/docker/local-docker.repo
dnf config-manager --add-repo=file:///root/packages/jq/local-jq.repo
dnf config-manager --add-repo=file:///root/packages/vim/local-vim.repo
dnf config-manager --add-repo=file:///root/packages/skopeo/local-skopeo.repo

# Install Docker
dnf install docker-ce docker-ce-cli containerd.io docker-compose-plugin --disablerepo='*' --enablerepo='local-docker'
dnf install jq --disablerepo='*' --enablerepo='local-jq'
dnf install vim --disablerepo='*' --enablerepo='local-vim'
dnf install skopeo --disablerepo='*' --enablerepo='local-skopeo'


dnf clean all
dnf repolist

# Start and enable Docker service
systemctl start docker
systemctl enable docker

# Check Docker version
docker --version

# Reboot the system to apply changes
read -p "Reboot the system now? (y/n): " confirm_reboot
if [[ "$confirm_reboot" == "y" ]]; then
    echo "Rebooting system in 5 seconds..."
    sleep 5
    shutdown -r now
else
    echo "Reboot canceled. Please remember to reboot the system manually later."
fi
