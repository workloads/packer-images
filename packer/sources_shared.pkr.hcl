locals {
  # mappings table for OS source image and connection information
  sources = {
    # Ubuntu 22.04 LTS (Jammy Jellyfish)
    # see https://releases.ubuntu.com/22.04/
    ubuntu22 = {
      aws = {
        allow_downgrade = true
        tools           = merge(local.tools, {})
      }

      null = {
        allow_downgrade = true
        tools           = merge(local.tools, {})
      }
    }

    # Ubuntu 22.04 LTS (Jammy Jellyfish) for ARM
    # see https://cdimage.ubuntu.com/releases/22.04/release/
    ubuntu22_arm = {
      null = {
        allow_downgrade = true
        tools           = merge(local.tools, {})
      }
    }
  }

  # Target-specific Tools Configuration
  tools = {
    docker = {
      component = "stable"
      key       = "https://download.docker.com/linux/ubuntu/gpg"
      packages  = local.repositories.docker.packages
      url       = "https://download.docker.com/linux/ubuntu"
    }

    hashicorp = {
      component = "main"
      key       = "https://apt.releases.hashicorp.com/gpg"
      packages  = local.repositories.hashicorp.packages
      url       = "https://apt.releases.hashicorp.com"
    }

    osquery = {
      component = "main"

      # Key ID can be retrieved from https://osquery.io/downloads/ (`Alternative Install Options`)
      # and can then be mapped to a PGP Public Key block using the upstream Keyserver (`pub`)
      key      = "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x1484120ac4e9f8a1a577aeee97a80c63c9d8b80b"
      packages = local.repositories.osquery.packages
      url      = "https://pkg.osquery.io/deb"
    }
  }
}
