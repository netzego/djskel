SHELL					:= bash
.SHELLFLAGS				:= -eu -o pipefail -c
MAKEFLAGS				+= --warn-undefined-variables
MAKEFLAGS				+= --no-builtin-rules
WORKTREE_ROOT			!= git rev-parse --show-toplevel 2> /dev/null
PROJECT_NAME			:= djskel
VENV					:= .venv
SYS_PYTHON				:= $(shell which python)
PYTHON					:= $(VENV)/bin/python3
PIP						:= $(VENV)/bin/pip3
PYTEST					:= $(VENV)/bin/pytest
PYTEST_DOCTEST_OPTIONS	:= --doctest-modules
PYTEST_OPTIONS			:= --verbose $(PYTEST_DOCTEST_OPTIONS)
PYTEST_WATCH_OPTIONS	:= --verbose $(PYTEST_DOCTEST_OPTIONS)
DJANGO_ADMIN			:= $(VENV)/bin/django-admin
DJANGO_ADDR				:= localhost
DJANGO_PORT				:= 8000

clean_caches:
	fd --no-ignore --hidden --type d __pycache__ $(PWD) -x rm -fr {}
	fd --no-ignore --hidden --type d \.pycache $(PWD) -x rm -fr {}
	fd --no-ignore --hidden --type d \.pytest_cache $(PWD) -x rm -fr {}

clean: clean_caches

distclean: clean
	fd --no-ignore --hidden --type d \\$(VENV) $(PWD) -x rm -fr {}

$(VENV)/pyvenv.cfg:
	$(SYS_PYTHON) -m venv $(VENV)

venv: $(VENV)/pyvenv.cfg

pip_install:
	$(PIP) install -r requirements.txt

pip_freeze:
	$(PIP) freeze > requirements.txt

pip_upgrade:
	$(PIP) install -r requirements.txt --upgrade

django_startproject: src
	$(DJANGO_ADMIN) startproject $(PROJECT_NAME) $(PWD)/src

django_runserver: 
	$(PYTHON) $(PWD)/src/manage.py runserver $(DJANGO_ADDR):$(DJANGO_PORT)

# pytest:
# 	$(PYTEST) $(PYTEST_OPTIONS)
#
# pytest_watch:
# 	fd --type f \.py$$ | entr -c $(PYTEST) $(PYTEST_WATCH_OPTIONS)

# files
src:
	mkdir -p $(PWD)/src

# aliases
init: venv pip_install
install: pip_install
upgrade: pip_upgrade pip_freeze
serve: django_runserver
# test: pytest
# watch: pytest_watch

.PHONY: \
	clean \
	distclean \
	django_runserver \
	django_startproject \
	init \
	install \
	pip_freeze \
	pip_install \
	pip_upgrade \
	pytest \
	pytest_watch \
	serve \
	test \
	upgrade \
	venv \

.DEFAULT_GOAL := pytest
