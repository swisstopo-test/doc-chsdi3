SHELL = /bin/bash



include sphinx.mk


# Variables
USER_SOURCE ?= rc_user
CURRENT_DIRECTORY := $(shell pwd)
INSTALL_DIRECTORY := .venv
PYPI_URL ?= https://pypi.org/simple/


# Commands
PIP_CMD := $(INSTALL_DIRECTORY)/bin/pip
PYTHON_CMD := $(INSTALL_DIRECTORY)/bin/python
SPHINX_CMD := $(INSTALL_DIRECTORY)/bin/sphinx-build

# Linting rules
PEP8_IGNORE := "E128,E221,E241,E251,E272,E305,E501,E711,E731"

# E128: continuation line under-indented for visual indent
# E221: multiple spaces before operator
# E241: multiple spaces after ':'
# E251: multiple spaces around keyword/parameter equals
# E272: multiple spaces before keyword
# E501: line length 79 per default
# E711: comparison to None should be 'if cond is None:' (SQLAlchemy's filter syntax requires this ignore!)
# E731: do not assign a lambda expression, use a def

# Colors
RESET := $(shell tput sgr0)
RED := $(shell tput setaf 1)
GREEN := $(shell tput setaf 2)

# Versions
# We need GDAL which is hard to install in a venv, modify PYTHONPATH to use the
# system wide version.
GDAL_VERSION ?= 1.10.0
PYTHON_VERSION := $(shell python --version 2>&1 | cut -d ' ' -f 2 | cut -d '.' -f 1,2)
PYTHONPATH ?= .venv/lib/python${PYTHON_VERSION}/site-packages:/usr/lib64/python${PYTHON_VERSION}/site-packages


.PHONY: doc 
doc:  .venv
	@echo "${GREEN}Building the documentation...${RESET}";
	${SPHINX_CMD} -W -b html source build || exit 1 ;

requirements.txt:
	@echo "${GREEN}File requirements.txt has changed${RESET}";
.venv: requirements.txt
	@echo "${GREEN}Setting up virtual environement...${RESET}";
	@if [ ! -d $(INSTALL_DIRECTORY) ]; \
	then \
		virtualenv $(INSTALL_DIRECTORY); \
		${PIP_CMD} install --upgrade pip==9.0.1 setuptools --index-url ${PYPI_URL} ; \
		${PIP_CMD} install --index-url ${PYPI_URL} -r requirements.txt ; \
	fi

.PHONY:
rss: doc 
	@echo "${GREEN}Creating the rss feed from releasenotes${RESET}";
	${PYTHON_CMD} scripts/rssFeedGen.py "https://api3.geo.admin.ch"


.PHONY: cleanall
cleanall:
	rm -rf .venv
