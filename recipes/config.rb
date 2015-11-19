# Encoding: UTF-8
#
# Cookbook Name:: clamav-milter
# Recipe:: config
#
# Copyright 2015, Stanislav Voroniy
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
confdir = node['clamav']['confdir']
if node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7
  milter_confdir = '/etc/mail'
  directory milter_confdir do
    mode 00750
  end
else
  milter_confdir = confdir
end
# ensure directories, but do not tuch /etc (CentOS6)
[confdir, node['clamav']['rundir']].each do |dir|
  directory dir do
    owner node['clamav']['user']
    group node['clamav']['group']
    mode 00750
  end if dir != '/etc'
end

template "#{confdir}/clamd.conf" do
  owner node['clamav']['user']
  group node['clamav']['group']
  source 'conf.erb'
  mode '0644'
  action :create
  variables(
    config: node['clamav']['config']['clamd']
  )
  notifies :restart, "service[#{node['clamav']['service']['clamd']}]"
end

template "#{confdir}/freshclam.conf" do
  owner node['clamav']['user']
  group node['clamav']['group']
  source 'conf.erb'
  mode '0644'
  action :create
  variables(
    config: node['clamav']['config']['freshclam']
  )
  notifies :restart, "service[#{node['clamav']['service']['freshclam']}]"
end if node['platform_family'] == 'debian'

template "#{milter_confdir}/clamav-milter.conf" do
  owner node['clamav']['user']
  group node['clamav']['group']
  source 'conf.erb'
  mode '0644'
  action :create
  variables(
    config: node['clamav']['config']['milter']
  )
  notifies :restart, "service[#{node['clamav']['service']['milter']}]"
end
