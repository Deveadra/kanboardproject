#
# Cookbook:: appserv_kanboard_cb
# Recipe:: default
#

# Update the package sources
apt_update 'update_sources' do
  action :update
end

# Install Apache and PHP
package ['apache2', 'php'] do
  action :install
end

# Install additional PHP extensions required modules for downloading/handling/running Kanboard
#package %w['libapache2-mod-php', 'php-cli', 'php-mbstring', 'php-sqlite3', 'php-opcache', 'php-json', 'php-mysql', 'php-pgsql', 'php-ldap', 'php-gd', 'php-xml', 'unzip', 'wget'] do
package %w[libapache2-mod-php php-cli php-mbstring php-sqlite3 php-opcache php-json php-mysql php-pgsql php-ldap php-gd php-xml unzip wget] do
  action :install
end

# Ensure the Apache web service has started and is enabled
service 'apache2' do
  action [:enable, :start]
  retries 5
end

# Download the Kanboard .zip from GitHub to temp folder. This should automatically detect the latest version!
# Possibly create an environemtal variable that can be updated with the link
remote_file '/tmp/kanboard-latest.zip' do
  source 'https://github.com/kanboard/kanboard/archive/master.zip'
  action :create
end

# Unzip the downloaded Kanboard file directly to www dir && rename it

execute 'unzip_kanboard' do
  command 'unzip /tmp/kanboard-latest.zip -d /var/www/ && mv /var/www/kanboard-master /var/www/kanboard'
  not_if { ::File.exist?('/var/www/kanboard') }
end

=begin
execute 'unzip_kanboard' do
  command 'unzip /tmp/kanboard-latest.zip -d /var/www/'
  not_if { ::File.exist?('/var/www/kanboard-master') }
end

execute 'move_kanboard' do
  command 'mv /var/www/kanboard-mainmaster /var/www/kanboard'
  not_if { ::File.exist?('/var/www/kanboard') }
end
=end

# Change ownership of the Kan dir. www-data is what Apache runs. (Allows Apache to read and write to Kanboard)
#Should sudo be used here? How would the password auth work?
execute 'set_permissions' do
  command 'chown -R www-data:www-data /var/www/kanboard'
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
end

# Disable the default Apache site configuration
execute 'disable_default_site' do
  command 'a2dissite 000-default.conf'
  action :nothing
end

# Check Apache status, restart if necessary

=begin
service 'apache2' do
  action [:restart]
  not_if [ ::service.running?('apache2') ]
=end

bash 'check_apache_running' do
  code <<-EOH
    if ! systemctl is-active --quiet apache2; then
      systemctl restart apache2
    fi
  EOH
  action :run
end

# Ensure Apache is enabled and active
service 'apache2' do
  action [:enable, :start]
end