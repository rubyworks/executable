module Executable

  #
  module Domain

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
    def attr_switch(name)
      attr_writer name
      module_eval %{
        def #{name}?
          @#{name}
        end
      }
    end

    # Run the command.
    #
    # @param argv [Array] command-line arguments
    #
    def execute(argv=ARGV)
      cli, args = parser.parse(argv)
      cli.call(*args)
      return cli
    end

    # CLI::Base classes don't run, they execute! But...
    alias_method :run, :execute

    # Command configuration options.
    #
    # @todo: This isn't used yet. Eventually the idea is to allow
    #   some additional flexibility in the parser behavior.
    def config
      @config ||= Config.new
    end

    # The parser for this command.
    def parser
      @parser ||= Parser.new(self)
    end

    # List of subcommands.
    def subcommands
      parser.subcommands
    end

    # Interface with cooresponding help object.
    def help
      @help ||= Help.new(self)
    end

    #
    def inspect
      name
    end

    # When inherited, setup up the +file+ and +line+ of the 
    # subcommand via +caller+. If for some odd reason this
    # does not work then manually use +setup+ method.
    #
    def included(subclass)
      file, line, _ = *caller.first.split(':')
      file = File.expand_path(file)
      subclass.help.setup(file,line.to_i)
    end

  end

end
