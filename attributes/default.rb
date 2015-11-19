# Encoding: UTF-8
#
# Cookbook Name:: clamav-milter
# Attributes:: default
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
  default['clamav']['service']['clamd'] = 'clamd'
  default['clamav']['service']['milter'] = 'clamav-milter'
  if node['platform_version'].to_i >= 7
    default['clamav']['confdir'] = '/etc/clamd.d'
  else
    default['clamav']['confdir'] = '/etc'
    default['clamav']['user'] = 'clam'
    default['clamav']['group'] = 'clam'
  end
when 'debian'
  default['clamav']['service']['clamd'] = 'clamav-daemon'
  default['clamav']['service']['freshclam'] = 'clamav-freshclam'
  default['clamav']['service']['milter'] = 'clamav-milter'
  default['clamav']['confdir'] = '/etc/clamav'
  default['clamav']['user'] = 'clamav'
  default['clamav']['group'] = 'clamav'
end
# General settings
default['clamav']['rundir'] = '/var/run/clamav'
default['clamav']['config']['MaxFileSize'] = '25M'

# clamav-daemon default minimal configuration
default['clamav']['config']['clamd']['LocalSocket'] = "#{node['clamav']['rundir']}/clamd.ctl"
default['clamav']['config']['clamd']['LocalSocketGroup'] = node['clamav']['group']
default['clamav']['config']['clamd']['User'] = node['clamav']['user']
default['clamav']['config']['clamd']['FixStaleSocket'] = 'true'
default['clamav']['config']['clamd']['LocalSocketMode'] = '666'
default['clamav']['config']['clamd']['AllowSupplementaryGroups'] = 'false'
default['clamav']['config']['clamd']['ReadTimeout'] = 180
default['clamav']['config']['clamd']['MaxThreads'] = 10
default['clamav']['config']['clamd']['MaxConnectionQueueLength'] = 50
default['clamav']['config']['clamd']['LogSyslog'] = 'true'
default['clamav']['config']['clamd']['PidFile'] = "#{node['clamav']['rundir']}/clamd.pid"
default['clamav']['config']['clamd']['DatabaseDirectory'] = '/var/lib/clamav'
default['clamav']['config']['clamd']['OfficialDatabaseOnly'] = 'false'
default['clamav']['config']['clamd']['SelfCheck'] = 3600
default['clamav']['config']['clamd']['Foreground'] = 'false'
default['clamav']['config']['clamd']['ExitOnOOM'] = 'false'
default['clamav']['config']['clamd']['DetectPUA'] = 'true'
default['clamav']['config']['clamd']['MaxScanSize'] = '100M'
default['clamav']['config']['clamd']['MaxFileSize'] = node['clamav']['config']['MaxFileSize']
default['clamav']['config']['clamd']['MaxRecursion'] = 10
default['clamav']['config']['clamd']['MaxFiles'] = 10_000
default['clamav']['config']['clamd']['MaxPartitions'] = 50
default['clamav']['config']['clamd']['MaxIconsPE'] = 100

default['clamav']['config']['freshclam']['DatabaseOwner'] = node['clamav']['user']
default['clamav']['config']['freshclam']['LogSyslog'] = 'true'
default['clamav']['config']['freshclam']['Foreground'] = 'false'
default['clamav']['config']['freshclam']['MaxAttempts'] = 5
default['clamav']['config']['freshclam']['DatabaseDirectory'] = node['clamav']['config']['clamd']['DatabaseDirectory']
default['clamav']['config']['freshclam']['AllowSupplementaryGroups'] = 'false'
default['clamav']['config']['freshclam']['PidFile'] = "#{node['clamav']['rundir']}/freshclam.pid"
default['clamav']['config']['freshclam']['ConnectTimeout'] = 30
default['clamav']['config']['freshclam']['ReceiveTimeout'] = 60
default['clamav']['config']['freshclam']['NotifyClamd'] = "#{node['clamav']['confdir']}/clamd.conf"
default['clamav']['config']['freshclam']['Checks'] = 8
default['clamav']['config']['freshclam']['DatabaseMirror'] = ['db.local.clamav.net', 'database.clamav.net']

default['clamav']['config']['milter']['MilterSocket'] = "#{node['clamav']['rundir']}clamav-milter.ctl"
default['clamav']['config']['milter']['FixStaleSocket'] = 'true'
default['clamav']['config']['milter']['User'] = node['clamav']['user']
default['clamav']['config']['milter']['MilterSocketGroup'] = node['clamav']['group']
default['clamav']['config']['milter']['MilterSocketMode'] = '666'
default['clamav']['config']['milter']['AllowSupplementaryGroups'] = 'true'
default['clamav']['config']['milter']['ReadTimeout'] = 120
default['clamav']['config']['milter']['Foreground'] = 'false'
default['clamav']['config']['milter']['PidFile'] = "#{node['clamav']['rundir']}/clamav-milter.pid"
default['clamav']['config']['milter']['ClamdSocket'] = "unix:#{node['clamav']['config']['clamd']['LocalSocket']}"
default['clamav']['config']['milter']['LogSyslog'] = 'true'
default['clamav']['config']['milter']['MaxFileSize'] = node['clamav']['config']['MaxFileSize']
default['clamav']['config']['milter']['SupportMultipleRecipients'] = 'false'
default['clamav']['config']['milter']['TemporaryDirectory'] = '/tmp'
