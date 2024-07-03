#
# Cookbook:: appserv_kanboard_cb
# Recipe:: default
#

# Define variables
kanboard_url = 'https://github.com/kanboard/kanboard/archive/refs/heads/master.zip'
kanboard_archive = '/tmp/kanboard-latest.zip'
kanboard_dir = '/var/www/kanboard'
kanboard_unzipped_dir = '/var/www/kanboard-main'

# Update the package sources
apt_update 'update_sources' do
  action :update
end

# Install Apache and PHP
apt_package ['apache2', 'php'] do
  action :install
end

# Install Install additional PHP extensions required modules for downloading/handling/running Kanboard
apt_package %w[libapache2-mod-php php-cli php-mbstring php-sqlite3 php-opcache php-json php-mysql php-pgsql php-ldap php-gd php-xml unzip wget] do
  action :install
end

# Ensure the Apache service is enabled and running
service 'apache2' do
  action [:enable, :start]
  retries 5
end

# Enable the PHP module in Apache
execute 'enable_php_module' do
  command 'a2enmod php8.1'
  notifies :restart, 'service[apache2]', :immediately
end

=begin
%w[libapache2-mod-php php-cli php-mbstring php-sqlite3 php-opcache php-json php-mysql php-pgsql php-ldap php-gd php-xml unzip wget].each do |service_name|
  service service_name do
    action [:enable, :start]
    retries 5
  end
end
=end

# Download the Kanboard .zip from GitHub to temp folder. This should automatically detect the latest version!
#environmental variables?
remote_file kanboard_archive do
  source kanboard_url
  action :create
end

# Unzip the downloaded Kanboard file directly to www dir && rename it
execute 'unzip_kanboard' do
  command "unzip -o #{kanboard_archive} -d /var/www/"
  not_if { ::File.exist?(kanboard_dir) }
  notifies :run, 'execute[change_kanboard_ownership]', :immediately
end

execute 'move_kanboard' do
  command "mv #{kanboard_unzipped_dir} #{kanboard_dir}"
  not_if { ::File.exist?(kanboard_dir) }
  only_if { ::File.exist?(kanboard_unzipped_dir) }
  notifies :run, 'execute[change_kanboard_ownership]', :immediately
end

# Change ownership of the Kanboard directory
execute 'change_kanboard_ownership' do
  command "chown -R www-data:www-data #{kanboard_dir}"
  action :nothing
end

=begin
# Change ownership of the Kanboard directory
directory kanboard_dir do
  owner 'www-data'
  group 'www-data'
  recursive true
  action :create
end
=end

require_relative '../libraries/path_helper'

# Allow 'Apache Full' through the firewall
execute 'allow-apache-full' do
  command 'ufw allow "Apache Full"'
  not_if 'ufw status | grep -q "Apache Full"'
end

=begin
# Install InSpec
package 'inspec' do
  action :install
end
=end

execute 'install_inspec' do
  command 'curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P inspec'
  not_if 'which inspec'
end

# Configure Apache to reach Kanboard
template '/etc/apache2/sites-available/kanboard.conf' do
  source 'kanboard.conf.erb'
  notifies :run, 'execute[enable_kanboard_site]', :immediately
  notifies :run, 'execute[disable_default_site]', :immediately
  notifies :restart, 'service[apache2]', :immediately
end

# Enable the Kanboard site configuration in Apache
execute 'enable_kanboard_site' do
  command 'a2ensite kanboard.conf'
  action :nothing
  notifies :restart, 'service[apache2]', :immediately
end

# Disable the default Apache site configuration
execute 'disable_default_site' do
  command 'a2dissite 000-default.conf'
  action :nothing
  notifies :restart, 'service[apache2]', :immediately
end

# Ensure Apache is enabled and active
service 'apache2' do
  action [:enable, :start]
end
