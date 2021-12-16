#!/bin/bash

#set -x
NO_CLR='\e[1;m'
RED='\e[1;31m'
GREEN='\e[1;32m'

retcode=$(echo $?)

chk_user=$(awk -F: '{ print $1}' /etc/passwd | grep $1)

if [ "$chk_user" != "$1" ]; then
    echo -e "${RED}User $1 does not exists! creating user $1...${NO_CLR}"
    password="P@ssw0rd"
    pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
    OS_DISTRO=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
    if [ $OS_DISTRO != 'ubuntu' ];then
        echo -e "\n-------------------------------------"
        echo -e "${GREEN}This is RHEL ${NO_CLR}"
        echo -e "\n*************************************"
        useradd -m -p "$pass" -G wheel "$1"
        echo -e "${GREEN}User $1 has been added!${NO_CLR}"
        echo -e "\n-------------------------------------"
    else
        echo -e "\n-------------------------------------"
        echo -e "${GREEN}This is Ubuntu${NO_CLR}"
        echo -e "\n*************************************"
        useradd -m -p "$pass" -G sudo "$1"
        echo -e "${GREEN}User $1 has been added!${NO_CLR}"
        echo -e "\n-------------------------------------"
    fi
else
    echo -e "${GREEN}User $1 exists!${NO_CLR}"
    exit 1
fi
