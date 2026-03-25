#!/bin/bash
chown -R minecraft:minecraft /opt/minecraft/
sudo usermod -aG wheel minecraft

cd /opt/
ORACLE_JAVA26_LINK="https://download.oracle.com/java/26/latest/jdk-26_linux-aarch64_bin.tar.gz"
wget $ORACLE_JAVA26_LINK

sudo tar -xvf jdk-26_linux-aarch64_bin.tar.gz -C /opt/

sudo update-alternatives --install /usr/bin/java java /opt/jdk-26/bin/java 1

sudo update-alternatives --config java

java -version