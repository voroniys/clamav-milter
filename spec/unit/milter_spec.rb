require 'spec_helper'

describe 'milter-test::default' do
  let(:platform) { { platform: nil, version: nil } }
  let(:services) { {} }
  let(:packages) { {} }
  let(:confdir) { nil }
  let(:milter_confdir) { nil }
  let(:user) { nil }
  let(:group) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      node.set['clamav']['config']['MaxFileSize'] = '33M'
      node.set['clamav']['rundir'] = '/test/run/clamav'
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    # {{{ install
    it 'installs the platform related packages' do
      packages.each do |p|
        expect(chef_run).to install_package(p)
      end
    end
    # }}}

    # {{{ config
    it 'creates configured directores' do
      expect(chef_run).to create_directory('/test/run/clamav').with(
        owner: user,
        group: group,
        mode: 0750
      )
      expect(chef_run).to create_directory(confdir).with(
        owner: user,
        group: group,
        mode: 0750
      ) if confdir != '/etc'
      expect(chef_run).to create_directory(milter_confdir).with(
        owner: user,
        group: group,
        mode: 0750
      ) if confdir != '/etc'
    end
    it 'renders file clamd.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{confdir}/clamd.conf").with_content(%r{^LocalSocket +/test/run/clamav/test.ctl})
      expect(chef_run).to render_file("#{confdir}/clamd.conf").with_content(/^MaxFileSize +33M/)
    end
    it 'renders file clamav-milter.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{milter_confdir}/clamav-milter.conf").with_content(%r{^MilterSocket +/test/run/clamav/test-milter.ctl})
    end
    # }}}

    # {{{ service
    it 'enables and starts services' do
      services.each do |service|
        expect(chef_run).to start_service(service)
        expect(chef_run).to enable_service(service)
      end
    end
    # }}}
  end

  shared_examples_for 'platform with freshclam' do
    it 'renders file freshclam.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{confdir}/freshclam.conf").with_content(%r{^PidFile +/test/run/clamav/test.pid})
    end
  end

  shared_examples_for 'platform with systemd' do
    it 'renders file clamd.service' do
      expect(chef_run).to render_file('/usr/lib/systemd/system/clamd.service')
    end
    it 'execute systemctl' do
      expect(chef_run).to_not run_execute('update-clamd-service')
    end
  end

  {
    Ubuntu: {
      platform: 'ubuntu',
      version: '14.04',
      packages: ['clamav', 'clamav-daemon', 'clamav-milter'],
      confdir: '/etc/clamav',
      milter_confdir: '/etc/clamav',
      user: 'clamav',
      group: 'clamav',
      services: ['clamav-daemon', 'clamav-freshclam', 'clamav-milter']
    },
    CentOS6: {
      platform: 'centos',
      version: '6.5',
      packages: ['epel-release', 'clamav', 'clamav-db', 'clamd', 'clamav-milter'],
      confdir: '/etc',
      milter_confdir: '/etc',
      user: 'clam',
      group: 'clam',
      services: ['clamd', 'clamav-milter']
    },
    CentOS7: {
      platform: 'centos',
      version: '7.0',
      packages: ['epel-release', 'clamav', 'clamav-server', 'clamav-update', 'clamav-milter', 'clamav-milter-systemd'],
      confdir: '/etc/clamd.d',
      milter_confdir: '/etc/mail',
      user: nil,
      group: nil,
      services: ['clamd', 'clamav-milter']
    }
  }.each do |k, v|
    context "On #{k} #{v[:version]}" do
      let(:platform) { { platform: v[:platform], version: v[:version] } }
      let(:confdir) { v[:confdir] }
      let(:milter_confdir) { v[:milter_confdir] }
      let(:services) { v[:services] }
      let(:packages) { v[:packages] }
      let(:user) { v[:user] }
      let(:group) { v[:group] }

      it_behaves_like 'any platform'
      it_behaves_like 'platform with freshclam' if k == :Ubuntu
      it_behaves_like 'platform with systemd' if k == :CentOS7
    end
  end
end
