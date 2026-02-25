# InSpec integration tests for appserv_kanboard_cb::default

describe package('apache2') do
  it { should be_installed }
end

describe package('php-fpm') do
  it { should be_installed }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

describe service('php8.1-fpm') do
  it { should be_enabled }
  it { should be_running }
end

describe port(80) do
  it { should be_listening }
end

describe file('/etc/apache2/sites-available/kanboard.conf') do
  it { should exist }
  its('content') { should match %r{DocumentRoot /var/www/kanboard} }
end

describe file('/var/www/kanboard/index.php') do
  it { should exist }
end