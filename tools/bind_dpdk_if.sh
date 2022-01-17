#!/bin/bash

export OFP_NETDEV_PCI=0000:02:06.0
PWD=`dirname $0`

if [ -z "$OFP_NETDEV_PCI" ];then
    echo "[shell error] env OFP_NETDEV_PCI is null!!!"
    exit -1
fi

dpdk_if=`$PWD/dpdk-devbind.py -s | grep "$OFP_NETDEV_PCI"`

echo "dpdk_if=$dpdk_if"

if [ -z "$dpdk_if" ];then
    echo "[shell error] PCIe device $OFP_NETDEV_PCI doesn't exist!!!"
    exit -1;
fi

bind_driver=`echo $dpdk_if | grep "drv="`
if [ -z "$bind_driver" ];then
    echo "[shell warning] PCIe driver $OFP_NETDEV_PCI doesn't bind driver!!"
    igb_uio_mod=`lsmod | grep "igb_uio"`
    if [ -z $igb_uio_mod ];then
        modprobe igb_uio
        sleep 1;
    fi

    $PWD/dpdk-devbind.py -b igb_uio $OFP_NETDEV_PCI
    echo "[shell note] bind $OFP_NETDEV_PCI success!"
    exit 0
fi

bind_driver_igb_uio=`echo $dpdk_if | grep "drv=igb_uio"`
if [ -z "$bind_dirver_igb_uio" ];then
    if_name=`$PWD/dpdk-devbind.py -s | grep "$OFP_NETDEV_PCI" | awk -F "=" '{print $2}' | awk '{print $1}'`
    echo "dpdk_if: $if_name"
    if [ ! -z "$if_name" ];then
        ifconfig $if_name down
    fi

    $PWD/dpdk-devbind.py -u $OFP_NETDEV_PCI
    $PWD/dpdk-devbind.py -b igb_uio $OFP_NETDEV_PCI
    echo "[shell note] bind $OFP_NETDEV_PCI success!"
fi
