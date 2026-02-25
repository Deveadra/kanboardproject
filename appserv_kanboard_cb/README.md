# appserv_kanboard_cb

Chef cookbook for provisioning a Kanboard application server on Ubuntu 22.04.

## Supported platforms

- Ubuntu 22.04 (Debian family)

## What this cookbook does

The default recipe:

- Installs Apache, PHP-FPM, and required PHP modules.
- Downloads a pinned Kanboard release from GitHub.
- Extracts Kanboard to `/var/www/kanboard`.
- Configures an Apache virtual host for Kanboard.
- Enables and starts Apache + PHP-FPM services.

## Attributes

| Attribute | Default | Description |
|---|---|---|
| `node['appserv_kanboard_cb']['kanboard']['version']` | `v1.2.35` | Kanboard release version tag |
| `node['appserv_kanboard_cb']['kanboard']['release_url']` | Derived from version | Source URL for release zip |
| `node['appserv_kanboard_cb']['kanboard']['install_dir']` | `/var/www/kanboard` | Installation directory |
| `node['appserv_kanboard_cb']['apache']['server_name']` | `kanboard.local` | Apache `ServerName` |

## Usage

Add to your run list:

```ruby
run_list 'recipe[appserv_kanboard_cb::default]'
```

Override attributes as needed in an environment, role, or Policyfile attributes block.

## Verification

InSpec controls are provided under `test/integration/default`.

Example workflow:

```bash
kitchen converge
kitchen verify
```