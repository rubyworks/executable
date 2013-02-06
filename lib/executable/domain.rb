module Executable

  #
  module Domain

    # TODO: Should this be in Help class?
    def usage_name
      list = []
      ancestors.each do |ancestor|
        break if Executable == ancestor
        list.unshift calculate_command_name(ancestor).to_s.strip
      end
      list.reject{|n| n.empty?}.join(" ")
    end

    #
    def calculate_command_name(ancestor)
      if ancestor.methods(false).include?(:command_name)
        command_name.to_s
      else
        cname = ancestor.name.sub(/\#\<.*?\>\:\:/,'').split('::').last.downcase
        cname.chomp('command').chomp('cli')
      end
    end

    private :calculate_command_name

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
    # TODO: Currently there is an unfortunate issue with using
    # this helper method. If does not correctly record the location
    # the method is called, so default help message is wrong.
    #
    def attr_switch(name)
      file, line = *caller[0].split(':')[0..1]
      module_eval(<<-END, file, line.to_i)
        def #{name}=(value)
          @#{name}=(value)
        end
        def #{name}?
          @#{name}
        end
      END
    end

    #
    # Alias a switch.
    #
    def alias_switch(name, origin)
      alias_method "#{name}=", "#{origin}="
      alias_method "#{name}?", "#{origin}?"
    end

    #
    # Alias an accessor.
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
    # Returns `help.to_s`. If you want to provide your own help
    # text you can override this method in your command subclass.
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
