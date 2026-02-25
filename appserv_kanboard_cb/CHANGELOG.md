# appserv_kanboard_cb CHANGELOG

## 0.2.1

- Improved Apache module and site enablement to be idempotent and easier to reason about.
- Added explicit `data` directory ownership/permissions for Kanboard runtime writes.
- Removed placeholder metadata URLs to avoid publishing inaccurate project links.

## 0.2.0

- Replaced scaffold cookbook content with a production-style default recipe.
- Added attributes for release version, release URL, install path, and Apache server name.
- Added Apache virtual host template for Kanboard + PHP-FPM integration.
- Replaced placeholder README with complete usage and attribute documentation.
- Replaced skipped InSpec examples with functional deployment verification controls.

## 0.1.0

- Initial release.