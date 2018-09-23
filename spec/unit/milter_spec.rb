require 'spec_helper'

describe 'milter-test::default' do
  let(:platform) { { platform: nil, version: nil } }
  let(:services) { {} }
  let(:packages) { {} }
  let(:confdir) { nil }
  let(:repo_package) { nil }
  let(:milter_confdir) { nil }
  let(:user) { nil }
  let(:group) { nil }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      node.normal['clamav']['config']['MaxFileSize'] = '33M'
      node.normal['clamav']['rundir'] = '/test/run/clamav'
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  shared_examples_for 'any platform' do
    # {{{ install
    it 'installs the platform related packages' do
      expect(chef_run).to install_package(packages)
      expect(chef_run).to install_package(repo_package) if !repo_package.nil?
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

  shared_examples_for 'normal platform' do
    it 'creates configured directores' do
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
    it 'renders file freshclam.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{confdir}/freshclam.conf").with_content(%r{^PidFile +/test/run/clamav/test.pid})
    end
    it 'renders file clamav-milter.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{milter_confdir}/clamav-milter.conf").with_content(%r{^MilterSocket +/test/run/clamav/test-milter.ctl})
    end
  end

  shared_examples_for 'centos7 platform' do
    it 'creates configured directores' do
      expect(chef_run).to create_directory(milter_confdir).with(
        owner: 'clamilt',
        group: 'clamilt',
        mode: 0750
      )
    end
    it 'renders file scan.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{confdir}/scan.conf").with_content(%r{^LocalSocket +/test/run/clamav/test.ctl})
      expect(chef_run).to render_file("#{confdir}/scan.conf").with_content(/^MaxFileSize +33M/)
    end
    it 'renders file freshclam.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("/etc/freshclam.conf").with_content(%r{^PidFile +/test/run/clamav/test.pid})
    end
    it 'renders file clamav-milter.conf with LocalSocket set to /test/run/clamav/test.ctl' do
      expect(chef_run).to render_file("#{milter_confdir}/clamav-milter.conf").with_content(%r{^MilterSocket +/var/run/clamav-milter/test-milter.ctl})
    end
    it 'execute db update' do
      expect(chef_run).to run_execute('update-clamd-db')
    end
  end

  {
    Ubuntu: {
      platform: 'ubuntu',
      version: '16.04',
      packages: ['clamav', 'clamav-daemon', 'clamav-milter'],
      confdir: '/etc/clamav',
      milter_confdir: '/etc/clamav',
      user: 'clamav',
      group: 'clamav',
      services: ['clamav-daemon', 'clamav-freshclam', 'clamav-milter'],
      repo_package: nil,
    },
    CentOS6: {
      platform: 'centos',
      version: '6.9',
      packages: ['clamav', 'clamav-db', 'clamd', 'clamav-milter'],
      repo_package: 'epel-release',
      confdir: '/etc',
      milter_confdir: '/etc',
      user: 'clam',
      group: 'clam',
      services: ['clamd', 'clamav-milter'],
    },
    CentOS7: {
      platform: 'centos',
      version: '7.5.1804',
      packages: ['clamav', 'clamav-server', 'clamav-update', 'clamav-milter-systemd', 'clamav-milter'],
      repo_package: 'epel-release',
      confdir: '/etc/clamd.d',
      milter_confdir: '/etc/mail',
      user: nil,
      group: nil,
      services: ['clamd@scan', 'clamav-milter'],
    }
  }.each do |k, v|
    context "On #{k} #{v[:version]}" do
      let(:platform) { { platform: v[:platform], version: v[:version] } }
      let(:confdir) { v[:confdir] }
      let(:milter_confdir) { v[:milter_confdir] }
      let(:services) { v[:services] }
      let(:packages) { v[:packages] }
      let(:repo_package) { v[:repo_package] }
      let(:user) { v[:user] }
      let(:group) { v[:group] }

      it_behaves_like 'any platform'
      it_behaves_like 'normal platform' if k != :CentOS7
      it_behaves_like 'centos7 platform' if k == :CentOS7
    end
  end
end
