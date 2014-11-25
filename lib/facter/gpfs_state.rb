Facter.add(:gpfs_state) do
  mmgetstate = Facter.value(:mmgetstate)

  setcode do
    unless mmgetstate.nil?
      output = Facter::Core::Execution.execute("#{mmgetstate} 2>&1")
      next if output.nil?

      #       20      foo1             active
      m = output.match(/^\s* (\d+)\s+(\w+)\s+(\w+) \s*$/mx)

      next if m.nil?
      next unless m.size == 4
      m[3]
    end
  end
end
