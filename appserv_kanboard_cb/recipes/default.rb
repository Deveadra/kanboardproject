#
# Cookbook:: appserv_kanboard_cb
# Recipe:: default
#
# Copyright:: 2024, The Authors, All Rights Reserved.

raise 'This cookbook currently supports Debian-family systems only.' unless platform_family?('debian')

apt_update 'update' do
  action :update
end

package %w(
  apache2
  libapache2-mod-fcgid
  php
  php-cli
  php-fpm
  php-gd
  php-xml
  php-mbstring
  php-sqlite3
  unzip
  curl
)

install_dir = node['appserv_kanboard_cb']['kanboard']['install_dir']
release_url = node['appserv_kanboard_cb']['kanboard']['release_url']
version = node['appserv_kanboard_cb']['kanboard']['version']
archive_path = "/tmp/kanboard-#{version}.zip"

remote_file archive_path do
  source release_url
  mode '0644'
  action :create
end

directory install_dir do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  recursive true
end

archive_file archive_path do
  destination install_dir
  overwrite true
  strip_components 1
  action :extract
  notifies :run, 'execute[set-kanboard-permissions]', :immediately
end

execute 'set-kanboard-permissions' do
  command "chown -R www-data:www-data #{install_dir}"
  action :nothing
end

template '/etc/apache2/sites-available/kanboard.conf' do
  source 'kanboard.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    install_dir: install_dir,
    server_name: node['appserv_kanboard_cb']['apache']['server_name']
  )
  notifies :run, 'execute[enable-kanboard-site]', :immediately
end

execute 'enable-apache-modules' do
  command 'a2enmod rewrite headers proxy_fcgi setenvif expires'
  not_if 'apache2ctl -M | grep -E "rewrite_module|headers_module|proxy_fcgi_module|setenvif_module|expires_module" >/dev/null'
  notifies :restart, 'service[apache2]', :delayed
end

execute 'enable-kanboard-site' do
  command 'a2ensite kanboard && a2dissite 000-default'
  action :nothing
  notifies :restart, 'service[apache2]', :delayed
end

service 'php8.1-fpm' do
  action %i(enable start)
end

service 'apache2' do
  action %i(enable start)
end