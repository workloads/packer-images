# Template: `null`

## Table of Contents

<!-- TOC -->
* [Template: `null`](#template-null)
  * [Table of Contents](#table-of-contents)
  * [Requirements](#requirements)
  * [Overview](#overview)
  * [Usage](#usage)
  * [Notes](#notes)
<!-- TOC -->

## Requirements

- HashiCorp Packer `1.10.0` or [newer](https://developer.hashicorp.com/packer/downloads)

## Overview

|                 | description                                    |
|-----------------|------------------------------------------------|
| image template  | n/a                                            |
| image variables | n/a                                            |
| build target    | `null`                                         |
| build command   | `make build target=null builder=null os=<os>`  |
| lint command    | `make lint template=null builder=null os=<os>` |

## Usage

To build the `null` image for the `os` operating system, run:

```shell
make build target=null builder=null os=<os>
```

## Notes

* The `null` template does not produce an Output Image, but it does render configuration information in the `$(DIR_DIST)` directory.
