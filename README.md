# Packer Templates: HashiCorp Nomad

> Packer Templates for HashiCorp Nomad (incl. Consul, and Vault) for multiple (Cloud) Platforms

## Table of Contents

- [Packer Templates: HashiCorp Nomad](#packer-templates-hashicorp-nomad)
  - [Table of Contents](#table-of-contents)
  - [Requirements](#requirements)
  - [Usage](#usage)
  - [Notes](#notes)
  - [Author Information](#author-information)
  - [License](#license)

## Requirements

- Packer `1.7.0` or newer
- Terraform `0.14.9` or newer
- Ansible `2.9.6` or newer

Ansible is used for system-level operations (e.g.: installing and removing packages).

Terraform is used as a helper, only. It is possible (though not advised) to manually create the resources needed.

## Usage

This repository contains Packer templates for multiple providers.

The primary way of interacting with this repository is `make` via a [Makefile](Makefile).

This allows for a consistent execution of the underlying workflows.

The workflow for (most) providers is as follows:

- log in to provider's CLI interface
- create prerequisite resources
  - initialize Terraform (using `make terraform-init target=provider`)
  - create Terraform-managed resources (using `make terraform-apply target=provider`)
- create image(s)
  - initialize Packer (using `make init target=provider`)
  - build Packer-managed image(s) (using `make build target=provider`)
- optionally: delete prerequisite resources
  - delete Terraform-managed resources (using `make terraform-destroy target=provider`)

Usage differs slightly for each provider and is therefore broken out into separate sections.

See the `packer/` (and `terraform/`) subdirectories for more information.

> All workflows _can_ be executed manually. See the [Makefile](Makefile) for more information.

## Notes

This repository takes input and inspiration from a handful of community projects. The authors would like to thank: [@ansible-community](https://github.com/ansible-community) in particular.

## Author Information

This repository is maintained by the contributors listed on [GitHub](https://github.com/operatehappy/packer-nomad/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may obtain a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an _"AS IS"_ basis, without WARRANTIES or conditions of any kind, either express or implied.

See the License for the specific language governing permissions and limitations under the License.
