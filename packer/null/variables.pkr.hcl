# This file is automatically loaded by Packer

locals {
  source = {
    image = "null-image"
  }

  # clean up source image name for downstream usage
  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/string/replace
  source_image_name_clean = replace(local.source.image, "-*", "")

  run_tags = {}

  tags = {}
}
