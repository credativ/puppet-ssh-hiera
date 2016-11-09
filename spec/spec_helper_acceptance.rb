require 'beaker-rspec'
require 'beaker-hiera'

def module_root
  File.expand_path(File.join(File.dirname(__FILE__), '..'))
end

##
# taken from puppetlabs/postgresql
def psql(psql_cmd, user = 'postgres', exit_codes = [0,1], &block)
  psql = "psql #{psql_cmd}"
  shell("su #{shellescape(user)} -c #{shellescape(psql)}", :acceptable_exit_codes => exit_codes, &block)
end

def shellescape(str)
  str = str.to_s

  # An empty argument will be skipped, so return empty quotes.
  return "''" if str.empty?

  str = str.dup

  # Treat multibyte characters as is.  It is caller's responsibility
  # to encode the string in the right encoding for the shell
  # environment.
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/, "\\\\\\1")

  # A LF cannot be escaped with a backslash because a backslash + LF
  # combo is regarded as line continuation and simply ignored.
  str.gsub!(/\n/, "'\n'")

  return str
end
##

hosts.each do |host|
  # Install Puppet
  on host, install_puppet
end

RSpec.configure do |c|
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module
    puppet_module_install(:source => module_root, :module_name => 'bayesdb')
  end

  copy_modules_to(hosts, {
    :source_dir   => 'spec/fixtures/modules',
    :module_names => ['apt', 'concat', 'dnsquery', 'example42lib', 'pacemaker', 'postgresql', 'stdlib', 'vim', 'ssh']


  })
end
