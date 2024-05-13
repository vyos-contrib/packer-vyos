#!make

# if not set, set defaults 
PARALLEL_BUILDS ?= 0
PACKER_LOG ?= 0
# always use DISPLAY :99
DISPLAY=:99
#export DISPLAY
# include .env vars
-include .env
# export all
export

.PHONY: help build init upgrade clean x11

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



build:
# if exist local.pkrvars.hcl load it
ifneq ($(wildcard local.pkrvars.hcl),) 
	packer build \
	-var-file=local.pkrvars.hcl \
	-parallel-builds=$(PARALLEL_BUILDS) \
	 vyos.pkr.hcl 
else
	packer build \
	-var-file=vyos.pkrvars.hcl \
	 -parallel-builds=$(PARALLEL_BUILDS) \
	vyos.pkr.hcl
endif

init:
	packer init vyos.pkr.hcl 

upgrade:
	packer init -upgrade vyos.pkr.hcl

clean:
	rm -rf output-*

# you need to run this first to use headless=false
x11server:
	Xvfb :99 -screen 0 1024x768x16 &
	export DISPLAY=:99
