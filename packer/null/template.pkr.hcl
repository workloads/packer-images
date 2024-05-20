# see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/blocks/packer
packer {}

# see https://developer.hashicorp.com/packer/docs/builders/null
source "null" "main" {
  # The `null` provider supports SSH connections and may be used in conjunction with Ansible.
  # At this point, the `null` provider is only used for rapid testing of `configuration.yml`.

  # see https://developer.hashicorp.com/packer/docs/templates/legacy_json_templates/communicator#none
  # communicator = "none"
}
