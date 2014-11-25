require 'spec_helper'

describe 'gpfs_packages', :type => :fact do
  before(:each) { Facter.clear }

  pkg_names = %w[
    gpfs.base
    gpfs.docs
    gpfs.gpl
    gpfs.msg.en_US
  ]

  pkg_wildcards = %w[
    gpfs.gplbin
  ]

  context 'gpfs is not installed' do
    it 'should return nil' do
      Facter::Core::Execution.stubs(:which).with('rpm').
        returns('/bin/rpm')

      pkg_names.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -q #{name} 2>&1").
          returns("package #{name} is not installed\n")
      end
      pkg_wildcards.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -qa | /bin/grep #{name} 2>&1").
          returns("")
      end

      Facter.fact(:gpfs_packages).value.should == nil
    end
  end

  context 'gpfs packages are installed' do
    it 'should return the the package versions' do
      Facter::Core::Execution.stubs(:which).with('rpm').
        returns('/bin/rpm')

      pkg_names.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -q #{name} 2>&1").
          returns(File.read(fixtures('rpm', name)))
      end
      pkg_wildcards.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -qa | /bin/grep #{name} 2>&1").
          returns(File.read(fixtures('rpm', name)))
      end

      Facter.fact(:gpfs_packages).value.should == {
        'gpfs.base'      => ['gpfs.base-3.5.0-21.x86_64'],
        'gpfs.docs'      => ['gpfs.docs-3.5.0-21.noarch'],
        'gpfs.gpl'       => ['gpfs.gpl-3.5.0-21.noarch'],
        'gpfs.msg.en_US' => ['gpfs.msg.en_US-3.5.0-21.noarch'],
        'gpfs.gplbin'    => ['gpfs.gplbin-2.6.32-504.1.3.el6.x86_64-3.5.0-21.x86_64'],
      }
    end
  end

  context 'some gpfs packages are installed' do
    it 'should return the the package versions' do
      Facter::Core::Execution.stubs(:which).with('rpm').
        returns('/bin/rpm')

      %w[gpfs.gpl gpfs.msg.en_US].each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -q #{name} 2>&1").
          returns("package #{name} is not installed\n")
      end
      pkg_wildcards.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -qa | /bin/grep #{name} 2>&1").
          returns("")
      end

      %w[gpfs.base gpfs.docs].each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -q #{name} 2>&1").
          returns(File.read(fixtures('rpm', name)))
      end

      Facter.fact(:gpfs_packages).value.should == {
        'gpfs.base'      => ['gpfs.base-3.5.0-21.x86_64'],
        'gpfs.docs'      => ['gpfs.docs-3.5.0-21.noarch'],
      }
    end
  end

  context 'multiple versions of gpfs packages are installed' do
    # this should not happen except for gpfs.gplbin
    it 'should return the the package versions' do
      Facter::Core::Execution.stubs(:which).with('rpm').
        returns('/bin/rpm')

      pkg_names.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -q #{name} 2>&1").
          returns(File.read(fixtures('rpm', "#{name}-multi")))
      end
      pkg_wildcards.each do |name|
        Facter::Core::Execution.stubs(:execute).
          with("/bin/rpm -qa | /bin/grep #{name} 2>&1").
          returns(File.read(fixtures('rpm', "#{name}-multi")))
      end

      # we are checking sort order as well
      Facter.fact(:gpfs_packages).value.should == {
        'gpfs.base'      => [
          'gpfs.base-3.5.0-17.x86_64',
          'gpfs.base-3.5.0-21.x86_64',
        ],
        'gpfs.docs'      => [
          'gpfs.docs-3.5.0-17.noarch',
          'gpfs.docs-3.5.0-21.noarch',
        ],
        'gpfs.gpl'       => [
          'gpfs.gpl-3.5.0-17.noarch',
          'gpfs.gpl-3.5.0-21.noarch',
        ],
        'gpfs.msg.en_US' => [
          'gpfs.msg.en_US-3.5.0-17.noarch',
          'gpfs.msg.en_US-3.5.0-21.noarch',
        ],
        'gpfs.gplbin'    => [
          'gpfs.gplbin-2.6.32-431.5.1.el6.x86_64-3.5.0-17.x86_64',
          'gpfs.gplbin-2.6.32-504.1.3.el6.x86_64-3.5.0-17.x86_64',
          'gpfs.gplbin-2.6.32-504.1.3.el6.x86_64-3.5.0-21.x86_64',
        ],
      }
    end
  end
end
