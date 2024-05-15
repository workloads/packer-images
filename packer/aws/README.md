# Amazon Web Services

## Table of Contents

<!-- TOC -->
* [Amazon Web Services](#amazon-web-services)
  * [Table of Contents](#table-of-contents)
  * [Requirements](#requirements)
  * [Overview](#overview)
    * [Overrides](#overrides)
  * [Authentication](#authentication)
  * [Images](#images)
  * [Notes](#notes)
    * [Image Tagging](#image-tagging)
<!-- TOC -->

## Requirements

- `aws` (AWS CLI) `2.15.00` or newer

## Overview

|                 |                                          |
|-----------------|------------------------------------------|
| image template  | [template.pkr.hcl](./template.pkr.hcl)   |
| image variables | [variables.pkr.hcl](./variables.pkr.hcl) |
| build target    | `aws`                                    |
| build command   | `make build target=aws`                  |
| lint command    | `make lint target=aws`                   |

> `make` commands must be run from the root directory.

## Authentication

not yet available

## Images

```shell
make build target=aws
```

️> `make` commands must be run from the root directory.

## Notes

This section contains notes that are relevant if you intend to customize the workflows of this repository.

### Image Tagging

We have chosen to follow AWS-recommended [best-practices](https://docs.aws.amazon.com/whitepapers/latest/tagging-best-practices/adopt-a-standardized-approach-for-tag-names.html) for tagging the resulting image(s).
