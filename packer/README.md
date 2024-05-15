# Packer Templates

This directory contains templates for various providers.

All templates _MUST_ inherit the following shared files through symbolic links:

* [`builders_shared.pkr.hcl`](./builders_shared.pkr.hcl), for common `builder` configuration
* [`plugins_shared.pkr.hcl`](./plugins_shared.pkr.hcl), for common `plugin` configuration
* [`variables_shared.pkr.hcl`](./variables_shared.pkr.hcl), for common `variable` configuration

## Making shared configuration accessible to a template

To make the shared configuration accessible to a template, the `_link_vars` target inside the [Makefile](../Makefile) can be used:

```shell
make _link_vars target=<target>
 ```
