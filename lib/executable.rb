# encoding: utf-8

require 'executable/errors'
require 'executable/parser'
require 'executable/help'
require 'executable/utils'
require 'executable/domain'
require 'executable/dispatch'

# Executable is a mixin for creating robust, inheritable and
# reusable command line interfaces.
#
module Executable

  #
  # When Exectuable is included into a class, the class is
  # also extended by `Executable::Doamin`.
  #
  def self.included(base)
    base.extend Domain
  end

  #
  # Default initializer, simply takes a hash of settings
  # to set attributes via writer methods. Not existant
  # attributes are simply ignored.
  #
  def initialize(settings={})
    settings.each do |k,v|
      __send__("#{k}=", v) if respond_to?("#{k}=")
    end
  end

public

  #
  # Command invocation abstract method.
  #
  def call(*args)
    #puts cli.show_help           # TODO: show help instead of error ?
    raise NotImplementedError
  end

  #
  # Convert Executable to Proc object.
  #
  def to_proc
    lambda { |*args| call(*args) }
  end

  alias_method :inspect, :to_s

  #
  # Output command line help.
  #
  def to_s
    self.class.help.to_s  # usage ?
  end

  #
  # Access to underlying Help instance.
  #
  def cli
    self.class.cli
  end

  #
  # Override option_missing if needed. This receives the name of the option
  # and the remaining arguments list. It must consume any arguments it uses
  # from the begining of the list (i.e. in-place manipulation).
  #
  def option_missing(opt, argv)
    raise NoOptionError, opt
  end

  # Base class alteranative ot using the mixin.
  #
  class Command
    include Executable
  end

end
