module Exectutable

  # Bare minimum variation of Executable which provides basic compatibility
  # with previous versions of Exectuable. It provides nothing but the 
  # Domain method at the class level and a `#__call__` method that dipatches
  # to public methods.
  #
  # Among other uses, Dispatchable can be useful for dropping into any class
  # as a quick and dirty way to work with it on the command line.
  #
  # @since 1.2.0
  module Dispatchable
    #
    # When Dispatchable is included into a class, the class is
    # also extended by `Executable::Domain`.
    #
    def self.included(base)
      base.extend Domain
      base.dispatcher = :__call__
    end

    def __call__(name, *args)
      public_method(name).call(args)
    end
  end

end
