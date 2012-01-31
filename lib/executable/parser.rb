module Executable

  # The Parser class does all the heavy lifting for Executable.
  #
  class Parser

    # 
    # @param [Executable] cli_class
    #   An executabe class.
    #
    def initialize(cli_class)
      @cli_class = cli_class
    end

    attr :cli_class

    # Parse command-line.
    #
    # @param argv [Array,String] command-line arguments
    #
    def parse(argv=ARGV)
      argv = parse_shellwords(argv)

      cmd, argv = parse_subcommand(argv)
      cli  = cmd.new
      args = parse_arguments(cli, argv)

      return cli, args
    end

    # Make sure arguments are an array. If argv is a String,
    # then parse using Shellwords module.
    #
    # @param argv [Array,String] commmand-line arguments
    def parse_shellwords(argv)
      if String === argv
        require 'shellwords'
        argv = Shellwords.shellwords(argv)
      end
      argv.to_a
    end

    #
    #
    #
    def parse_subcommand(argv)
      cmd = cli_class
      arg = argv.first

      while c = cmd.subcommands[arg]
        cmd = c
        argv.shift
        arg = argv.first
      end

      return cmd, argv
    end

    #
    # Parse command line options based on given object.
    #
    # @param obj [Object] basis for command-line parsing
    # @param argv [Array,String] command-line arguments
    # @param args [Array] pre-seeded arguments to add to
    #
    # @return [Array] parsed arguments
    #
    def parse_arguments(obj, argv, args=[])
      case argv
      when String
        require 'shellwords'
        argv = Shellwords.shellwords(argv)
      #else
      #  argv = argv.dup
      end

      #subc = nil
      #@args = []  #opts, i = {}, 0

      while argv.size > 0
        case arg = argv.shift
        when /=/
          parse_equal(obj, arg, argv, args)
        when /^--/
          parse_long(obj, arg, argv, args)
        when /^-/
          parse_flags(obj, arg, argv, args)
        else
          #if Executable === obj
          #  if cmd_class = obj.class.subcommands[arg]
          #    cmd  = cmd_class.new(obj)
          #    subc = cmd
          #    parse(cmd, argv, args)
          #  else
              args << arg
          #  end
          #end
        end
      end
     
      return args
    end

    #
    # Parse equal setting comman-line option.
    #
    def parse_equal(obj, opt, argv, args)
      if md = /^[-]*(.*?)=(.*?)$/.match(opt)
        x, v = md[1], md[2]
      else
        raise ArgumentError, "#{x}"
      end
      if obj.respond_to?("#{x}=")
        v = true  if v == 'true'   # yes or on  ?
        v = false if v == 'false'  # no  or off ?
        obj.send("#{x}=", v)
      else
        obj.__send__(:option_missing, x, v) # argv?
      end
    end

    #
    # Parse double-dash command-line option.
    #
    def parse_long(obj, opt, argv, args)
      x = opt.sub(/^\-+/, '') # remove '--'
      if obj.respond_to?("#{x}=")
        m = obj.method("#{x}=")
        if obj.respond_to?("#{x}?")
          m.call(true)
        else
          invoke(obj, m, argv)
        end
      elsif obj.respond_to?("#{x}!")
        invoke(obj, "#{x}!", argv)
      else
        # call even if private method
        obj.__send__(:option_missing, x, argv)
      end
    end

    # TODO: parse_flags needs some thought concerning character
    # spliting and arguments.

    #
    # Parse single-dash command-line option.
    #
    def parse_flags(obj, opt, argv, args)
      x = opt[1..-1]
      c = 0
      x.split(//).each do |k|
        if obj.respond_to?("#{k}=")
          m = obj.method("#{k}=")
          if obj.respond_to?("#{x}?")
            m.call(true)
          else
            invoke(obj, m, argv) #m.call(argv.shift)
          end
        elsif obj.respond_to?("#{k}!")
          invoke(obj, "#{k}!", argv)
        else
          long = find_long_option(obj, k)
          if long
            if long.end_with?('=') && obj.respond_to?(long.chomp('=')+'?')
              invoke(obj, long, [true])
            else
              invoke(obj, long, argv)
            end
          else
            obj.__send__(:option_missing, x, argv)
          end
        end
      end
    end

    #
    #
    # @todo Sort alphabetically?
    #
    def find_long_option(obj, char)
      meths = obj.methods.map{ |m| m.to_s }
      meths = meths.select do |m|
        m.start_with?(char) and (m.end_with?('=') or m.end_with?('!'))
      end
      meths.first
    end

    #
    #
    def invoke(obj, meth, argv)
      m = (Method === meth ? meth : obj.method(meth))
      a = []
      m.arity.abs.times{ a << argv.shift }
      m.call(*a)
    end

    # Index of subcommands.
    #
    # @return [Hash] name mapped to subcommnd class
    def subcommands
      @cli_class.subcommands
    end

  end

end
