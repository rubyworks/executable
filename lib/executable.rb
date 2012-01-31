# encoding: utf-8

require 'executable/errors'
require 'executable/parser'
require 'executable/help'
require 'executable/config'
require 'executable/utils'
require 'executable/domain'

# Executable is a mixin for creating robust, inheritable and
# reusable command line interfaces.
#
module Executable

  #
  #
  #
  def self.included(base)
    base.extend Domain
  end

  #
  # Default initializer, simply takes a hash of settings
  # to set attributes via writer methods. Not existnt
  # attributes are simply ignored.
  #
  def initialize(settings={})
    settings.each do |k,v|
      __send__("#{k}=", v) if respond_to?("#{k}=")
    end
  end

  #
  #
  #
  def call(*args)
    #puts self.class  # TODO: fix help
    raise NoCommandError #NotImplementedError
  end

  #
  # Convert executable to Proc object.
  #
  def to_proc
    lambda { |*args| call(*args) }
  end

  #
  # Override option_missing if needed. This receives the name of the option
  # and the remaining arguments list. It must consume any arguments it uses
  # from the begining of the list (i.e. in-place manipulation).
  #
  def option_missing(opt, argv)
    raise NoOptionError, opt
  end

  #
  # Access the help instance of the class of the command object.
  #
  def command_help
    self.class.help
  end

  # Alterate use as a base class.
  #
  class Base
    include Executable
  end

end
