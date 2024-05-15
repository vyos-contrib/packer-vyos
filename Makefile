#!make

# if not set, set defaults 
#PARALLEL_BUILDS ?= 0
PACKER_LOG ?= 0
# always use DISPLAY :99
DISPLAY=:99
#export DISPLAY
# include .env vars
-include .env
# export all
export

VM_NAME_FILE := .vm_name
VM_NAME := $(shell cat $(VM_NAME_FILE))
SRC_QCOW2 := iso/$(VM_NAME)-build1.qcow2
DST_QCOW2 := iso/$(VM_NAME)-build2.qcow2
SRC_CHECKSUM := iso/$(VM_NAME)-build1.qcow2.checksum
DST_CHECKSUM := iso/$(VM_NAME)-build2.qcow2.checksum


.PHONY: help
help:
	@echo "make working:"
	@echo "- will use local.pkrvars.hcl if exists or vyos.pkrvars.hcl"
	@echo "- will load .env if file exists"

	@echo "make usage:"
	@echo "  make build - build image with 'packer build'"
	@echo "  make init  - init 'packer init'"
	@echo "  make upgrade  - init 'packer init -upgrade'"
	@echo "  make clean - remove output files"
	@echo "  make x11server - start Xvfb X11 server on DISPLAY=:99. Require apt install xvfb"





# ifneq ("$(wildcard .env)","") 
# include .env
# export
# endif


.PHONY: build1-1.3
build1-1.3:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.3.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.3.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.3.pkr.hcl
else
	packer build \
	-var-file=vyos-1.3.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.3.pkr.hcl
endif

.PHONY: build1-1.4
build1-1.4:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.4.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.4.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.4.pkr.hcl
else
	packer build \
	-var-file=vyos-1.4.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.4.pkr.hcl
endif


.PHONY: build1-1.5
build1-1.5:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.5.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.5.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.5.pkr.hcl
else
	packer build \
	-var-file=vyos-1.5.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1-1.5.pkr.hcl
endif


.PHONY: build2-1.3
build2-1.3:
# create a copy of qcow2 - if build2 fail you can run again
	cp -f $(SRC_QCOW2) $(DST_QCOW2)
	cp -f $(SRC_CHECKSUM) $(DST_CHECKSUM)
	sed -i 's/$(VM_NAME)-build1.qcow2/$(VM_NAME)-build2.qcow2/' $(DST_CHECKSUM)
	cat iso/*.checksum > iso/SHA256SUM

# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.3.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.3.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.3.pkr.hcl
else
	packer build \
	-var-file=vyos-1.3.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.3.pkr.hcl
endif


.PHONY: build2-1.4
build2-1.4:
# create a copy of qcow2 - if build2 fail you can run again
	cp -f $(SRC_QCOW2) $(DST_QCOW2)
	cp -f $(SRC_CHECKSUM) $(DST_CHECKSUM)
	sed -i 's/$(VM_NAME)-build1.qcow2/$(VM_NAME)-build2.qcow2/' $(DST_CHECKSUM)
	cat iso/*.checksum > iso/SHA256SUM

# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.4.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.4.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.4.pkr.hcl
else
	packer build \
	-var-file=vyos-1.4.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.4.pkr.hcl
endif

.PHONY: build2-1.5
build2-1.5:
# create a copy of qcow2 - if build2 fail you can run again
	cp -f $(SRC_QCOW2) $(DST_QCOW2)
	cp -f $(SRC_CHECKSUM) $(DST_CHECKSUM)
	sed -i 's/$(VM_NAME)-build1.qcow2/$(VM_NAME)-build2.qcow2/' $(DST_CHECKSUM)
	cat iso/*.checksum > iso/SHA256SUM

# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local-vyos-1.5.pkrvars.hcl),) 
	packer build \
	-var-file=local-vyos-1.5.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.5.pkr.hcl
else
	packer build \
	-var-file=vyos-1.5.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2-1.5.pkr.hcl
endif


.PHONY: init
init:
	packer init vyos-image1-1.3.pkr.hcl
	packer init vyos-image1-1.4.pkr.hcl
	packer init vyos-image1-1.5.pkr.hcl
	packer init vyos-image2-1.3.pkr.hcl
	packer init vyos-image2-1.4.pkr.hcl
	packer init vyos-image2-1.5.pkr.hcl

.PHONY: upgrade
upgrade:
	packer init -upgrade vyos-image1-1.3.pkr.hcl
	packer init -upgrade vyos-image1-1.4.pkr.hcl
	packer init -upgrade vyos-image1-1.5.pkr.hcl
	packer init -upgrade vyos-image2-1.3.pkr.hcl
	packer init -upgrade vyos-image2-1.4.pkr.hcl
	packer init -upgrade vyos-image2-1.5.pkr.hcl

.PHONY: clean
clean:
	rm -rf output/*

# you need to run this first to use headless=false
.PHONY: x11server
x11server:
	Xvfb :99 -screen 0 1024x768x16 &
	export DISPLAY=:99
