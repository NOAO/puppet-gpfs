Facter.add(:mmgetstate) do
  setcode do
    Facter::Util::Resolution.which('mmgetstate')
  end
end
