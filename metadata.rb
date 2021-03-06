name 'clamav-milter'
maintainer 'Stanislav Voroniy'
maintainer_email 'stas@voroniy.com'
license 'Apache-2.0'
description 'Installs/Configures clamav-milter'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.4.0'
chef_version '>= 12.1' if respond_to?(:chef_version)
issues_url 'https://github.com/voroniys/clamav-milter/issues' if respond_to?(:source_url)
source_url 'https://github.com/voroniys/clamav-milter' if respond_to?(:issues_url)

supports 'ubuntu'
supports 'debian'
supports 'redhat', '>= 6.0'
supports 'centos', '>= 6.0'
