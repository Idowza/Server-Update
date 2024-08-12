#!/bin/bash

sudo apt update -y
sudo apt upgrade -y
sudo flatpak update -y
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt autopurge -y
sudo apt install -f -y
sudo dpkg --configure -a

pihole -up
pihole -g
