module Executable

  #
  module Domain

    #
    # Helper method for creating switch attributes.
    #
    # This is equivalent to:
    #
    #   def name=(val)
    #     @name = val
    #   end
    #
    #   def name?
    #     @name
    #   end
    #
    #
    def attr_switch(name)
      attr_writer name
      module_eval %{
        def #{name}?
          @#{name}
        end
      }
    end

    #
    # 
    #
    def alias_switch(name, origin)
      alias_method "#{name}=", "#{origin}="
      alias_method "#{name}?", "#{origin}?"
    end

    #
    #
    #
    def alias_accessor(name, origin)
      alias_method "#{name}=", "#{origin}="
      alias_method "#{name}",  "#{origin}"
    end

    #
    # Inspection method. This must be redefined b/c #to_s is overridden.
    #
    def inspect
      name
    end

    #
    # Returns `help.to_s`.
    #
    def to_s
      cli.to_s
    end

    #
    # Interface with cooresponding cli/help object.
    #
    def help
      @help ||= Help.new(self)
    end

    #
    # Interface with cooresponding cli/help object.
    #
    alias_method :cli, :help

    #
    # Execute the command.
    #
    # @param argv [Array] command-line arguments
    #
    def execute(argv=ARGV)
      cli, args = parser.parse(argv)
      cli.call(*args)
      return cli
    end

    #
    # Executables don't run, they execute! But...
    #
    alias_method :run, :execute

    #
    #
    # @return [Array<Executable,Array>] The executable and call arguments.
    def parse(argv)
      parser.parse(argv)
    end

    #
    # The parser for this command.
    #
    def parser
      @parser ||= Parser.new(self)
    end

    #
    # Index of subcommands.
    #
    # @return [Hash] name mapped to subcommnd class
    #
    def subcommands
      @subcommands ||= (
        consts = constants - superclass.constants
        consts.inject({}) do |h, c|
          c = const_get(c)
          if Class === c && Executable > c
            n = c.name.split('::').last
            n = n.chomp('Command').chomp('CLI')
            n = n.downcase
            h[n] = c
          end
          h
        end
      )
    end

  end

end
