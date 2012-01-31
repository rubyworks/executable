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
    def inspect
      name
    end

    #
    # Command configuration options.
    #
    # @todo: This isn't used yet. Eventually the idea is to allow
    #   some additional flexibility in the parser behavior.
    #
    def config
      @config ||= Config.new
    end

    #
    # Interface with cooresponding help object.
    #
    def help
      @help ||= Help.new(self)
    end

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
    #
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
            n = c.name.split('::').last.downcase
            h[n] = c
          end
          h
        end
      )
    end

  end

end
