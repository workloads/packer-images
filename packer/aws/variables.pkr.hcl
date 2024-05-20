# This file is automatically loaded by Packer

variable "ami_description" {
  type        = string
  description = "The description to set for the resulting AMI(s)."
  default     = ""
}

variable "ami_groups" {
  type        = list(string)
  description = "A list of groups that have access to launch the resulting AMI(s)."

  default = []
}

variable "ami_name" {
  type        = string
  description = "(Required) The name of the resulting AMI that will appear when managing AMIs in the AWS console or via APIs."
  default     = ""
}

variable "ami_product_codes" {
  type        = list(string)
  description = "A list of product codes to associate with the AMI."

  default = []
}

variable "ami_regions" {
  type        = list(string)
  description = "A list of regions to copy the AMI to."

  default = []
}

variable "ami_users" {
  type        = list(string)
  description = "A list of account IDs that have access to launch the resulting AMI(s)."

  default = []
}

variable "ami_virtualization_type" {
  type        = string
  description = "The type of virtualization for the AMI you are building."
  default     = "hvm"

  validation {
    condition = can(contains([
      "hvm",
      "paravirtual"
    ], var.ami_virtualization_type))

    error_message = "The AMI Virtualization Type must be one of \"hvm\", \"paravirtual\"."
  }
}

variable "associate_public_ip_address" {
  type        = bool
  description = "If this is true, your new instance will get a Public IP."

  # setting this to `false` requires that Packer is able to make a network connection
  # via an indirect way, which may include a NAT Gateway or a VPN connection
  default = true
}

variable "availability_zone" {
  type        = string
  description = "Destination availability zone to launch instance in."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
}

variable "aws_polling" {
  type = object({
    delay_seconds = number
    max_attempts  = number
  })

  description = "Polling configuration for the AWS waiter."

  default = {
    delay_seconds = 30
    max_attempts  = 50
  }
}

variable "ebs_optimized" {
  type        = bool
  description = "Mark instance as EBS Optimized."
  default     = false
}

variable "enable_unlimited_credits" {
  type        = bool
  description = "Enabling T2 Unlimited allows the source instance to burst additional CPU beyond its available CPU Credits for as long as the demand exists."
  default     = true
}

variable "ena_support" {
  type        = bool
  description = "Enable enhanced networking (ENA but not `SriovNetSupport`) on HVM-compatible AMIs."
  default     = false
}

variable "custom_endpoint_ec2" {
  type        = string
  description = "This option is useful if you use a cloud provider whose API is compatible with AWS EC2."
  default     = null
}

variable "disable_stop_instance" {
  type        = bool
  description = "Packer normally stops the build instance after all provisioners have run."
  default     = false
}

variable "encrypt_boot" {
  type        = bool
  description = "Whether or not to encrypt the resulting AMI when copying a provisioned instance to an AMI."
  default     = null
}

variable "force_delete_snapshot" {
  type        = bool
  description = "Force Packer to delete snapshots associated with AMIs, which have been deregistered by `force_deregister`."
  default     = false
}

variable "force_deregister" {
  type        = bool
  description = "Force Packer to first deregister an existing AMI if one with the same name already exists."
  default     = false
}

variable "iam_instance_profile" {
  type        = string
  description = "The name of an IAM instance profile to launch the EC2 instance with."
  default     = null
}

variable "imds_support" {
  type        = string
  description = "Enforce version of the Instance Metadata Service on the built AMI."
  default     = "v2.0"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type to use while building the AMI"

  # The default value of `m5.large` for the Packer-orchestrated EC2 Instance is in line with deployment suggestions from HashiCorp.
  # While Packer does not require the exact same instance type as the target deployment environment, we find it to be less error-prone.
  # see https://developer.hashicorp.com/nomad/tutorials/enterprise/production-reference-architecture-vm-with-consul#deployment-system-requirements
  default = "m5.large"
}

variable "kms_key_id" {
  type        = string
  description = "ID, alias or ARN of the KMS key to use for AMI encryption."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
  default = null
}

variable "profile" {
  type        = string
  description = "The profile to use in the shared credentials file for AWS."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
  default = null
}

variable "region" {
  type        = string
  description = "The name of the region in which to launch the EC2 instance to create the AMI."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
}

variable "region_kms_key_ids" {
  type        = map(string)
  description = "Regions to copy the AMI to, along with the custom KMS Key ID(Alias or ARN) to use for encryption for that region."

  default = {}
}

# this value will be enriched with the contents of local.tags_base
variable "run_tags" {
  type        = map(string)
  description = "Key/value pair tags to apply to the instance that is that is launched to create the EBS volumes."

  default = {}
}

variable "security_group_filter" {
  type        = map(string)
  description = "Filters used to populate the `security_group_ids` field."

  default = {}
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security groups as to assign to the instance."

  default = []
}

variable "shutdown_behavior" {
  type        = string
  description = "Automatically terminate instances on shutdown in case Packer exits ungracefully."
  default     = "stop"

  validation {
    condition     = can(contains(["stop", "terminate"], var.shutdown_behavior))
    error_message = "The Shutdown Behavior must be one of \"stop\", \"terminate\"."
  }
}

variable "skip_create_ami" {
  type        = bool
  description = "If true, Packer will not create the AMI."
  default     = false
}

variable "skip_credential_validation" {
  type        = bool
  description = "Set to true if you want to skip validating AWS credentials before runtime."
  default     = false
}

variable "skip_metadata_api_check" {
  type        = bool
  description = "Skip Metadata API Check."
  default     = false
}

variable "skip_profile_validation" {
  type        = bool
  description = "Whether or not to check if the IAM instance profile exists."
  default     = false
}

variable "skip_region_validation" {
  type        = bool
  description = "Set to true if you want to skip validation of the ami_regions configuration option."
  default     = false
}

variable "skip_save_build_region" {
  type        = bool
  description = "If true, Packer will not check whether an AMI with the `ami_name` exists in the region it is building in."
  default     = false
}

variable "snapshot_groups" {
  type        = list(string)
  description = "A list of groups that have access to create volumes from the snapshot(s)."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
  default = []
}

variable "snapshot_users" {
  type        = list(string)
  description = "A list of account IDs that have access to create volumes from the snapshot(s)."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
  default = []
}

variable "source_image_family" {
  type        = string
  description = "Family to filter AMI search on"

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
}

variable "source_image_name" {
  type        = string
  description = "Name to filter AMI search on."

  # The default for this should be specified in `./overrides.auto.pkrvars.hcl`
}

locals {
  # clean up source image name for downstream usage
  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/string/replace
  source_image_name_clean = replace(var.source_image_name, "-*", "")
}

#  the `filters` of `image` is defined in the `locals` stanza at the bottom of this file
variable "source_image_owner" {
  type = object({
    most_recent = bool

    # Filters the images by these owners.
    owners = list(string)
  })

  description = "Owner to filter AMI search on"
}

variable "subnet_id" {
  type        = string
  description = "If using VPC, the ID of the subnet, such as subnet-12345def, where Packer will launch the EC2 instance. This field is required if you are using an non-default VPC."
  default     = ""
}

variable "vpc_id" {
  type        = string
  description = "Requires subnet_id to be set. Used to create a temporary security group within the VPC. If this field is left blank, Packer will try to get the VPC ID from the subnet_id."
  default     = ""
}

locals {
  tags_base = {
    "image:builder"       = "Packer v${packer.version}"
    "image:source-id"     = local.source.image
    "image:source-name"   = data.amazon-ami.image.name
    "image:source-region" = var.region
    "image:version"       = local.image.version

    # Name is a special tag and must be unique in the AWS region
    "Name" = local.image_name_human

    # `nomad:type` defines if the initial intention of an AMI is to be used as a Nomad client or server
    "nomad:type" = var.nomad_type
  }

  tags_versions = {
    # TODO: populate with list of versions of primary tools
  }

  run_tags = merge(local.tags_base, var.run_tags)

  # assemble tags from common tags and version information
  tags = merge(local.tags_base, local.tags_versions)
}
