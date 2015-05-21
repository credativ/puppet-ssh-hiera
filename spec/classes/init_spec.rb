require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

describe 'ssh' do
  context "With standard facts" do
    let(:facts) { { :osfamily => 'Debian' } }
    it {
      should contain_package('openssh-server')
    }
  end

  context "With manage_users_allow" do
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) { {
      :manage_users_allow => true,
      :users => {
        "test1" => { },
        "test2" => { },
      },
    } }
    it {
      should contain_file('/etc/ssh/sshd_config')
        .with_content(%r{^AllowUsers test1 test2$})
    }
  end

  context "With manage_users_allow, without users" do
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) { {
      :manage_users_allow => true,
    } }
    it {
      expect {
        should contain_file('/etc/ssh/sshd_config')
      }.to raise_error(Puppet::Error, /Need users/)
    }
  end

  context "With manage_users_allow, with use_ldapuser" do
    let(:pre_condition) {
      <<-FIN
class { ldapuser::dataexport:
  data => {
    'passwd' => {
      'nobody' => {
      }
    }
  }
}
FIN
    }
    let(:facts) { { :osfamily => 'Debian' } }
    let(:params) { {
      :manage_users_allow => true,
      :use_ldapuser => true,
    } }
    it {
      should contain_file('/etc/ssh/sshd_config')
        .with_content(%r{^AllowUsers nobody$})
    }
  end
end
