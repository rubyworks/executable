module Exectuable

  #
  DIRECTORY = File.dirname(__FILE__)

  #
  def self.version
    @package ||= (
      require 'yaml'
      YAML.load(File.new(DIRECTORY + '/version.yml'))
    )
  end

  #
  def self.const_missing(name)
    version[name.to_s.downcase] || super(name)
  end

  # because Ruby 1.8~ gets in the way
  remove_const(:VERSION) if const_defined?(:VERSION)

end

