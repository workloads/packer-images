# Image `${image.name}`

| Image Information |                      |
|-------------------|----------------------|
| build version     | `${image.version}`   |
| build timestamp   | `${image.timestamp}` |
| source image      | `${source.image}`    |
%{~ if image.developer_mode }
| Developer Mode    | ⚠️ enabled                       |
%{~ endif}

## Table of Contents

%{ if can(shared.tools.docker) }- [Docker Packages](#docker-packages)%{ endif }
%{ if can(shared.tools.hashicorp) }- [HashiCorp Packages](#hashicorp-packages)%{ endif }
%{ if can(shared.nomad_plugins.plugins) }- [HashiCorp Nomad Plugins](#hashicorp-nomad-plugins)%{ endif }
%{ if can(shared.tools.osquery) }- [osquery Packages](#osquery-packages)%{ endif }

%{ if can(shared.tools.docker) ~}
## Docker Packages

%{~ for item in shared.tools.docker.packages.to_install }
- `${item.name}`, version `${item.version}`
%{~ endfor ~}
%{ endif }

%{ if can(shared.tools.hashicorp) ~}
## HashiCorp Packages

%{~ for item in shared.tools.hashicorp.packages.to_install }
- `${item.name}`, version `${item.version}`
%{~ endfor ~}
%{ endif }

%{ if can(shared.nomad_plugins.plugins) ~}
## HashiCorp Nomad Plugins

%{~ for name, config in shared.nomad_plugins.plugins }
- `${name}`, version `${config.version}` (%{ if config.official }HashiCorp-maintained %{~ else ~}community-supported, [source](${config.url})%{ endif ~})
%{~ endfor ~}
%{ endif }

%{ if can(shared.tools.osquery) ~}
## osquery Packages

%{~ for item in shared.tools.osquery.packages.to_install }
- `${item.name}`, version `${item.version}`
%{~ endfor ~}
%{ endif }
