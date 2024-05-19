# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {
  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer#specifying-plugin-requirements
  required_plugins {
    # see https://developer.hashicorp.com/packer/integrations/hashicorp/amazon
    amazon = {
      source = "github.com/hashicorp/amazon"

      # allow patch-level updates to the plugin
      version = "~> 1.3.0"
    }

    # see https://developer.hashicorp.com/packer/integrations/hashicorp/ansible
    ansible = {
      source = "github.com/hashicorp/ansible"

      # allow patch-level updates to the plugin
      version = "~> 1.1.0"
    }

    # see https://developer.hashicorp.com/packer/integrations/mondoohq/cnspec
    cnspec = {
      source = "github.com/mondoohq/cnspec"

      # allow patch-level updates to the plugin
      version = "~> 6.2.0"
    }
  }
}

# see https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/data-source/ami
data "amazon-ami" "image" {
  # this filter is designed to find the most recent AMI that matches the given constraints (name, etc.)
  # depending on the source image, this may not result in the same source AMI being selected each time
  filters = {
    name                = "${var.source_image_family}/images/${var.ami_virtualization_type}-ssd/${var.source_image_name}"
    root-device-type    = "ebs"
    virtualization-type = var.ami_virtualization_type
  }

  most_recent = var.source_image_owner.most_recent
  owners      = var.source_image_owner.owners
  region      = var.region
}

locals {
  # `local.source` will be merged into `local.information_input` once the data source has been evaluated.
  source = {
    image = data.amazon-ami.image.id
  }
}

# see https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs
source "amazon-ebs" "main" {
  # the following configuration represents a curated variable selection
  # for all options see: https://developer.hashicorp.com/packer/integrations/hashicorp/amazon/latest/components/builder/ebs

  ami_description = var.ami_description
  ami_groups      = var.ami_groups

  # AMI Name should be short and memorable
  ami_name = local.image.name

  ami_product_codes           = var.ami_product_codes
  ami_regions                 = var.ami_regions
  ami_users                   = var.ami_users
  ami_virtualization_type     = var.ami_virtualization_type
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = var.availability_zone

  aws_polling {
    delay_seconds = var.aws_polling.delay_seconds
    max_attempts  = var.aws_polling.max_attempts
  }

  communicator          = var.template_communicator
  custom_endpoint_ec2   = var.custom_endpoint_ec2
  disable_stop_instance = var.disable_stop_instance
  ebs_optimized         = var.ebs_optimized

  # enable this if `var.instance_type` is of type T2, T3, or T4g
  #enable_unlimited_credits = var.enable_unlimited_credits

  ena_support           = var.ena_support
  encrypt_boot          = var.encrypt_boot
  force_delete_snapshot = var.force_delete_snapshot
  force_deregister      = var.force_deregister
  iam_instance_profile  = var.iam_instance_profile
  imds_support          = var.imds_support
  instance_type         = var.instance_type
  kms_key_id            = var.kms_key_id
  profile               = var.profile
  region                = var.region
  region_kms_key_ids    = var.region_kms_key_ids
  run_tags              = local.run_tags

  security_group_filter {
    filters = var.security_group_filter
  }

  security_group_ids           = var.security_group_ids
  shutdown_behavior            = var.shutdown_behavior
  skip_create_ami              = var.skip_create_ami
  skip_credential_validation   = var.skip_credential_validation
  skip_metadata_api_check      = var.skip_metadata_api_check
  skip_profile_validation      = var.skip_profile_validation
  skip_region_validation       = var.skip_region_validation
  skip_save_build_region       = var.skip_save_build_region
  snapshot_groups              = var.snapshot_groups
  snapshot_users               = var.snapshot_users
  ssh_clear_authorized_keys    = var.shared.communicator.ssh_clear_authorized_keys
  ssh_disable_agent_forwarding = var.shared.communicator.ssh_disable_agent_forwarding
  ssh_username                 = var.template_image_username
  source_ami                   = data.amazon-ami.image.id
  subnet_id                    = var.subnet_id
  tags                         = local.tags
  vpc_id                       = var.vpc_id
}
