require 'spec_helper'

describe 'gpfs_state', :type => :fact do
  before(:each) { Facter.clear }

  context 'mmgetstate fact not set' do
    it 'should return nil' do
      Facter.fact(:mmgetstate).stubs(:value).returns(nil)
      Facter.fact(:gpfs_state).value.should be_nil
    end
  end

  context 'mmgetstate fact is broken' do
    it 'should return nil' do
      Facter.fact(:mmgetstate).stubs(:value).returns('foobar')
        Facter::Core::Execution.stubs(:execute).
          with('foobar 2>&1')
      Facter.fact(:gpfs_state).value.should be_nil
    end
  end

  context 'mmgetstate fact is working' do
    context 'gpfs is not configured' do
      it 'should return nil' do
        Facter.fact(:mmgetstate).stubs(:value).
          returns('/usr/lpp/mmfs/bin/mmgetstate')
        Facter::Core::Execution.stubs(:execute).
          with('/usr/lpp/mmfs/bin/mmgetstate 2>&1').
          returns(File.read(fixtures('mmgetstate', 'unconfigured')))

        Facter.fact(:gpfs_state).value.should be_nil
      end
    end

    context 'gpfs state is active' do
      it 'should return the state' do
        Facter.fact(:mmgetstate).stubs(:value).
          returns('/usr/lpp/mmfs/bin/mmgetstate')
        Facter::Core::Execution.stubs(:execute).
          with('/usr/lpp/mmfs/bin/mmgetstate 2>&1').
          returns(File.read(fixtures('mmgetstate', 'active')))

        Facter.fact(:gpfs_state).value.should == 'active'
      end
    end

    context 'gpfs state is arbitrating' do
      it 'should return the state' do
        Facter.fact(:mmgetstate).stubs(:value).
          returns('/usr/lpp/mmfs/bin/mmgetstate')
        Facter::Core::Execution.stubs(:execute).
          with('/usr/lpp/mmfs/bin/mmgetstate 2>&1').
          returns(File.read(fixtures('mmgetstate', 'arbitrating')))

        Facter.fact(:gpfs_state).value.should == 'arbitrating'
      end
    end

    context 'gpfs state is down' do
      it 'should return the state' do
        Facter.fact(:mmgetstate).stubs(:value).
          returns('/usr/lpp/mmfs/bin/mmgetstate')
        Facter::Core::Execution.stubs(:execute).
          with('/usr/lpp/mmfs/bin/mmgetstate 2>&1').
          returns(File.read(fixtures('mmgetstate', 'down')))

        Facter.fact(:gpfs_state).value.should == 'down'
      end
    end

    context 'gpfs state is unknown' do
      it 'should return the state' do
        Facter.fact(:mmgetstate).stubs(:value).
          returns('/usr/lpp/mmfs/bin/mmgetstate')
        Facter::Core::Execution.stubs(:execute).
          with('/usr/lpp/mmfs/bin/mmgetstate 2>&1').
          returns(File.read(fixtures('mmgetstate', 'unknown')))

        Facter.fact(:gpfs_state).value.should == 'unknown'
      end
    end
  end # mmgetstate fact is working

end
