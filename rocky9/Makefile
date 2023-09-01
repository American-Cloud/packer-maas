include .env
# Variables
PACKER ?= packer
PACKER_LOG ?= 0
ARGS ?=

.PHONY: all clean

all: rocky9.tar.gz

build:
ifeq ($(wildcard http/rocky.ks.bak),)
	# Replace variables in kickstart file
	cp -p http/rocky.ks http/rocky.ks.bak
	sed -i 's/ZABBIX_SERVER/${ZABBIX_SERVER}/g' http/rocky.ks
else
	@echo Backup file already exists
endif

rocky9.tar.gz: clean build
	sudo ${PACKER} init rocky9.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build rocky9.pkr.hcl
	mv http/rocky.ks.bak http/rocky.ks
	reset

clean:
	sudo ${RM} -rf output-rocky9 rocky9.tar.gz
