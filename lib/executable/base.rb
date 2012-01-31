# Base class for command line parrsing.
#
module Executable

  def self.included(base)
    base.extend Domain
  end

  # TODO: Should #main be called #call instead?

  #
  def main(*args)
    #puts self.class  # TODO: fix help
    raise NotImplementedError
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

end

