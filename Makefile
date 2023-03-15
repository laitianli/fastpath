PWD=$(shell pwd)
TARGET=x86_64-native-linuxapp-gcc
OFP_DIR=$(PWD)/ofp
ODP_DPDK_DIR=$(PWD)/odp-dpdk
DPDK_DIR=$(PWD)/dpdk
DPDK_INSTALL_DIR=$(DPDK_DIR)/install_dir
DPDK_BUILD_DIR=x86_build
#export PKG_CONFIG_PATH=$(DPDK_DIR)/install_dir/lib/pkgconfig
all: dpdk odp_dpdk ofp
build: build_dpdk build_odp_dpdk build_ofp
define dpdk_19_11
	cd $(DPDK_DIR) && make config T=${TARGET} O=${TARGET}
	cd $(DPDK_DIR) && make -j4 build O=${TARGET} EXTRA_CFLAGS="-fPIC -O0 -g"
	cd $(DPDK_DIR) && make install  O=${TARGET} DESTDIR=${TARGET}	
endef



define dpdk_21_11
	echo "[note] build dpdk 21.11"
	cd $(DPDK_DIR) && meson configure -Dc_args='-fPIC' -Dc_link_args='-fPIC' --prefix=$(DPDK_INSTALL_DIR) --libdir=lib --includedir=include --default-library=static
	cd $(DPDK_DIR) && meson $(DPDK_BUILD_DIR) -Dc_args='-fPIC' -Dc_link_args='-fPIC' --prefix=$(DPDK_INSTALL_DIR) --libdir=lib --includedir=include --default-library=static
	cd $(DPDK_DIR) && ninja -C $(DPDK_BUILD_DIR)
	cd $(DPDK_DIR) && ninja -C $(DPDK_BUILD_DIR) install
endef

dpdk:
	$(call dpdk_21_11)


build_dpdk:
	cd $(DPDK_DIR) && make -j4 build O=${TARGET} EXTRA_CFLAGS="-fPIC -O0 -g"
	cd $(DPDK_DIR) && make install  O=${TARGET} DESTDIR=${TARGET}	

build_odp_dpdk:
	cd $(ODP_DPDK_DIR) && make -j4 install

define odp_dpdk_19_11
	cd $(ODP_DPDK_DIR) && ./bootstrap
	cd $(ODP_DPDK_DIR) && ./configure --enable-debug --enable-debug-print --without-openssl --with-dpdk-path=$(DPDK_DIR)/$(TARGET)/usr/local --prefix=${ODP_DPDK_DIR}/install CFLAGS="-g -O0"
	cd $(ODP_DPDK_DIR) && make -j4 install
endef
#cd $(ODP_DPDK_DIR) && ./configure --enable-debug --enable-debug-print --without-openssl  --prefix=${ODP_DPDK_DIR}/install CFLAGS="-fPIC -g -O0 -D_DPDK_NEW_VERSION_" PKG_CONFIG_PATH=$(DPDK_DIR)/install_dir/lib/pkgconfig DPDK_LIBS="$(shell pkg-config --static --libs libdpdk)" DPDK_CFLAGS="$(shell pkg-config --cflags libdpdk)"
define odp_dpdk_21_11
	cd $(ODP_DPDK_DIR) && ./bootstrap
	cd $(ODP_DPDK_DIR) && ./configure --enable-debug --enable-debug-print --without-openssl  --prefix=${ODP_DPDK_DIR}/install CFLAGS="-fPIC -g -O0 -D_DPDK_NEW_VERSION_" PKG_CONFIG_PATH=$(DPDK_DIR)/install_dir/lib/pkgconfig
	cd $(ODP_DPDK_DIR) && make -j4 install
endef

odp_dpdk:
	$(call odp_dpdk_21_11)
ofp:
	cd $(OFP_DIR) && ./bootstrap
	cd $(OFP_DIR) && ./configure --with-odp=${ODP_DPDK_DIR}/install --enable-static --enable-sp --enable-debug --with-odp-lib=odp-dpdk --prefix=${OFP_DIR}/install CFLAGS="-g -O0 -D_DPDK_NEW_VERSION" PKG_CONFIG_LIBDIR=${ODP_DPDK_DIR}/install/lib/pkgconfig
	cd $(OFP_DIR) && make -j4 install

build_ofp:
	cd $(OFP_DIR) && make -j4 install


.PHONY: all dpdk odp_dpdk ofp clean build build_dpdk build_odp_dpdk build_ofp


clean:
	if [ -d $(DPDK_INSTALL_DIR) ];then rm -rf $(DPDK_INSTALL_DIR); fi
	if [ -d $(DPDK_DIR)/$(DPDK_BUILD_DIR) ];then rm -rf $(DPDK_DIR)/$(DPDK_BUILD_DIR); fi
	make -C $(ODP_DPDK_DIR) clean
	make -C $(OFP_DIR) clean
