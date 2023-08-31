include .env
# Variables
PACKER ?= packer
PACKER_LOG ?= 0
ARGS ?=

.PHONY: all clean

all: centos8-stream.tar.gz

build:
	# Replace variables in kickstart file
	cp -p http/centos8-stream.ks http/centos8-stream.ks.bak
	sed -i 's/ZABBIX_SERVER/${ZABBIX_SERVER}/g' http/centos8-stream.ks

centos8-stream.tar.gz: clean build
	sudo ${PACKER} init centos8-stream.pkr.hcl && sudo PACKER_LOG=${PACKER_LOG} ${PACKER} build -on-error=ask centos8-stream.pkr.hcl ${ARGS}
	mv http/centos8-stream.ks.bak http/centos8-stream.ks
	reset

clean:
	sudo ${RM} -rf output-centos8-stream centos8-stream.tar.gz
