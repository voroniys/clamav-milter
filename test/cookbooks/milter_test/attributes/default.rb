default['clamav']['config']['clamd']['LocalSocket'] = "#{node['clamav']['rundir']}/test.ctl"
default['clamav']['config']['milter']['ClamdSocket'] = "#{node['clamav']['rundir']}/test.ctl"
default['clamav']['config']['freshclam']['PidFile'] = "#{node['clamav']['rundir']}/test.pid"
default['clamav']['config']['milter']['MilterSocket'] = node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7 ? '/var/run/clamav-milter/test-milter.ctl' : "#{node['clamav']['rundir']}/test-milter.ctl"
