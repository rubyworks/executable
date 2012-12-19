module Exectuable

  #
  DIRECTORY = File.dirname(__FILE__)

  #
  def self.const_missing(name)
    index[name.to_s.downcase] || super(name)
  end

  #
  def self.index
    @index ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/../executable.yml'))
    )
  end

end

