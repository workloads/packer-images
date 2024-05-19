# This file contains shared Packer and Packer Builder configuration.
#
# The contents are made available to ALL Packer Templates through a symlink
# from `/packer/<target>/variables_shared.pkr.hcl` to `/packer/variables_shared.pkr.hcl`.

# global Packer configuration, applies to all templates in this repository
# this section should exclusively be used to define the `required_version` constraint
# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  # allow minor-level updates; ensure this version is in sync with `.github/workflows/packer.yml`
  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer#version-constraint-syntax
  required_version = ">= 1.10.0, < 2.0.0"
}

locals {
  packer = {
    # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/uuid/uuidv4
    uuid = uuidv4()

    # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/contextual-variables#packer-version
    version = "${packer.version}"
  }
}

# see https://developer.hashicorp.com/packer/docs/builders/file
source "file" "configuration" {
  content = templatefile(local.templates.configuration.input, {
    # merge common config (`var.shared`) and other relevant configuration,
    # then YAML-encode it for consumption as configuration through Ansible
    # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/encoding/yamlencode
    configuration = yamlencode(local.configuration_data)

    packer_version = local.packer.version
    timestamp      = local.timestamp.human
  })

  target = local.templates.configuration.output
}

# see https://developer.hashicorp.com/packer/docs/builders/file
source "file" "information" {
  content = local.information_input
  target  = local.templates.information.output
}

# render configuration and information templates for downstream consumption
# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "0-pre-build"

  sources = [
    "source.file.configuration",
    "source.file.information"
  ]
}

# render (binary) image from template and configuration data
# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build
build {
  name = "1-build"

  sources = [
    "source.${var.template_provider}.main",
  ]

  # see https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible
  provisioner "ansible" {
    ansible_env_vars        = var.ansible_env_vars
    command                 = var.ansible_command
    extra_arguments         = local.ansible_extra_arguments
    galaxy_command          = var.ansible_galaxy_command
    galaxy_file             = var.ansible_galaxy_file
    galaxy_force_install    = var.ansible_galaxy_force_install
    inventory_file_template = var.ansible_inventory_file_template
    playbook_file           = var.ansible_playbook_file
    skip_version_check      = var.ansible_skip_version_check
    use_proxy               = var.ansible_use_proxy
  }

  # see https://mondoo.com/docs/cnspec/supplychain/packer/
  # and https://console.mondoo.com/space/integrations/add/hashicorp/packer
  provisioner "cnspec" {
    asset_name      = "${local.image.name}-${local.image.version}"
    on_failure      = var.cnspec_on_failure
    score_threshold = var.cnspec_score_threshold

    sudo {
      active = var.cnspec_sudo_active
    }

    # map `local.tags` to Mondoo Annotations for better traceability
    annotations = local.tags
  }

  # see https://developer.hashicorp.com/packer/docs/post-processors/checksum#checksum-post-processor
  post-processor "checksum" {
    checksum_types      = var.shared.checksum_types
    keep_input_artifact = true
    output              = local.templates.checksum.output
  }

  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/build/hcp_packer_registry
  hcp_packer_registry {
    bucket_name = local.hcp_packer_registry_bucket_name
    description = local.hcp_packer_registry_description


    # use common tags for better traceability
    bucket_labels = local.tags
    build_labels  = local.run_tags
  }
}
