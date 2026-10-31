.PHONY: all install list help

all: install

install:
	@./install.sh

list:
	@./install.sh --list

help:
	@echo "Usage:"
	@echo "  make install  - Install/link all skills to detected AI agents"
	@echo "  make list     - List all skills in this repository"
