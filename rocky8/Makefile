include .env
# Variables
PACKER ?= packer
PACKER_LOG ?= 0
ARGS ?=

.PHONY: all clean

all: rocky8.tar.gz

build:
	# Replace variables in kickstart file
	cp -p http/rocky.ks http/rocky.ks.bak
	sed -i 's/ZABBIX_SERVER/${ZABBIX_SERVER}/g' http/rocky.ks

rocky8.tar.gz: clean build
	sudo ${PACKER} init rocky8.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build rocky8.pkr.hcl
	mv http/rocky.ks.bak http/rocky.ks
	reset

clean:
	sudo ${RM} -rf output-rocky8 rocky8.tar.gz
