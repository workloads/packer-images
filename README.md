# Packer Templates

> This repository manages Packer Templates for [@workloads](https://github.com/workloads).

## Table of Contents

<!-- TOC -->
* [Packer Templates](#packer-templates)
  * [Table of Contents](#table-of-contents)
  * [Requirements](#requirements)
  * [Usage](#usage)
    * [Workflow](#workflow)
  * [Notes](#notes)
    * [Ansible outside Packer](#ansible-outside-packer)
    * [Development Helpers](#development-helpers)
    * [Overriding Binaries](#overriding-binaries)
    * [Colorized Output](#colorized-output)
    * [Acknowledgements](#acknowledgements)
  * [Contributors](#contributors)
  * [License](#license)
<!-- TOC -->

## Requirements

- HashiCorp Packer `1.10.0` or [newer](https://developer.hashicorp.com/packer/downloads)
- Ansible `2.15.0` or [newer](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- a check-out of [@workloads/tooling](https://github.com/workloads/tooling)

Optional, and only needed for development and testing of Packs:

- `terraform-docs` `0.17.0` or [newer](https://terraform-docs.io/user-guide/installation/)
- `ansible-lint` `24.5.0` or [newer](https://ansible.readthedocs.io/projects/lint/installing/)

## Usage

This repository provides a [Makefile](./Makefile)-based workflow.

Running `make` without commands will print out the following help information:

```text
🔵 PACKER TEMPLATES

init                initialize a Packer Template                                      `make init target=<target> os=<os>`
lint                lint a Packer Template                                            `make lint template=<target> os=<os>`
build               build a Packer Template                                           `make build target=<target> builder=<builder> os=<os>`
docs                generate documentation for a Packer Template                      `make docs target=<target>`
console             start Console for a Packer Template                               `make console target=<target> os=<os>`
ansible_init        initialize Ansible Collections and Roles                          `make ansible_init`
ansible_inventory   construct an Ansible Inventory                                    `make ansible_inventory host=<host> user=<user>`
ansible_lint        lint Ansible Playbooks                                            `make ansible_lint`
ansible_local       run Ansible directly, outside of Packer                           `make ansible_local`
cloudinit_lint      lint cloud-init user data files using Alpine (via Docker)         `make cloudinit_lint path=templates/user-data.yml`
yaml_lint           lint YAML files                                                   `make yaml_lint`
_clean              remove generated files                                            `make _clean`
_dist               quickly open the generated files directory (macOS only)           `make _dist`
_pd                 quickly open Parallels Desktop (macOS only)                       `make _pd`
_vb                 quickly open VirtualBox (macOS only)                              `make _vb`
_kill_vb            force-kill all VirtualBox processes (macOS only)                  `make _kill_vb`
_link_vars          create a symlink to the shared variables file for a new target    `make _link_vars target=my_target`
help                display a list of Make Targets                                    `make help`
_listincludes       list all included Makefiles and *.mk files                        `make _listincludes`
_selfcheck          lint Makefile                                                     `make _selfcheck`
```

### Workflow

The workflow for (most) targets is as follows:

- log in to provider's CLI interface
- create image(s)
  - initialize Packer (using `make init target=target`)
  - build Packer-managed image(s) (using `make build target=target`)

Usage differs slightly for each provider and is therefore broken out into separate sections.

See the `packer/` subdirectory for more information.

> All workflows _may_ be executed manually, though this is not advisable. See the [Makefile](./Makefile) for more information.

## Notes

### Ansible outside Packer

For rapid development and an improved feedback loop, Ansible may be run outside a Packer workflow. To do this, an [Ansible Inventory](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) may be created like so:

```shell
make ansible_inventory host=<hostname or IP address> user=vagrant
```

This will write an Ansible Inventory file to `$(ANSIBLE_INVENTORY)` (e.g.: `$(DIR_DIST)/inventory.txt`)

Once present, Ansible may be executed using `make ansible_local`

### Development Helpers

The [Makefile](./Makefile) includes several unsupported helper targets that _may_ be useful when developing additional templates and functionality.

These targets are prefixed with an underscore (`_`) and may be removed at any time.

### Overriding Binaries

* The binaries for Ansible (`ansible`, `ansible-galaxy`, `ansible-lint`), Docker (`docker`), Packer (`packer`), Vagrant (`vagrant`) and `yaml-lint` may be overridden by setting their respective `BINARY_` equivalent arguments when running the [Makefile](./Makefile):

```shell
# override Ansible binaries
make render pack=<pack> BINARY_ANSIBLE=/tmp/ansible BINARY_ANSIBLE_GALAXY=/tmp/ansible-galaxy

# override Docker binary
make render pack=<pack> BINARY_DOCKER=custom-docker-binary
```

A complete list of overridable binaries can be found in the [Makefile](./Makefile).

### Colorized Output

Colorized CLI output may be disabled by setting the `NO_COLOR` environment variable to any non-empty value.

```shell
export NO_COLOR=1 && make
```

### Acknowledgements

This repository takes input and inspiration from a handful of community projects.

The authors would like to thank the following parties for their contributions:

* [@ansible-community](https://github.com/ansible-community?q=hashicorp)
* [Mark Lewis](https://github.com/ml4/base)
* [Mike Nomitch](https://github.com/mikenomitch/nomatic-stack)
* [Ryan Johnson](https://github.com/vmware-samples/packer-examples-for-vsphere)

## Contributors

For a list of current (and past) contributors to this repository, see [GitHub](https://github.com/workloads/packer-templates/graphs/contributors).

## License

Licensed under the Apache License, Version 2.0 (the "License").

You may download a copy of the License at [apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0).

See the License for the specific language governing permissions and limitations under the License.
