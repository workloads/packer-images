# Makefile for shipyard-blueprints

# configuration
MAKEFLAGS      = --no-builtin-rules --warn-undefined-variables
SHELL         := sh

.DEFAULT_GOAL := help
.ONESHELL     :
.SHELLFLAGS   := -eu -o pipefail -c

color_off      = $(shell tput sgr0)
color_bright   = $(shell tput bold)

.SILENT .PHONY: clear
clear:
	clear

.SILENT .PHONY: help
help: # Displays this help text
	$(info )
	$(info $(color_bright)PACKER TEMPLATES$(color_off))
	grep \
		--context=0 \
		--devices=skip \
		--extended-regexp \
		--no-filename \
			"(^[a-z-]+):{1} ?(?:[a-z-])* #" $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?# "}; {printf "\033[1m%s\033[0m;%s\n", $$1, $$2}' | \
	column \
		-c2 \
		-s ";" \
		-t
	$(info )

.PHONY: azure
azure: # Create Packer Image(s) in Azure
	@packer \
		build \
			-var-file="azure-variables.pkrvars.hcl" \
			"azure.pkr.hcl"

.PHONY: azure-terraform
azure-terraform: # Create prerequisite resources in Azure using Terraform
	@terraform \
		-chdir="./terraform/azure" \
		apply

.PHONY: azure-terraform-destroy
azure-terraform-destroy: # Destroy prerequisite resources in Azure using Terraform
	@terraform \
		-chdir="./terraform/azure" \
		destroy
