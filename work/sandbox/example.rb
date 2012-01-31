require 'executable'

class MyCli < Executable::Command

  # Example command.
  def call
  end

end

x = MyCli.new

p x

puts x
