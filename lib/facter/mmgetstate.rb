Facter.add(:mmgetstate) do
  setcode do
    Facter::Core::Execution.which('mmgetstate')
  end
end
