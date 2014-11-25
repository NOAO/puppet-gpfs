require 'spec_helper'

describe 'mmgetstate', :type => :fact do
  before(:each) { Facter.clear }

  context 'not in path' do
    it do
      Facter::Util::Resolution.stubs(:which).with('mmgetstate').returns(nil)
      Facter.fact(:mmgetstate).value.should be_nil
    end
  end

  context 'in path' do
    it do
      Facter::Util::Resolution.stubs(:which).with('mmgetstate').returns('/usr/lpp/mmfs/bin/mmgetstate')
      Facter.fact(:mmgetstate).value.should == '/usr/lpp/mmfs/bin/mmgetstate'
    end
  end
end
