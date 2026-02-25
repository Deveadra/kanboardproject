# Kanboard Project

Infrastructure-as-Code repository for provisioning a **Kanboard application server** with Chef.

This project is intentionally small and focused: it provides a production-style Chef cookbook (`appserv_kanboard_cb`) that installs and configures a runnable Kanboard stack on Ubuntu 22.04.

## Repository structure

- `appserv_kanboard_cb/` — Chef cookbook to install and configure Kanboard.
  - `recipes/default.rb` — end-to-end server setup.
  - `attributes/default.rb` — configurable defaults.
  - `templates/default/kanboard.conf.erb` — Apache virtual host.
  - `test/integration/default/default_test.rb` — verification controls.

## Quick start

### Prerequisites

- Chef Workstation (or Cinc Workstation).
- Test Kitchen with an AWS account/profile (as configured in `kitchen.yml`).

### Run locally (lint/sanity)

From the cookbook directory:

```bash
cd appserv_kanboard_cb
ruby -c recipes/default.rb
ruby -c attributes/default.rb
```

### Converge and verify with Test Kitchen

```bash
cd appserv_kanboard_cb
kitchen converge
kitchen verify
kitchen destroy
```

## What the cookbook configures

The default recipe currently:

1. Installs Apache, PHP-FPM, and required PHP extensions.
2. Downloads a pinned Kanboard release archive.
3. Extracts Kanboard into `/var/www/kanboard`.
4. Creates an Apache virtual host and enables required modules.
5. Starts/enables services (`apache2`, `php8.1-fpm`).


## Recommended project layout

Your sample tree shows **mixed structures** (root-level cookbook files *and* nested cookbook paths like `appserv_kanboard_cb/templates`). Pick one convention and keep it consistent.

For this repository, the clean approach is:

- Keep the repository root as a project wrapper (`README`, CI, docs).
- Keep exactly one cookbook root at `appserv_kanboard_cb/`.
- Keep tests only under `appserv_kanboard_cb/test/integration/default/` (avoid duplicate `default/default_test.rb` paths outside `test/integration`).

That prevents drift, duplicate files, and confusing Chef tooling behavior.

## Roadmap

- Add ChefSpec unit tests for recipe behavior.
- Parameterize database backend options (SQLite/MySQL/PostgreSQL).
- Add CI pipeline for cookbook lint + kitchen verify.