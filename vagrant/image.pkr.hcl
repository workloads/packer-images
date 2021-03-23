# see https://www.packer.io/docs/builders/vagrant
source "vagrant" "nomad" {
  # the following configuration represents a minimally viable selection
  # for all options see: https://www.packer.io/docs/builders/vagrant

  communicator = "ssh"
  source_path  = var.source_path
  provider     = "virtualbox"
  add_force    = true
  output_dir   = "vagrant-nomad"
}

build {
  sources = [
    "source.vagrant.nomad"
  ]

  provisioner "ansible" {
    playbook_file = "./playbooks/main.yml"
    command       = "ansible-playbook"
    ansible_env_vars = [
      "ANSIBLE_NOCOLOR=True",
      "ANSIBLE_NOCOWS=True"
    ]
  }

  # Vagrant Cloud post-provisioning (https://www.packer.io/docs/post-processors/vagrant-cloud)
  post-processor "vagrant-cloud" {
    box_tag = var.box_tag
    version = var.version
  }
}

