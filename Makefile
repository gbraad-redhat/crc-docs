SHELL := /bin/bash -o pipefail

# Docs build related variables
DOCS_BUILD_DIR ?= public
DOCS_BUILD_CONTAINER ?= ghcr.io/crc-org/antora:latest
DOCS_SERVE_CONTAINER ?= docker.io/httpd:alpine
DOCS_TEST_CONTAINER ?= docker.io/wjdp/htmltest:latest
DOCS_BUILD_TARGET ?= ./source/getting_started/master.adoc

CONTAINER_RUNTIME ?= podman
SELINUX_VOLUME_LABEL = :Z
ifeq ($(GOOS),darwin)
SELINUX_VOLUME_LABEL :=
endif

.PHONY: build_docs
build_docs:
	${CONTAINER_RUNTIME} run -e CI -v $(CURDIR):/workspace$(SELINUX_VOLUME_LABEL) --rm $(DOCS_BUILD_CONTAINER) --stacktrace antora-playbook.yml

.PHONY: docs_serve
docs_serve: build_docs
	${CONTAINER_RUNTIME} run -it -v $(CURDIR)/$(DOCS_BUILD_DIR):/usr/local/apache2/htdocs/$(SELINUX_VOLUME_LABEL) --rm -p 8088:80/tcp $(DOCS_SERVE_CONTAINER)

.PHONY: docs_check_links
docs_check_links:
	${CONTAINER_RUNTIME} run -v $(CURDIR):/test$(SELINUX_VOLUME_LABEL) --rm $(DOCS_TEST_CONTAINER) -c .htmltest.yml
