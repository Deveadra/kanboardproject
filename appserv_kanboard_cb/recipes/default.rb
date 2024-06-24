#
# Cookbook:: appserv_kanboard_cb
# Recipe:: default
#

# Update the package sources
apt_update 'update_sources' do
  action :update
end

# Install Apache
package 'apache2' do
  action :install
end

# Install PHP
package 'php' do
  action :install
end

# Install additional PHP packages
package ['libapache2-mod-php', 'php-cli', 'php-mbstring', 'php-sqlite3', 'php-opcache', 'php-json', 'php-mysql', 'php-pgsql', 'php-ldap', 'php-gd', 'php-xml'] do
  action :install
end

# Ensure Apache service is started and enabled
service 'apache2' do
  action [:start, :enable]
  retries 5
end

# Restart Apache service to apply changes
service 'apache2' do
  action :restart
end
