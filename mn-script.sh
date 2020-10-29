#!/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu 18.04 is the recommended operating system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Autradex Core masternodes.   *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ "y" ]]; then

    cd

    if [[ -d autx-core/ ]]; then
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!                                                 !"
    echo "!    Detected previous build files, deleting..    !"
    echo "!                                                 !"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        rm -r autx-core/
    fi 

    sudo apt-get -y update
    sudo apt-get -y upgrade
    sudo apt-get -y install git
    sudo apt-get install -y curl 
    sudo apt-get install -y build-essential
    sudo apt-get install -y libtool
    sudo apt-get install -y autotools-dev
    sudo apt-get install -y automake pkg-config
    sudo apt-get install -y python3
    sudo apt-get install -y bsdmainutils
    sudo apt-get install -y cmake
    cd

    cd /var
    sudo touch swap.img
    sudo chmod 600 swap.img
    sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
    sudo mkswap /var/swap.img
    sudo swapon /var/swap.img
    sudo free
    sudo echo "/var/swap.img none swap sw 0 0" >>/etc/fstab
    cd

    cd 
    git clone https://github.com/farsider350/autx-core.git
    cd autx-core/
    bash build.sh
    rm /usr/bin/autxd*
    mv src/autxd /usr/bin
    mv src/autx-cli /usr/bin
    mv src/autx-tx /usr/bin
    #rm -r /root/autx-core/

    sudo apt-get install -y ufw
    sudo ufw allow ssh/tcp
    sudo ufw limit ssh/tcp
    sudo ufw logging on
    echo "y" | sudo ufw enable
    sudo ufw status

    mkdir -p ~/bin
    echo 'export PATH=~/bin:$PATH' >~/.bash_aliases
    source ~/.bashrc
fi

## Setup conf
mkdir -p ~/bin

MNCOUNT=""
re='^[0-9]+$'
while ! [[ $MNCOUNT =~ $re ]]; do
    echo ""
    echo "How many nodes do you want to create on this server?, followed by [ENTER]:"
    read MNCOUNT
done

for i in $(seq 1 1 $MNCOUNT); do
    echo ""
    echo "Enter alias for new node"
    read ALIAS

    echo ""
    echo "Enter port 7999 for node $ALIAS"
    read PORT

    echo ""
    echo "Enter masternode private key for node $ALIAS"
    read PRIVKEY

    echo ""
    echo "Configure your masternodes now!"
    echo "Type the IP of this server, followed by [ENTER]:"
    read IP

    echo ""
    echo "Enter RPC Port 4001"
    read RPCPORT

    ALIAS=${ALIAS,,}
    CONF_DIR=~/.autxcore$ALIAS

    # Create scripts
    echo '#!/bin/bash' >~/bin/autxd_$ALIAS.sh
    echo "autxd -daemon -conf=$CONF_DIR/autx.conf -datadir=$CONF_DIR "'$*' >>~/bin/autxd_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/autx-cli_$ALIAS.sh
    echo "autx-cli -conf=$CONF_DIR/autx.conf -datadir=$CONF_DIR "'$*' >>~/bin/autx-cli_$ALIAS.sh
    echo '#!/bin/bash' >~/bin/autx-tx_$ALIAS.sh
    echo "autx-tx -conf=$CONF_DIR/autx.conf -datadir=$CONF_DIR "'$*' >>~/bin/autx-tx_$ALIAS.sh
    chmod 755 ~/bin/autx*.sh

    mkdir -p $CONF_DIR
    echo "" >> autx.conf_TEMP
    echo "" >> autx.conf_TEMP
    echo "rpcuser=user"$(shuf -i 100000-10000000 -n 1) >> autx.conf_TEMP
    echo "rpcpassword=pass"$(shuf -i 100000-10000000 -n 1) >> autx.conf_TEMP
    echo "rpcallowip=127.0.0.1" >> autx.conf_TEMP
    echo "rpcport=$RPCPORT" >> autx.conf_TEMP
    echo "listen=1" >> autx.conf_TEMP
    echo "server=1" >> autx.conf_TEMP
    echo "daemon=1" >> autx.conf_TEMP
    echo "port=$PORT" >> autx.conf_TEMP
    echo "externalip=$IP" >> autx.conf_TEMP
    echo "bind=$IP" >> autx.conf_TEMP
    echo "logtimestamps=1" >> autx.conf_TEMP
    echo "maxconnections=64" >> autx.conf_TEMP
    echo "addnode=139.180.172.199:7999" >> autx.conf_TEMP
    echo "masternodeblsprivkey=$PRIVKEY" >> autx.conf_TEMP
    sudo ufw allow $PORT/tcp

    mv autx.conf_TEMP $CONF_DIR/autx.conf

    sh ~/bin/autxd_$ALIAS.sh
done