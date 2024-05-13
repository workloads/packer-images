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
YAMLLINT_CONFIG        ?= .yaml-lint.yml
YAMLLINT_FORMAT        ?= colored
TITLE                   = 🔵 PACKER TEMPLATES

# TODO: fix logic
# conditionally load Target-specific configuration if present
ifneq ($(wildcard $(DIR_PACKER)/$(strip $(builder))/extras.mk),)
	include $(DIR_PACKER)/$(strip $(builder))/extras.mk
endif

# expose relevant information to Packer
var_ansible_command       = -var 'ansible_command=$(BINARY_ANSIBLE)'
var_ansible_galaxy_file   = -var 'ansible_galaxy_file=$(ANSIBLE_REQUIREMENTS)'
var_ansible_playbook_file = -var 'ansible_playbook_file=$(ANSIBLE_PLAYBOOK)'
var_dir_dist              = -var 'dir_dist=$(DIR_DIST)'
var_dir_templates         = -var 'dir_templates=$(DIR_TEMPLATES)'
var_template_arch         = -var 'template_arch=$(arch)'
var_template_builder      = -var 'template_builder=$(builder)'
var_template_os           = -var 'template_os=$(os)'
var_template_provider     = -var 'template_provider=$(provider)'

# enable dev mode and configure corresponding packages
var_developer_mode = -var 'developer_mode=false'

ifdef dev
var_developer_mode = -var 'developer_mode=true'
endif

# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/onlyexcept#except-foo-bar-baz
extra_except_args =
args_only         =
args_except       =

# if `builder` is not null, pass `provider` to Packer
ifneq ($(builder),null)
	args_only = -only="1-provisioners.$(provider).main"
endif

ifneq ($(extra_except_args),)
	args_except = -except="$(extra_except_args)"
endif

# convenience handles for ALL CLI arguments
ansible_cli_args  = $(var_ansible_command) $(var_ansible_galaxy_file) $(var_ansible_playbook_file)
directory_cli_args = $(var_dir_dist) $(var_dir_templates)
template_cli_args = $(var_template_builder) $(var_template_provider) $(var_template_os) $(var_template_arch)
varsfile_cli_args = -var-file="$(DIR_BUILD)/$(os)_$(arch).pkrvars.hcl"
cli_args          = $(args_only) $(args_except) $(template_cli_args) $(directory_cli_args) $(ansible_cli_args) $(var_developer_mode) $(varsfile_cli_args)

# include common and Packer-specific Makefile logic
include ../tooling/make/configs/shared.mk
include ../tooling/make/functions/shared.mk
include ../tooling/make/functions/packer.mk
include ../tooling/make/targets/packer.mk
include ../tooling/make/targets/shared.mk

.SILENT .PHONY: init
init: # initialize a Packer Template [Usage: `make init builder=<builder> os=<os>`]
	$(if $(builder),,$(call missing_argument,builder=<builder>))

	$(call print_args)
	$(call packer_init,"$(DIR_BUILD)")

.SILENT .PHONY: lint
lint: # lint a Packer Template [Usage: `make lint builder=<builder> provider=<provider> os=<os> arch=<arch>`]
	$(if $(builder),,$(call missing_argument,builder=<builder>))
	$(if $(provider),,$(call missing_argument,provider=<provider>))
	$(if $(os),,$(call missing_argument,os=<os>))
	$(if $(arch),,$(call missing_argument,arch=<arch>))

	$(call print_args)
	$(call packer_lint,"$(DIR_BUILD)")

.SILENT .PHONY: build
build: # build a Packer Template [Usage: `make build builder=<builder> provider=<provider> os=<os> arch=<arch>`]
	$(if $(builder),,$(call missing_argument,builder=<builder>))
	$(if $(provider),,$(call missing_argument,provider=<provider>))
	$(if $(os),,$(call missing_argument,os=<os>))
	$(if $(arch),,$(call missing_argument,arch=<arch>))

	$(call print_args)
	$(call packer_build,"$(DIR_BUILD)")

.SILENT .PHONY: docs
docs: # generate documentation for a Packer Templates [Usage: `make docs builder=<builder>`]
	$(if $(target),,$(call missing_argument,builder=<builder>))

	# TODO: align with overall `render_documentation` function
	$(call render_documentation,$(DIR_BUILD)),shared.pkr.hcl,$(DOCS_CONFIG),sample.pkrvars.hcl)

.SILENT .PHONY: console
console: # start Console for a Packer Template [Usage: `make console builder=<builder> provider=<provider> os=<os> arch=<arch>`]
	$(if $(builder),,$(call missing_argument,builder=<builder>))
	$(if $(provider),,$(call missing_argument,provider=<provider>))
	$(if $(os),,$(call missing_argument,os=<os>))
	$(if $(arch),,$(call missing_argument,arch=<arch>))

	$(call print_args)
	$(call packer_console,"$(DIR_BUILD)")

.SILENT .PHONY: ansible_init
ansible_init: # initialize Ansible Collections and Roles [Usage: `make ansible_init`]
	$(call print_reference,$(ANSIBLE_REQUIREMENTS))

	echo

	# see https://docs.ansible.com/ansible/latest/cli/ansible-galaxy.html
	$(BINARY_ANSIBLE_GALAXY) \
		install \
			--role-file "$(ANSIBLE_REQUIREMENTS)" \
			--force

	echo

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
