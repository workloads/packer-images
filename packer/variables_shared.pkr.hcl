# This file contains shared configurations.
#
# The contents are made available to ALL Packer Templates through a symlink
# from `/packer/<target>/variables_shared.pkr.hcl` to `/packer/variables_shared.pkr.hcl`.

variable "ansible_command" {
  type        = string
  description = "Ansible CLI Command."
  default     = "ansible-playbook"
}

variable "ansible_env_vars" {
  type        = list(string)
  description = "Ansible Environment Variables."

  # when in doubt, edit `../ansible/ansible.cfg` instead of `var.ansible_env_vars`
  default = [
    "ANSIBLE_CONFIG=../../ansible/ansible.cfg",
  ]
}

variable "ansible_galaxy_command" {
  type        = string
  description = "Ansible Galaxy CLI Command."
  default     = "ansible-galaxy"
}

variable "ansible_galaxy_file" {
  type        = string
  description = "Ansible Galaxy File."
  default     = "../../ansible/requirements.yml"
}

variable "ansible_galaxy_force_install" {
  type        = bool
  description = "Toggle to force-install (and overwrite) existing Ansible Galaxy Roles."
  default     = false
}

variable "ansible_inventory_file_template" {
  type        = string
  description = "Ansible Inventory File Template."
  default     = "{{ .HostAlias }} ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }}\n"
}

variable "ansible_playbook_file" {
  type        = string
  description = "Ansible Playbook File."
  default     = "../../ansible/playbooks/main.yml"
}

variable "ansible_skip_version_check" {
  type        = bool
  description = "Toggle to check if Ansible is installed prior to running."
  default     = false
}

variable "ansible_use_proxy" {
  type        = bool
  description = "Toggle to set up a `localhost` proxy adapter so that Ansible has an IP address to connect to, even if your guest does not have an IP address."
  default     = false
}

variable "ansible_verbosity" {
  type        = string
  description = "Ansible Verbosity Level."

  # acceptable values include:
  #
  #   null    - basic information only
  #   "-v"     - more detailed information
  #   "-vv    - detailed information on each task (incl. variables and results)
  #   "-vvv"  - adds debugging information about the control flow and decision-making process
  #   "-vvvv" - includes connection debugging and Ansible's internal operations
  #   "-vvvvv - outputs extremely detailed debugging information (incl. Python tracebacks and internal variable states)
  #
  # see https://docs.ansible.com/ansible/latest/cli/ansible-playbook.html#cmdoption-ansible-playbook-v
  default = "-v"
}

variable "cnspec_on_failure" {
  type        = string
  description = "Set to `continue` to ignore build failures that do not meet any set `score_threshold`."
  default     = "continue"
}

variable "cnspec_score_threshold" {
  type        = number
  description = "Set a score threshold for Packer builds. Any scans that fall below this value will fail the build process unless `on_failure` is set to `continue`."
  default     = 85
}

variable "cnspec_sudo_active" {
  type        = bool
  description = "Toggle to enable `sudo` for the `cnspec` provisioner."
  default     = false
}

# Advanced Users only: Dev Mode installs packages that are helpful
# when developing on one or more of the installed HashiCorp products;
variable "developer_mode" {
  type        = bool
  description = "Toggle to enable Developer Mode and configure developer-friendly tooling."
  default     = false
}

variable "dir_dist" {
  type        = string
  description = "Directory to store distributable artifacts in."
}

variable "dir_templates" {
  type        = string
  description = "Directory to retrieve templateized files from."
}

# `nomad_type` defines the primary intended role of the resulting image;
# as `client` and `server`
variable "nomad_type" {
  type        = string
  description = "Nomad Type, as received from `make`."
}

variable "shared" {
  type = object({
    enable_cis_hardening    = bool
    enable_debug_statements = bool
    enable_facts_statement  = bool

    checksum_types = list(string)

    communicator = object({
      ssh_clear_authorized_keys    = bool
      ssh_disable_agent_forwarding = bool
    })

    developer = object({
      go = object({
        version            = string
        install_dir_prefix = string
        modules            = list(string)
      })

      packages = object({
        to_install = list(string)
        to_remove  = list(string)
      })
    })

    os = object({
      enabled = bool

      directories = map(object({
        to_create = list(string)
        to_remove = list(string)
      }))

      toggles = map(bool)

      packages = map(object({
        to_install = list(string)
        to_remove  = list(string)
      }))
    })

    post_cleanup = object({
      enabled = bool
    })
  })

  description = "Shared Configuration for all Packer Templates."

  default = {
    # TODO: enable and add remediation options
    # feature flag to enable CIS roles for OS-hardening
    enable_cis_hardening = false

    # feature flag to enable installation and configuration of Datadog Agent
    enable_datadog_agent = false

    # feature flag to enable debug statements
    enable_debug_statements = true

    # feature flag to enable printing of Ansible Facts
    enable_facts_statement = false

    # Packer Checksum Post-Processor configuration
    # see https://developer.hashicorp.com/packer/docs/post-processors/checksum#checksum_types
    checksum_types = [
      "sha256"
    ]

    # Packer Machine Communicator-specific configuration:
    communicator = {
      # If true, Packer will attempt to remove its temporary keys.
      ssh_clear_authorized_keys = true

      # If true, SSH agent forwarding will be disabled.
      ssh_disable_agent_forwarding = true
    }

    # Developer Mode-specific configuration
    developer = {
      # Developer-Mode packages to manage
      packages = {
        to_install = []
        to_remove  = []
      }

      # Go-specific configuration
      go = {
        # see https://go.dev/doc/devel/release
        version = "1.22.0"

        # parent directory for all Go installations
        # individual versions will be installed into
        # version-specific directories: `/opt/go/<version>`
        install_dir_prefix = "/opt/go/"

        modules = [
          "github.com/go-delve/delve/cmd/dlv@latest"
        ]
      }
    }

    hashicorp = {
      enabled = true

      enabled_products = [
        "nomad",

        # `vault` is not currently enabled, as we only need an agent for usage with HCP Vault
        # "vault",
      ]

      toggles = {
        create_users             = true
        create_groups            = true
        create_users             = true
        add_nomad_user_to_docker = true
        copy_unit_files          = true
        enable_services          = true
        start_services           = true
      }
    }

    # OS-specific configuration
    os = {
      enabled = true

      # Directories to create and remove
      directories = {
        # Amazon Linux directories to manage
        Amazon = {
          to_create = []
          to_remove = []
        }

        # Debian / Ubuntu directories to manage
        Debian = {
          to_create = []
          to_remove = []
        }

        # generic Linux directories to manage
        Linux = {
          to_create = []

          to_remove = [
            "/etc/machine-id",
            "/tmp/ansible",
            "/var/lib/dbus/machine-id"
          ]
        }
      }

      # Packages to install and remove
      packages = {
        # Amazon Linux packages to manage
        Amazon = {
          to_install = [
            "amazon-ssm-agent"
          ]

          to_remove = []
        }

        # Debian / Ubuntu packages to manage
        Debian = {
          to_install = [
            "apt-transport-https",
          ]

          to_remove = [
            "ubuntu-release-upgrader-core"
          ]
        }

        # generic Linux packages to manage
        Linux = {
          to_install = [
            "ca-certificates",
            "curl", # see https://curl.se
            "gnupg",
            "jq", # see https://stedolan.github.io/jq/
            "libcap2",
            "lsb-release",
            "nano",
            "podman", # see https://podman.io
            "sudo",
            "unzip",

            # Linux Crisis Tools
            # see https://www.brendangregg.com/blog/2024-03-24/linux-crisis-tools.html
            "procps",
            "util-linux",
            "sysstat",
            "iproute2",
            "numactl",
            "tcpdump",
            "linux-tools-common",
            "bpfcc-tools",
            "bpftrace",
            "trace-cmd",
            "nicstat",
            "ethtool",
            "tiptop",
            "cpuid",
            "msr-tools",
          ]

          to_remove = [
            "dosfstools",
            "ftp",
            "fuse",
            "ntfs-3g",
            "ntp",
            "open-iscsi",
            "pastebinit",
            "snapd",
          ]
        }
      }

      toggles = {
        copy_nologin_file  = true
        copy_versions_file = true
        create_directories = true
        install_packages   = true
        remove_directories = true
        remove_packages    = true
        update_apt_cache   = true
        update_yum_cache   = true
      }
    }

    # Post-Cleanup Actions
    post_cleanup = {
      enabled = true
    }
  }
}

variable "source_image_checksum" {
  type        = string
  description = "Source Image Checksum."

  # The default for this should be overridden in `./overrides.auto.pkrvars.hcl`
  default = null
}

variable "source_image_file" {
  type        = string
  description = "Source Image File."

  # The default for this should be overridden in `./overrides.auto.pkrvars.hcl`
  default = null
}

variable "template_arch" {
  type        = string
  description = "Template Architecture, as received from `make`."
}

# variable "template_boot_command" {
#   type        = list(string)
#   description = "List of Commands to (automatically) type when the VM is first booted."
# }
#
# variable "template_boot_wait" {
#   type        = string
#   description = "Time to wait after booting the VM."
#   default     = "10s"
# }

variable "template_builder" {
  type        = string
  description = "Template Builder, as received from `make`."
}

# see https://developer.hashicorp.com/packer/docs/communicators/ssh
variable "template_communicator" {
  type        = string
  description = "Template Communicator."
  default     = "ssh"
}

variable "template_communicator_port" {
  type        = number
  description = "Port to use for Template Communicator."
  default     = 22
}

variable "template_communicator_timeout" {
  type        = string
  description = "Template Communicator Timeout."
  default     = "15m"
}

variable "template_image_hostname" {
  type        = string
  description = "Template Image Hostname."
  default     = null
}

variable "template_image_username" {
  type        = string
  description = "Template Communicator Username."
}

variable "template_os" {
  type        = string
  description = "Template OS, as received from `make`."
}

variable "template_provider" {
  type        = string
  description = "Template Provider, as received from `make`."
}

variable "template_target" {
  type        = string
  description = "Template Target, as received from `make`."
}

locals {
  # see https://developer.hashicorp.com/packer/plugins/provisioners/ansible/ansible-local#extra_arguments
  # and https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/collection/compact
  ansible_extra_arguments = compact([
    # set verbosity level
    var.ansible_verbosity == null ? "" : var.ansible_verbosity,

    # set extra vars
    "--extra-vars",
    "ConfigFile=${local.templates.configuration.output} InfoFile=${local.templates.information.output}",
  ])

  # assemble configuration data for easier use
  configuration_data = merge(var.shared, {
    developer_mode = var.developer_mode,

    nomad_plugins = local.nomad_plugins,
    nomad_type    = var.nomad_type,

    # OS and CPU architecture specific package configuration
    tools_allow_downgrade = local.sources[var.template_os][var.template_target].allow_downgrade,
    tools                 = local.sources[var.template_os][var.template_target].tools,

    user_groups = [
      for repository in local.repositories : repository.user_groups
    ]
  })

  # HCP Packer Registry-specific configuration

  # Bucket Name must be between 3 and 36 characters long
  # Acceptable inputs are letters, numbers, and hyphens
  hcp_packer_registry_bucket_name = "TODO-name-without-version-string"
  hcp_packer_registry_description = "TODO"

  # base image name, includes OS and CPU architecture
  image_name_base = "${var.template_os}-${var.template_arch}"

  # enriched image name, includes `dev` suffix if developer mode is active
  image_name_with_suffix = var.developer_mode ? "${local.image_name_base}-dev" : local.image_name_base

  # full image name, includes version and suffix
  image_name_full = "${local.image_name_with_suffix}-${local.timestamp.iso}"

  # full, human-readable image name
  # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/string/title
  image_name_human = "Nomad ${title(var.nomad_type)} on `${local.source_image_name_clean}`"

  # Packer Image-specific configuration
  image = {
    description = "Packer-built Image (Identifier: `${var.template_os}-${var.template_arch}`)"
    config_path = "${var.dir_dist}/${var.template_provider}/"
    name        = local.image_name_full
    output_name = "${var.template_os}_${var.template_arch}"
    output_path = "${var.dir_dist}/${var.template_provider}/${var.template_os}_${var.template_arch}"
    version     = local.timestamp.iso
  }

  # `local.information_input` is used to create an in-image `README.md` file
  # and for provider-specific cases such as Vagrant Cloud Box Descriptions
  information_input = templatefile(local.templates.information.input, {
    # merge image data and configuration data
    # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/collection/merge
    image = merge(local.image, {
      developer_mode = var.developer_mode,
      timestamp      = local.timestamp.human,
    })

    shared = local.configuration_data

    # `local.source` is populated inside `template.pkr.hcl`
    source = local.source
  })

  # Nomad Plugins-specific information
  nomad_plugins = {
    hashicorp_base_url = "https://releases.hashicorp.com"
    destination        = "/var/lib/nomad/plugins"

    plugins = {
      # see https://developer.hashicorp.com/nomad/tools/autoscaling
      # and https://releases.hashicorp.com/nomad-autoscaler/
      nomad-autoscaler = {
        official = true
        version  = "0.4.3"
      }

      # see https://releases.hashicorp.com/nomad-device-nvidia/
      nomad-device-nvidia = {
        official = true
        version  = "1.0.0"
      }

      # see https://developer.hashicorp.com/nomad/plugins/drivers/community/containerd
      # and https://github.com/Roblox/nomad-driver-containerd/releases
      nomad-driver-containerd = {
        official = false
        version  = "0.9.4"
        url      = "https://github.com/Roblox/nomad-driver-containerd/releases/download/v0.9.4/containerd-driver"
      }

      # see https://developer.hashicorp.com/nomad/plugins/drivers/remote/ecs (now deprecated)
      # and https://releases.hashicorp.com/nomad-driver-ecs/
      # nomad-driver-ecs = {
      #  # is this an official plugin? (e.g.: is it on `releases.hashicorp.com`)
      #  official = true
      #  version  = "0.1.0"
      # }

      # see https://developer.hashicorp.com/nomad/plugins/drivers/community/lxc (now deprecated)
      # and https://releases.hashicorp.com/nomad-driver-lxc/
      # nomad-driver-lxc = {
      #  # is this an official plugin? (e.g.: is it on `releases.hashicorp.com`)
      #  official = true
      #  version  = "0.1.0"
      # }

      # see https://developer.hashicorp.com/nomad/plugins/drivers/podman
      # and https://releases.hashicorp.com/nomad-driver-podman/
      nomad-driver-podman = {
        # is this an official plugin? (e.g.: is it on `releases.hashicorp.com`)
        official = true
        version  = "0.5.2"
      }
    }
  }

  repositories = {
    docker = {
      packages = {
        # prefer exact versions to avoid breaking changes,
        # this may necessitate a downgrade instead of keeping the current version
        allow_downgrades = true

        to_remove = [
          "docker",
          "docker-engine",
          "docker.io",
          "containerd",
          "runc",
        ]

        to_install = [
          {
            # see https://github.com/containerd/containerd/releases/
            name    = "containerd.io"
            version = "1.6.31-*"
          },
          {
            # see https://docs.docker.com/engine/release-notes/
            name    = "docker-ce"
            version = "5:26.1.2-*"
          },
          {
            # see https://docs.docker.com/engine/release-notes/
            name    = "docker-ce-cli"
            version = "5:26.1.2-*"
          },
        ]
      }

      user_groups = {
        group = "docker"

        users = [
          "docker",
        ]
      }
    }

    hashicorp = {
      packages = {
        # prefer exact versions to avoid breaking changes
        allow_downgrades = true

        to_remove = []

        to_install = [
          {
            # the `boundary-enterprise` package is needed for HCP Boundary
            # see https://releases.hashicorp.com/boundary/
            name    = "boundary-enterprise"
            version = "0.16.0+ent-*"
          },
          {
            # see https://releases.hashicorp.com/consul/
            name    = "consul"
            version = "1.18.1-*"
          },
          {
            # see https://releases.hashicorp.com/hcdiag/
            name    = "hcdiag"
            version = "0.5.3-*"
          },
          {
            # see https://releases.hashicorp.com/nomad/
            name    = "nomad"
            version = "1.7.7-*"
          },
          {
            # see https://releases.hashicorp.com/nomad-autoscaler/
            name    = "nomad-autoscaler"
            version = "0.4.3-*"
          },
          #         # TODO: enable when `tfc-agent` is available via apt
          #           {
          #             # see https://releases.hashicorp.com/tfc-agent/
          #             name    = "tfc-agent"
          #             version = "1.15.1"
          #           },
          {
            # see https://releases.hashicorp.com/vault/
            name    = "vault"
            version = "1.16.2-*"
          }
        ]
      }

      user_groups = {
        group = "hashicorp"

        users = [
          "boundary",
          "consul",
          "nomad",
          "tfc-agent",
          "vault",
        ]
      }
    }

    osquery = {
      packages = {
        # prefer exact versions to avoid breaking changes
        allow_downgrades = true

        to_remove = []

        to_install = [
          {
            # see https://osquery.io/downloads/official/
            name    = "osquery"
            version = "5.12.1-*"
          }
        ]
      }

      user_groups = {
        group = "osquery"

        users = [
          "osquery",
        ]
      }
    }
  }

  # Packer-generated Template file naming configuration:
  templates = {
    # see https://developer.hashicorp.com/packer/docs/post-processors/checksum#output
    checksum = {
      output = "${local.image.output_path}/CHECKSUMS"
    }

    # these paths are relative to the Packer Builder target
    configuration = {
      input  = "${var.dir_templates}/configuration.pkrtpl.yml"
      output = "${local.image.output_path}/configuration.yml"
    }

    information = {
      input  = "${var.dir_templates}/information.pkrtpl.md"
      output = "${local.image.output_path}/README.md"
    }
  }

  timestamp = {
    # see https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/datetime/formatdate
    # and https://developer.hashicorp.com/packer/docs/templates/hcl_templates/functions/datetime/timestamp
    iso   = formatdate("YYYYMMDD-hhmmss", timestamp())
    human = formatdate("YYYY-MM-DD 'at' hh:mm:ss '('ZZZZ')'", timestamp())
  }
}
