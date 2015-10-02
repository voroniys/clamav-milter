default['clamav']['config']['clamd']['LocalSocket'] = "#{node['clamav']['rundir']}/test.ctl"
default['clamav']['config']['freshclam']['PidFile'] = "#{node['clamav']['rundir']}/test.pid"
default['clamav']['config']['milter']['MilterSocket'] = "#{node['clamav']['rundir']}/test-milter.ctl"
