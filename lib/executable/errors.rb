module Executable

  class NoOptionError < ::NoMethodError # ArgumentError ?
    def initialize(name, *arg)
      super("unknown option -- #{name}", name, *args)
    end
  end

  #class NoCommandError < ::NoMethodError
  #  def initialize(name, *args)
  #    super("unknown command -- #{name}", name, *args)
  #  end
  #end

  class NoCommandError < ::NoMethodError
    def initialize(*args)
      super("missing command", *args)
    end
  end

end

