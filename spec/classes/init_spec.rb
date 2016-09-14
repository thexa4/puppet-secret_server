require 'spec_helper'
describe 'secrets_server' do
  context 'with default values for all parameters' do
    it { should contain_class('secrets_server') }
  end
end
