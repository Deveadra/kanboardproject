=begin
# This is an example test, replace it with your own test.
describe port(80), :skip do
  it { should_not be_listening }
end
=end

describe service('apache2') do
  it { should be_installed}
  it { should be_enabled }
  it { should be_running }
end

describe service('php') do
  it { should be_installed}
  it { should be_enabled }
  it { should be_running }
end


# test/integration/default/kanboard_spec.rb
describe http('http://localhost') do
  its('status') { should cmp 200 }
  its('body') { should match /Kanboard/ }
end

describe file('/var/www/kanboard/data') do
  it {should exist}
  it {should be_directory}
  its('owner') { should eq 'www-data'}
  its('group') {should eq 'www-data'}
end

