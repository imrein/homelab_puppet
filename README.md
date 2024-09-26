# Homelab puppet repo

<p align="center">
<img src="https://www.puppet.com/sites/default/themes/custom/puppet/logo.svg" width=250>
</p>

<div align="center">
A collection of all the puppet profiles I use in my homelab.
</div>

## Overview

Status: **WIP**

My puppetserver is installed using an [ansible role](https://github.com/geerlingguy/ansible-role-puppet) which I tweaked a bit for my personal needs. The setup is created with CI/CD integration in mind and utilizes 2 repositories (this one + hieradata) to keep all the code up-to-date on the puppetserver. These will automatically push changes in config and manifests to the right location on the puppetserver using [Jenkins](https://www.jenkins.io/) pipelines.

> [!NOTE]
> I created all of the profiles from the ground up to learn more about puppet. These profiles are not perfect and might still have flaws and bad-practises.

### Profiles

- [x] Base
- [x] Docker
- [x] Gitea
- [x] Grafana
- [x] Jenkins
- [x] Minecraft
- [x] Prometheus
- [x] Hashicorp Vault

### Folder setup

File locations:

| Description                | Location                                                         |
| -------------------------- | ---------------------------------------------------------------- |
| Puppet manifests           | `/etc/puppetlabs/code/environments/production/modules/`          |
| Node specific hieradata    | `/etc/puppetlabs/code/environments/production/data/nodes/`       |
| OS specific hieradata      | `/etc/puppetlabs/code/environments/production/data/os/`          |
| Common hieradata           | `/etc/puppetlabs/code/environments/production/data/common.yaml`  |
| Role definitions for nodes | `/etc/puppetlabs/code/environments/production/manifests/site.pp` |

### Modules

I installed some extra modules to make my life easier:

```bash
/etc/puppetlabs/code/modules
├── puppet-archive
├── puppet-systemd
├── puppet-vault_lookup
├── puppetlabs-apt
├── puppetlabs-concat
├── puppetlabs-inifile
├── puppetlabs-mysql
├── puppetlabs-stdlib
├── saz-ssh
├── saz-timezone
└── stm-debconf
```


## Vault integration

To remove the secrets from my code, I use [Vault](https://www.hashicorp.com/products/vault) which can house these safely. By using an extra [puppet module](https://github.com/voxpupuli/puppet-vault_lookup) to lookup the secrets in the vault, I can make my workflow more secure and separate the secrets from the repos.

### Practical

To grab one of the secrets that are stored in `Vault`, I can use a `Deferred` function to lookup a secret:
```puppet
$jwt_secret = Deferred('vault_lookup::lookup', ['homelab-vm/data/gitea', { field => 'jwt_secret' }]),
```

This will populate the `jwt_secret` parameter in this case with a value of type `Sensitive`.