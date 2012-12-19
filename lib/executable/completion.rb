module Executable

  # Encpsulates command completion.
  #
  class Completion

    #
    # Setup new completion object.
    #
    def initialize(cli_class)
      @cli_class = cli_class

      @subcommands = nil
      @options     = nil
    end

    #
    alias_method :inspect, :to_s

    #
    # The Executable subclass to which this help applies.
    #
    attr :cli_class

    #
    # List of subcommands converted to a printable string.
    # But will return +nil+ if there are no subcommands.
    #
    # @return [String,NilClass] subcommand list text
    #
    def subcommands
      @subcommands ||= @cli_class.subcommands.keys
    end

    #
    def options
      @options ||= (
        method_list.map do |meth|
          case meth.name
          when /^(.*?)[\!\=]$/
            name = meth.name.to_s.chomp('!').chomp('=')
            mark = name.to_s.size == 1 ? '-' : '--'
            mark + name
          end
        end.compact.sort
      )
    end

    #
    def to_s
      (subcommands + options).join(' ')
    end

    #
    def call(*args)
      puts self
    end

  private

    #
    # Produce a list relavent methods.
    #
    def method_list
      list      = []
      methods   = []
      stop_at   = cli_class.ancestors.index(Executable::Command) ||
                  cli_class.ancestors.index(Executable) ||
                  -1
      ancestors = cli_class.ancestors[0...stop_at]
      ancestors.reverse_each do |a|
        a.instance_methods(false).each do |m|
          list << cli_class.instance_method(m)
        end
      end
      list
    end

  end

end

