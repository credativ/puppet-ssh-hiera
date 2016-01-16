source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['~> 3.7.2']
gem 'rake'
gem 'puppet', puppetversion
gem 'puppetlabs_spec_helper', '>= 0.8.2'
# newer versions have a bug that cause ignore patterns not to work
# http://stackoverflow.com/questions/27138893/puppet-lint-ignoring-the-ignore-paths-option
gem 'puppet-lint', '~> 1.0.1'
gem 'metadata-json-lint'
gem 'facter', '~> 1.6.10'
gem 'hiera', '~> 1.3.4'
gem 'beaker-rspec'
gem 'beaker-hiera'
