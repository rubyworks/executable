# encoding: utf-8

require 'executable/errors'
require 'executable/parser'
require 'executable/help'
require 'executable/config'
require 'executable/utils'
require 'executable/domain'

# Executable is the sup'd-up base class for creating robust, inheritable and
# reusable command line interfaces.
#
#   class MyCLI
#     include Executable
#
#     # foo --debug
#
#     def debug?
#       $DEBUG
#     end
#
#     def debug=(bool)
#       $DEBUG = bool
#     end
#
#     # $ foo remote
#
#     class Remote
#
#       # $ foo remote --verbose
#
#       def verbose?
#         @verbose
#       end
#
#       def verbose=(bool)
#         @verbose = bool
#       end
#
#       # $ foo remote --force
#
#       def force?
#         @force
#       end
#
#       def force=(bool)
#         @force = bool
#       end
#
#       # $ foo remote --output <path>
#
#       def output=(path)
#         @path = path
#       end
#
#       # $ foo remote -o <path>
#
#       alias_method :o=, :output=
#
#       # $ foo remote add
#
#       class Add < self
#
#         def main(name, branch)
#           # ...
#         end
#
#       end
#
#       # $ foo remote show
#
#       class Show < self
#
#         def main(name)
#           # ...
#         end
#
#       end
#
#     end
#
#   end
#

# Base class for command line parrsing.
#
module Executable
  def self.included(base)
    base.extend Domain
  end

  #
  def call(*args)
    #puts self.class  # TODO: fix help
    raise NoCommandError #NotImplementedError
  end

  # Override option_missing if needed. This receives the name of the option
  # and the remaining arguments list. It must consume any arguments it uses
  # from the begining of the list (i.e. in-place manipulation).
  #
  def option_missing(opt, argv)
    raise NoOptionError, opt
  end

  # Access the help instance of the class of the command object.
  def cli_help
    self.class.help
  end

  # Alterate use as a base class.
  #
  class Base
    include Executable

    # When inherited, setup up the +file+ and +line+ of the 
    # subcommand via +caller+. If for some odd reason this
    # does not work then manually use +setup+ method.
    #
    def self.inherited(subclass)
      file, line, _ = *caller.first.split(':')
      file = File.expand_path(file)
      subclass.help.setup(file,line.to_i)
    end
  end

end
