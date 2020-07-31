#!/usr/bin/env make

include Makehelp.mk

.EXPORT_ALL_VARIABLES:

SUBFOLDER ?= .

## Check that all .tf files are in canonical format
check:
	docker-compose run --rm terra terraform fmt -check -diff -recursive
.PHONY: check

## Format .tf files
fmt:
	docker-compose run --rm terra terraform fmt -diff -recursive
.PHONY: fmt

## Validate with tflint
lint:
	docker-compose run --rm terra tflint --module
.PHONY: lint

## Scans all modules for potential security issues
tfsec:
	cat .run-tfsec.sh | docker-compose run --rm terra bash
.PHONY: tfsec

## Generate markdown documentation for a terraform module (expect SUBFOLDER)
readme:
	docker-compose run --rm terra bash -c "sed -i '1,/<!-- TERRAFORM-DOCS-GENERATION -->/!d' README.md; terraform-docs markdown . >> README.md"
.PHONY: readme

## Generate markdown documentation for all modules
all-readme:
	cat .generate-all-readme.sh | docker-compose run --rm terra bash
.PHONY: all-readme
