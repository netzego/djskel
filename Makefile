SHELL					:= bash
.SHELLFLAGS				:= -eu -o pipefail -c
MAKEFLAGS				+= --warn-undefined-variables
MAKEFLAGS				+= --no-builtin-rules
WORKTREE_ROOT			!= git rev-parse --show-toplevel 2> /dev/null
PROJECT_NAME			:= djskel
VENV					:= .venv
REQ_IN					:= requirements.in
REQ_TXT					:= requirements.txt
SYS_PYTHON				!= which --all python | grep -v -F $(VENV_DIR)
PYTHON					:= $(VENV)/bin/python
PIP						:= $(VENV)/bin/pip3
PIP_OPTIONS				:= --disable-pip-version-check --no-color --isolated
PYTEST					:= $(VENV)/bin/pytest
PYTEST_DOCTEST_OPTIONS	:= --doctest-modules
PYTEST_OPTIONS			:= --verbose $(PYTEST_DOCTEST_OPTIONS)
PYTEST_WATCH_OPTIONS	:= --verbose $(PYTEST_DOCTEST_OPTIONS)
DJANGO_ADMIN			:= $(VENV)/bin/django-admin
DJANGO_ADDR				:= localhost
DJANGO_PORT				:= 8000

clean_venv:
	@rm -fr $(VENV)

clean_caches:
	@fd --no-ignore --hidden --type d __pycache__ $(PWD) -x rm -fr {}
	@fd --no-ignore --hidden --type d \.pycache $(PWD) -x rm -fr {}
	@fd --no-ignore --hidden --type d \.pytest_cache $(PWD) -x rm -fr {}

clean: clean_venv clean_caches

distclean: clean
	fd --no-ignore --hidden --type d \\$(VENV) $(PWD) -x rm -fr {}

src:
	@mkdir -p src

$(VENV)/pyvenv.cfg: |src
	$(SYS_PYTHON) -m venv $(VENV)

venv: $(VENV)/pyvenv.cfg

install_packages: $(REQ_IN) |$(VENV)
	@$(PIP) $(PIP_OPTIONS) install -r $<

pip_install:
	$(PIP) install -r requirements.txt

pip_freeze:
	$(PIP) freeze > requirements.txt

pip_upgrade:
	$(PIP) install -r requirements.txt --upgrade

django_startproject: |src
	$(DJANGO_ADMIN) startproject config $(WORKTREE_ROOT)/src

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
init: venv install_packages

.PHONY: \
	clean \
	clean_caches \
	clean_venv \
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

.DEFAULT_GOAL := init
