packer {
  required_plugins {
    # see https://developer.hashicorp.com/packer/plugins/builders/vagrant
    vagrant = {
      # see https://github.com/hashicorp/packer-plugin-vagrant/releases/
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/vagrant"
    }

    # see https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible
    ansible = {
      # see https://github.com/hashicorp/packer-plugin-ansible/releases/
      version = ">= 1.0.3"
      source  = "github.com/hashicorp/ansible"
    }

    # see https://developer.hashicorp.com/packer/plugins/provisioners/mondoo/cnspec
    cnspec = {
      # see https://github.com/mondoohq/packer-plugin-cnspec/releases/tag/v6.2.0
      version = ">= 6.2.0"
      source  = "github.com/mondoohq/cnspec"
    }
  }
}

locals {
  box_version = local.sources[var.os][var.target].source.version
}

# see https://developer.hashicorp.com/packer/plugins/builders/vagrant
source "vagrant" "virtualbox" {
  # the following configuration represents a curated variable selection
  # for all options see: https://developer.hashicorp.com/packer/plugins/builders/vagrant#optional

  add_force                    = var.add_force
  box_name                     = local.image.name
  box_version                  = local.box_version
  checksum                     = local.sources[var.os][var.target].source.checksum
  communicator                 = "ssh"
  output_dir                   = "${var.dist_dir}/${var.target}"
  provider                     = "virtualbox"
  skip_add                     = var.skip_add
  source_path                  = local.sources[var.os][var.target].source.path
  ssh_clear_authorized_keys    = var.shared.communicator.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.shared.communicator.ssh_disable_agent_forwarding
  teardown_method              = var.teardown_method
  template                     = "./packer/${var.target}/Vagrantfile"
}

# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "1-provisioners"

  sources = [
    "source.vagrant.virtualbox",
  ]

  # see https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible
  provisioner "ansible" {
    ansible_env_vars   = var.shared.ansible.ansible_env_vars
    command            = var.shared.ansible.command
    extra_arguments    = local.ansible_extra_arguments
    galaxy_file        = var.shared.ansible.galaxy_file
    playbook_file      = var.shared.ansible.playbook_file
    skip_version_check = var.shared.ansible.skip_version_check
  }

  # see https://developer.hashicorp.com/packer/docs/post-processors/checksum#checksum-post-processor
  post-processor "checksum" {
    checksum_types      = var.shared.checksum_types
    keep_input_artifact = true
    output              = local.templates.checksum.output
  }

  # see https://developer.hashicorp.com/packer/plugins/post-processors/vagrant/vagrant-cloud
  post-processor "vagrant-cloud" {
    access_token        = local.vagrant_cloud_access_token
    box_tag             = "${var.vagrant_cloud_organization}/${local.image.name}"
    no_release          = var.vagrant_cloud_no_release
    keep_input_artifact = var.vagrant_cloud_keep_input_artifact
    version             = local.box_version
    version_description = local.information_input
  }
}