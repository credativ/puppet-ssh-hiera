require 'spec_helper'

describe 'ssh_keygen' do
    describe 'requires arguments' do
        it { should run.with_params().and_raise_error("/request argument required/") }
    end
end
