require 'spec_helper'

describe 'ssh_keygen' do
    describe 'requires arguments' do
        it do
            expect { is_expected.to raise_error(Puppet::ParseError) }
        end
    end
end
