PWD=$(shell pwd)
TARGET=x86_64-native-linuxapp-gcc
OFP_DIR=$(PWD)/ofp
ODP_DPDK_DIR=$(PWD)/odp-dpdk
DPDK_DIR=$(PWD)/dpdk

all: dpdk odp_dpdk ofp
build: build_dpdk build_odp_dpdk build_ofp

dpdk:
	cd $(DPDK_DIR) && make config T=${TARGET} O=${TARGET}
	cd $(DPDK_DIR) && make -j4 build O=${TARGET} EXTRA_CFLAGS="-fPIC -O0 -g"
	cd $(DPDK_DIR) && make install  O=${TARGET} DESTDIR=${TARGET}	
build_dpdk:
	cd $(DPDK_DIR) && make -j4 build O=${TARGET} EXTRA_CFLAGS="-fPIC -O0 -g"
	cd $(DPDK_DIR) && make install  O=${TARGET} DESTDIR=${TARGET}	

build_odp_dpdk:
	cd $(ODP_DPDK_DIR) && make -j4 install

odp_dpdk:
	cd $(ODP_DPDK_DIR) && ./bootstrap
	cd $(ODP_DPDK_DIR) && ./configure --enable-debug --enable-debug-print --without-openssl --with-dpdk-path=$(DPDK_DIR)/$(TARGET)/usr/local --prefix=${ODP_DPDK_DIR}/install CFLAGS="-g -O0"
	cd $(ODP_DPDK_DIR) && make -j4 install

ofp:
	cd $(OFP_DIR) && ./bootstrap
	cd $(OFP_DIR) && ./configure --with-odp=${ODP_DPDK_DIR}/install --enable-debug --disable-sp --prefix=${OFP_DIR}/install CFLAGS="-g -O0"
	cd $(OFP_DIR) && make -j4 install

build_ofp:
	cd $(OFP_DIR) && make -j4 install


.PHONY: all dpdk odp_dpdk ofp clean build build_dpdk build_odp_dpdk build_ofp


clean:
	make -C $(DPDK_DIR) clean
	make -C $(ODP_DPDK_DIR) clean
	make -C $(OFP_DIR) clean
