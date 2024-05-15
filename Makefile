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


.PHONY: build1
build1:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local.pkrvars.hcl),) 
	packer build \
	-var-file=local.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1.pkr.hcl
else
	packer build \
	-var-file=vyos.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image1.pkr.hcl
endif

.PHONY: build2
build2:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local.pkrvars.hcl),) 
	packer build \
	-var-file=local.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2.pkr.hcl
else
	packer build \
	-var-file=vyos.pkrvars.hcl \
	-parallel-builds=0 \
	vyos-image2.pkr.hcl
endif

.PHONY: init
init:
	packer init vyos-image1.pkr.hcl
	packer init vyos-image2.pkr.hcl

.PHONY: upgrade
upgrade:
	packer init -upgrade vyos-image1.pkr.hcl
	packer init -upgrade vyos-image2.pkr.hcl

.PHONY: clean
clean:
	rm -rf output/*

# you need to run this first to use headless=false
.PHONY: x11server
x11server:
	Xvfb :99 -screen 0 1024x768x16 &
	export DISPLAY=:99
