include .env
# Variables
PACKER ?= packer
PACKER_LOG ?= 0
ARGS ?=

.PHONY: all clean

all: custom-cloudimg.tar.gz

lint:
	packer validate .
	packer fmt -check -diff .

format:
	packer fmt .

build_cloud:
ifeq ($(wildcard scripts/cloudimg/customize.sh.bak),)
	# Replace variables in customize.sh
	cp -p scripts/cloudimg/customize.sh scripts/cloudimg/customize.sh.bak
	sed -i 's/ZABBIX_SERVER/${ZABBIX_SERVER}/g' scripts/cloudimg/customize.sh
else
	@echo Backup file already exists
endif

build_flat:
	@echo "Build flat not implemented"

build_lvm:
	@echo "Build lvm not implemented"

seeds-lvm.iso: user-data-lvm meta-data
	cloud-localds $@ $^

seeds-flat.iso: user-data-flat meta-data
	cloud-localds $@ $^

OVMF_VARS.fd: /usr/share/OVMF/OVMF_VARS.fd
	cp -v $< $@

custom-cloudimg.tar.gz: clean build_cloud

	sudo ${PACKER} init . && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -on-error=ask -only='cloudimg.*' $(ARGS) .
	mv scripts/cloudimg/customize.sh.bak scripts/cloudimg/customize.sh

custom-ubuntu.tar.gz: clean build_flat seeds-flat.iso OVMF_VARS.fd \
			packages/custom-packages.tar.gz
	sudo ${PACKER} init . && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -on-error=ask -only=qemu.flat $(ARGS) .

custom-ubuntu-lvm.dd.gz: clean build_lvm seeds-lvm.iso OVMF_VARS.fd
	sudo ${PACKER} init . && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -on-error=ask -only=qemu.lvm $(ARGS) .

clean:
	sudo ${RM} -rf output-* custom-*.gz

CUSTOM_PKGS:=${wildcard packages/*.deb}

packages/custom-packages.tar.gz: ${CUSTOM_PKGS}
ifeq ($(strip $(CUSTOM_PKGS)),)
	tar czf $@ -C packages -T /dev/null
else
	tar czf $@ -C packages ${notdir $^}
endif

.INTERMEDIATE: OVMF_VARS.fd
