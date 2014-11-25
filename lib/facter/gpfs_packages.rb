Facter.add(:gpfs_packages) do
  # if rpm is missing we're so screwed it's not worthing checking...
  rpm = Facter::Core::Execution.which('rpm')

  pkg_names = %w[
    gpfs.base
    gpfs.docs
    gpfs.gpl
    gpfs.msg.en_US
  ]

  pkg_wildcards = %w[
    gpfs.gplbin
  ]

  setcode do
    unless rpm.nil?
      pkgs = {}
      
      pkg_names.each do |name|
        output = Facter::Core::Execution.execute("#{rpm} -q #{name} 2>&1")
        next if output.nil?
        # $ rpm -q foo
        # package foo is not installed
        next unless output.match(/package .+ is not installed/).nil?

        pkgs[name] = output.split("\n").sort
      end

      # these packages have a version as part of the literal package name and
      # can not be matched with -q
      pkg_wildcards.each do |name|
        # posix says grep should be there
        output = Facter::Core::Execution.execute("#{rpm} -qa | /bin/grep #{name} 2>&1")
        next if output.nil?
        # because of the shell pipeline, an empty string is returned if there
        # are no matches
        next if output == ""

        pkgs[name] = output.split("\n").sort
      end

      if pkgs.empty?
        next nil
      else
        next pkgs
      end
    end
  end
end
