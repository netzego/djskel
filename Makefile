SHELL					:= bash
.SHELLFLAGS				:= -eu -o pipefail -c
MAKEFLAGS				+= --warn-undefined-variables
MAKEFLAGS				+= --no-builtin-rules
WORKTREE_ROOT			!= git rev-parse --show-toplevel 2> /dev/null
PROJECT_NAME			:= djskel
VENV_DIR				:= .venv
REQ_IN					:= requirements.in
REQ_TXT					:= requirements.txt
SYS_PYTHON				!= which --all python | grep -v -F $(VENV_DIR)
PYTHON					:= $(VENV_DIR)/bin/python
PIP						:= $(VENV_DIR)/bin/pip3
PIP_OPTIONS				:= --disable-pip-version-check --no-color --isolated
PYTEST					:= $(VENV_DIR)/bin/pytest
PYTEST_DOCTEST_OPTIONS	:= --doctest-modules
PYTEST_OPTIONS			:= --verbose $(PYTEST_DOCTEST_OPTIONS)
PYTEST_WATCH_OPTIONS	:= --verbose $(PYTEST_DOCTEST_OPTIONS)
DJANGO_ADMIN			:= $(VENV_DIR)/bin/django-admin
DJANGO_ADDR				:= localhost
DJANGO_PORT				:= 8123
DJANGO_ROOT				:= src

clean_venv:
	@rm -fr $(VENV_DIR)

clean_caches:
	@fd --no-ignore --hidden --type d __pycache__ $(PWD) -x rm -fr {}
	@fd --no-ignore --hidden --type d \.pycache $(PWD) -x rm -fr {}
	@fd --no-ignore --hidden --type d \.pytest_cache $(PWD) -x rm -fr {}

clean: clean_venv clean_caches

distclean: clean
	@rm -fr $(DJANGO_ROOT)
	@rm -fr $(REQ_TXT)

$(DJANGO_ROOT):
	@mkdir -p $@

$(VENV_DIR)/pyvenv.cfg: |$(DJANGO_ROOT)
	@$(SYS_PYTHON) -m venv $(VENV_DIR)

venv: $(VENV_DIR)/pyvenv.cfg

$(REQ_IN):
	@touch $@

$(REQ_TXT): .FORCE $(REQ_IN) |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) freeze \
		--local \
		--exclude-editable \
		--requirement $(REQ_IN) \
		| tee $(REQ_TXT)

freeze: $(REQ_TXT)

install_packages: $(REQ_IN) |$(VENV_DIR)
	@$(PIP) $(PIP_OPTIONS) install -r $<

django_startproject: |$(DJANGO_ROOT)
	$(DJANGO_ADMIN) startproject config $(WORKTREE_ROOT)/$(DJANGO_ROOT)

django_runserver: 
	$(PYTHON) $(WORKTREE_ROOT)/$(DJANGO_ROOT)/manage.py runserver $(DJANGO_ADDR):$(DJANGO_PORT)

serve: django_runserver

watch_surf:
	surf http://$(DJANGO_ADDR):$(DJANGO_PORT)/ &> /dev/null &
	fd -t f . src/ | entr -r kill -s HUP $$(pgrep surf)

test:
	$(PYTEST) $(PYTEST_OPTIONS)

# pytest_watch:
# 	fd --type f \.py$$ | entr -c $(PYTEST) $(PYTEST_WATCH_OPTIONS)

.FORCE:

# aliases
init: venv install_packages django_startproject

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
