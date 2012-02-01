module Executable

  # Variation of Executable which provides basic compatibility with
  # previous versions of Executable. It provides a call method that
  # automatically dispatches to publich methods.
  #
  # Among other uses, Dispatch can be useful for dropping into any class
  # as a quick and dirty way to work with it on the command line.
  #
  # @since 1.2.0
  module Dispatch
    Executable.__send__(:append_features, self)

    #
    # When Dispatchable is included into a class, the class is
    # also extended by `Executable::Domain`.
    #
    def self.included(base)
      base.extend Domain
    end

    def call(name, *args)
      public_method(name).call(*args)
    end
  end

  # Dispatch is Legacy.
  Legacy = Dispatch

end
