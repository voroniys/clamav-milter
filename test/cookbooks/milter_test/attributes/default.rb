default['clamav']['config']['clamd']['LocalSocket'] = "#{node['clamav']['rundir']}/test.ctl"
default['clamav']['config']['milter']['ClamdSocket'] = "#{node['clamav']['rundir']}/test.ctl"
default['clamav']['config']['freshclam']['PidFile'] = "#{node['clamav']['rundir']}/test.pid"
if node['platform_family'] == 'rhel' && node['platform_version'].to_i >= 7
  default['clamav']['config']['milter']['MilterSocket'] = "/var/run/clamav-milter/test-milter.ctl"
else
  default['clamav']['config']['milter']['MilterSocket'] = "#{node['clamav']['rundir']}/test-milter.ctl" 
end
