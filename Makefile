PROJECT=image-service_aiohttp
VERSION=1.0



# .ONESHELL:
DEFAULT_GOAL: help
.PHONY: init deps freeze clean

init: ##@main >> create virtualenv to ./venv and install lib from ./requirements.txt
	@echo "--> Create virtualenv to ./venv"
	@python3 -m venv venv
	@venv/bin/python -V
	@echo "--> install package from ./requirements.txt"
	@PYTHONPATH=venv ; . venv/bin/activate && venv/bin/pip install -U -r requirements.txt && if [ "$(ls requirements)" ] ; then venv/bin/pip install -U -r requirements/* ; fi
	@echo "--> pip package"
	@venv/bin/pip freeze

update: ##@option >> update pip and package in venv
	@echo "--> update pip"
	@venv/bin/python -m pip install --upgrade pip
	@echo "--> update package"
	@venv/bin/pip install -r requirements.txt --upgrade
	@echo "--> update package to ./requirements.txt"
	@. venv/bin/activate && venv/bin/pip freeze > requirements.txt

freeze: ##@option >> pip freeze package to ./requirements.txt
	@echo "--> pip freeze package to ./requirements.txt"
	@. venv/bin/activate && venv/bin/pip freeze > requirements.txt
	@venv/bin/pip freeze

clear: ##@option >> removing virtual environment
	@echo "--> Removing virtual environment"
	@rm -rf venv

HELP_FUN = \
	%help; \
	while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^([a-zA-Z\-\$\(]+)\s*:.*\#\#(?:@([a-zA-Z\-\)]+))?\s(.*)$$/ }; \
	print "usage: make [target]\n\n"; \
	for (sort keys %help) { \
	print "${WHITE}$$_:${RESET}\n"; \
	for (@{$$help{$$_}}) { \
	$$sep = " " x (32 - length $$_->[0]); \
	print "  ${YELLOW}$$_->[0]${RESET}$$sep${GREEN}$$_->[1]${RESET}\n"; \
	}; \
	print "\n"; }

help: ##@other >> Show this help.
	@echo $(PROJECT) V$(VERSION)
	@python -V
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)