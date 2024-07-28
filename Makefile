# Makefile for Packer Template Building Management

# configuration
ARGS                   :=
ANSIBLE_INVENTORY      ?= $(DIR_DIST)/inventory.txt
ANSIBLE_PLAYBOOK       ?= $(DIR_ANSIBLE)/playbooks/main.yml
ANSIBLE_REQUIREMENTS   ?= $(DIR_ANSIBLE)/requirements.yml
ANSIBLELINT_CONFIG     ?= .ansible-lint.yml
ANSIBLELINT_FORMAT     ?= full
ANSIBLELINT_SARIF_FILE  = $(DIR_DIST)/ansible-lint.sarif
BINARY_ANSIBLE         ?= ansible-playbook
BINARY_ANSIBLE_GALAXY  ?= ansible-galaxy
BINARY_ANSIBLE_LINT    ?= ansible-lint
BINARY_DOCKER          ?= docker
BINARY_PACKER          ?= packer
BINARY_VAGRANT         ?= vagrant
BINARY_YAMLLINT        ?= yamllint
CLOUDINIT_DIRECTORY    ?= $(shell dirname ${path})
CLOUDINIT_FILE         ?= $(shell basename ${path})
CLOUDINIT_LINT_IMAGE   ?= "ghcr.io/workloads/alpine-with-cloudinit:latest" # full content address is supported but not required
DIR_ANSIBLE            ?= ansible
DIR_BUILD               = $(DIR_PACKER)/$(builder)
DIR_DIST               ?= dist
DIR_PACKER             ?= packer
DIR_TEMPLATES          ?= ../templates
DOCS_CONFIG             = .packer-docs.yml
FILES_SHARED					 ?= "variables_shared.pkr.hcl" "builders_shared.pkr.hcl"
MAKEFILE_TITLE          = 🔵 PACKER TEMPLATES

.SILENT .PHONY: ansible_inventory
ansible_inventory: # construct an Ansible Inventory [Usage: `make ansible_inventory host=<host> user=<user>`]
	$(if $(host),,$(call missing_argument,host=<host>))
	$(if $(user),,$(call missing_argument,user=<user>))

	echo "\
[all:vars] \n \
\t ansible_user=$(user) \n \
\t ansible_port=22 \n \
\t ansible_ssh_pass=$(user) \n \
\n \
[default] \n \
\t $(host)" \
> $(ANSIBLE_INVENTORY)

.SILENT .PHONY: ansible_lint
ansible_lint: # lint Ansible Playbooks [Usage: `make ansible_lint`]
	# create directory for `ansible-lint` SARIF output
	$(call safely_create_directory,$(DIR_DIST))

	rm -rf "$(ANSIBLELINT_SARIF_FILE)"

	# lint Ansible files and output SARIF results
	$(BINARY_ANSIBLE_LINT) \
		--config "$(CONFIG_ANSIBLELINT)" \
		--format "$(FORMAT_ANSIBLELINT)" \
    --sarif-file="$(ANSIBLELINT_SARIF_FILE)" \
		--fix="all" \
		"$(ANSIBLE_PLAYBOOK)"

.SILENT .PHONY: ansible_local
ansible_local: # run Ansible directly, outside of Packer [Usage: `make ansible_local`]
	export ANSIBLE_CONFIG="$(DIR_ANSIBLE)/ansible.cfg" \
	&& \
	$(BINARY_ANSIBLE) \
		--ask-pass \
		--ask-become-pass \
		--connection="smart" \
		--extra-vars "ConfigFile=$(DIR_DIST)/configuration.yml InfoFile=$(DIR_DIST)/README.md" \
		--inventory-file "$(ANSIBLE_INVENTORY)" \
		$(ANSIBLE_PLAYBOOK)

.SILENT .PHONY: cloudinit_lint
cloudinit_lint: # lint cloud-init user data files using Alpine (via Docker) [Usage: `make cloudinit_lint path=templates/user-data.yml`]
	$(if $(path),,$(call missing_argument,path=templates/user-data.yml))

	$(call print_arg,path,$(path))

	echo $(CLOUDINIT_DIRECTORY)

	# run an interactive Docker container that self-removes on completion
	$(BINARY_DOCKER) \
		run \
			--interactive \
			--quiet \
			--rm \
			--tty \
			--volume "$(CLOUDINIT_DIRECTORY):/config/" \
			$(CLOUDINIT_LINT_IMAGE)

.SILENT .PHONY: _clean
_clean: # remove generated files [Usage: `make _clean`]
	$(call delete_target_path,$(DIR_DIST))

.SILENT .PHONY: _dist
_dist: # quickly open the generated files directory (macOS only) [Usage: `make _dist`]
	open $(DIR_DIST)

.SILENT .PHONY: _pd
_pd: # quickly open Parallels Desktop (macOS only) [Usage: `make _pd`]
	open \
		-a "Parallels Desktop"

.SILENT .PHONY: _vb
_vb: # quickly open VirtualBox (macOS only) [Usage: `make _vb`]
	open \
		-a "VirtualBox"

.SILENT .PHONY: _kill_vb
_kill_vb: # force-kill all VirtualBox processes (macOS only) [Usage: `make _kill_vb`]
	# `9`  = signal number
	# `-f` = match against the full argument list instead of just process names
	pkill \
		-9 \
		-f "VBox"
