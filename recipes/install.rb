# Encoding: UTF-8
#
# Cookbook Name:: clamav-milter
# Recipe:: install
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
case node['platform_family']
when 'rhel'
  package 'epel-release'
  packages =
    if node['platform_version'].to_i >= 7
      %w(clamav clamav-server clamav-update clamav-milter-systemd clamav-milter)
    else
      %w(clamav clamav-db clamd clamav-milter)
    end
when 'debian'
  packages = %w(clamav clamav-daemon clamav-milter)
else
  raise(Chef::Exceptions::UnsupportedAction,
       "Platform #{node['platform_family']} not supported")
end

package packages

if node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7
  execute 'update-clamd-db' do
    command '/usr/bin/freshclam'
    not_if { ::File.exist?("#{node['clamav']['config']['clamd']['DatabaseDirectory']}/main.cvd") }
    action :run
  end
end
