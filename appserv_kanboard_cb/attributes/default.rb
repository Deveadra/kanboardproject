default['appserv_kanboard_cb']['kanboard']['version'] = 'v1.2.35'
default['appserv_kanboard_cb']['kanboard']['release_url'] =
  "https://github.com/kanboard/kanboard/releases/download/#{node['appserv_kanboard_cb']['kanboard']['version']}/kanboard-#{node['appserv_kanboard_cb']['kanboard']['version']}.zip"
default['appserv_kanboard_cb']['kanboard']['install_dir'] = '/var/www/kanboard'
default['appserv_kanboard_cb']['apache']['server_name'] = 'kanboard.local'