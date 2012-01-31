# TITLE:
#
#   Command
#
# COPYRIGHT:
#
#   Copyright (c) 2005 Thomas Sawyer
#
# LICENSE:
#
#   Ruby License
#
#   This module is free software. You may use, modify, and/or
#   redistribute this software under the same terms as Ruby.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.
#
# AUTHORS:
#
#   - 7rans
#   - Tyler Rick
#
# TODOs:
#
#   - Add help/documentation features.
#   - Problem with exit -1 when testing. See IMPORTANT!!! remark below.
#
# LOG:
#
#   - 2007.10.31 TRANS
#     Re-added support for __option notation.

require 'facets/module/attr'
require 'facets/kernel/constant'
require 'facets/arguments'
require 'shellwords'
#require 'facets/annotations' # for help ?

module Console

  # For CommandOptions, but defined external to it, so
  # that it is easy to access from user defined commands.
  # (This lookup issue should be fixed in Ruby 1.9+, and then
  # the class can be moved back into Command namespace.)

  class NoOptionError < NoMethodError
    def initialize(name, *arg)
      super("unknown option -- #{name}", name, *args)
    end
  end

  class NoCommandError < NoMethodError
    def initialize(name, *arg)
      super("unknown subcommand -- #{name}", name, *args)
    end
  end

  # Here is an example of usage:
  #
  #   # General Options
  #
  #   module GeneralOptions
  #     attr_accessor :dryrun ; alias_accessor :n, :noharm, :dryrun
  #     attr_accessor :quiet  ; alias_accessor :q, :quiet
  #     attr_accessor :force
  #     attr_accessor :trace
  #   end
  #
  #   # Build Subcommand
  #
  #   class BuildCommand < Console::Command
  #     include GeneralOptions
  #
  #     # metadata files
  #     attr_accessor  :file     ; alias_accessor :f, :file
  #     attr_accessor  :manifest ; alias_accessor :m, :manifest
  #
  #     def call
  #       # do stuf here
  #     end
  #   end
  #
  #   # Box Master Command
  #
  #   class BoxCommand < Console::MasterCommand
  #     subcommand :build,     BuildCommand
  #     subcommand :install,   InstallCommand
  #     subcommand :uninstall, UninstallCommand
  #   end

  class MasterCommand

    #

    def self.start(line=nil)
      cargs = Console::Arguments.new(line || ARGV)
      pre = cargs.preoptions
      cmd, argv  = *cargs.subcommand
      args, opts = *argv
      new(pre).send(cmd, *(args << opts))
    end

    #

    def self.subcommand(name, command_class, options=nil)
      options ||= {}
      if options[:no_merge]
        file, line = __FILE__, __LINE__+1
        code = %{
          def #{name}(*args)
            #{command_class}.new(*args).call
          end
        }
      else
        file, line = __FILE__, __LINE__+1
        code = %{
          def #{name}(*args)
            (Hash===args.last ? args.last.merge(master_options) : args << master_options)
            #{command_class}.new(*args).call
          end
        }
      end
      class_eval(code, file, line)
    end

    private

    attr :master_options

    #

    def initialize(master_options=nil)
      @master_options = master_options || {}
    end

    public

    #

    def send(cmd, *args)
      cmd = :default if cmd.nil?
      begin
        subcommand = method(cmd)
        parameters = args
      rescue NameError
        subcommand = method(:subcommand_missing)
        parameters = [cmd, *args]
      end
      if subcommand.arity < 0
        subcommand.call(*parameters[0..subcommand.arity])
      else
        subcommand.call(*parameters[0,subcommand.arity])
      end
    end

    #

    def help; end

    def default ; help ; end

    #

    def subcommand_missing(cmd, *args)
      help
      #raise NoCommandError.new(cmd, *args)
    end

  end


  # = Command base class
  #
  # See MasterCommand for example.

  class Command

    def self.start(line=nil)
      cargs = Console::Argument.new(line || ARGV)
      pre = cargs.preoptions
      args, opts = *cargs.parameters
      new(args, opts).call
    end

    attr :arguments
    attr :options

    #

    def call
      puts "Not implemented yet."
    end

  private

    #

    def initialize(*arguments)
      options = (Hash===arguments.last ? arguments.pop : nil)
      initialize_arguments(*arguments)
      initialize_options(options)
    end

    #

    def initialize_arguments(*arguments)
      @arguments = arguments
    end

    #

    def initialize_options(options)
      options = options || {}
      begin
        opt, val = nil, nil
        options.each do |opt, val|
          send("#{opt}=", val)
        end
      rescue NoMethodError
        option_missing(opt, val)
      end
      @options = options
    end

    #

    def option_missing(opt, arg=nil)
      raise NoOptionError.new(opt)
    end

  end

end


=begin


  class Command

    # Command Syntax DSL

    class << self

      # Starts the command execution.
      def execute(*args)
        cmd = new()
        #cmd.instance_variable_set("@global_options",global_options)
        cmd.execute(*args)
      end
      alias_method :start, :execute

      # Change the option mode.
      def global_option(*names)
        names.each{ |name| global_options << name.to_sym }
      end
      alias_method :global_options, :global_option

      # Define a set of options. This can be a Command::Options subclass,
      # or a block which will be used to create an Command::Options subclass.

      def options(name, klass=nil, &block)
        raise ArgumentError if klass && block
        if block
          command_options[name.to_sym] = Class.new(Options, &block)
        else
          command_options[name.to_sym] = klass
        end
      end
      alias_method :opts, :options
      alias_method :opt, :options

      #

      def command_options
        @_command_options ||= {}
      end

      #

      def global_options
        @_global_options ||= []
      end
    end

    #def initialize #(global_options=nil)
    #  #@global_options = global_options || []
    #end

    #

    def execute(line=ARGV)
      argv = line

      g_opts = Command::Options.new(self)
      g_keys = self.class.global_options

      # Deal with global options.
      if g_keys && ! g_keys.empty?
        argv = g_opts.parse(argv, :only => g_keys)
      end

      # Sole main command or has subcommands?
      if respond_to?(:main)
        argv = g_opts.parse(argv, :pass => true)
        cmd = :main
      else
        argv = g_opts.parse(argv, :stop => true)
        cmd = argv.find{ |s| s !~ /^-/ }
              argv.delete_at(argv.index(cmd)) if cmd
        cmd = :default unless cmd
        cmd = cmd.to_sym
      end

      keys = self.class.command_options

      if keys.key?(cmd)
        opts = keys[cmd].new
        argv = opts.parse(argv)
      end

      argv = g_opts.parse_missing(argv)

      call(cmd, argv, opts)
    end

    #

    def call(subcmd, argv, opts)
      @options = opts  # should we use this it fill in instance vars?

      # This is a little tricky. The method has to be defined by a subclass.
      if self.respond_to?(subcmd) and not Console::Command.public_instance_methods.include?(subcmd.to_s)
        puts "# call: #{subcmd}(*#{argv.inspect})" if $debug
        __send__(subcmd, *argv)
      else
        begin
          puts "# call: method_missing(#{subcmd.inspect}, #{argv.inspect})" if $debug
          method_missing(subcmd.to_sym, *argv)
        rescue NoMethodError => e
          #if self.private_methods.include?( "no_command_error" )
          #  no_command_error( *args )
          #else
            $stderr << "Unrecognized subcommand -- #{subcmd}\n"
            exit -1
          #end
        end
      end
    end

    #

    def call(argv, opts)
      begin
        opts.each do |opt, val|
          send("#{opt}=", val)
        end
      rescue NoMethodError => e
        option_missing(opt, val)
      end
    end

    #def global_options
    #  self.class.global_options
    #end

    def option_missing(opt, arg=nil)
      raise InvalidOptionError.new(opt)
    end

  end


  # We include a module here so you can define your own help
  # command and call #super to utilize this one.

  module Help

    def help
      opts = help_options
      s = ""
      s << "#{File.basename($0)}\n\n"
      unless opts.empty?
        s << "OPTIONS\n"
        s << help_options
        s << "\n"
      end
      s << "COMMANDS\n"
      s << help_commands
      puts s
    end

    private

    def help_commands
      help = self.class.help
      bufs = help.keys.collect{ |a| a.to_s.size }.max + 3
      lines = []
      help.each { |cmd, str|
        cmd = cmd.to_s
        if cmd !~ /^_/
          lines << "  " + cmd + (" " * (bufs - cmd.size)) + str
        end
      }
      lines.join("\n")
    end

    def help_options
      help = self.class.help
      bufs = help.keys.collect{ |a| a.to_s.size }.max + 3
      lines = []
      help.each { |cmd, str|
        cmd = cmd.to_s
        if cmd =~ /^_/
          lines << "  " + cmd.gsub(/_/,'-') + (" " * (bufs - cmd.size)) + str
        end
      }
      lines.join("\n")
    end

    module ClassMethods

      def help( str=nil )
        return (@help ||= {}) unless str
        @current_help = str
      end

      def method_added( meth )
        if @current_help
          @help ||= {}
          @help[meth] = @current_help
          @current_help = nil
        end
      end

    end

  end

  include Help
  extend Help::ClassMethods



  # = Command::Options
  #
  # CommandOptions provides the basis for Command to Object Mapping (COM).
  # It is an commandline options parser that uses method definitions
  # as means of interprting command arguments.
  #
  # == Synopsis
  #
  # Let's make an executable called 'mycmd'.
  #
  #   #!/usr/bin/env ruby
  #
  #   require 'facets/command_options'
  #
  #   class MyOptions < CommandOptions
  #     attr_accessor :file
  #
  #     def v!
  #       @verbose = true
  #     end
  #   end
  #
  #   opts = MyOptions.parse("-v --file hello.rb")
  #
  #   opts.verbose  #=> true
  #   opts.file     #=> "hello.rb"
  #
  #--
  # == Global Options
  #
  # You can define <i>global options</i> which are options that will be
  # processed no matter where they occur in the command line. In the above
  # examples only the options occuring before the subcommand are processed
  # globally. Anything occuring after the subcommand belonds strictly to
  # the subcommand. For instance, if we had added the following to the above
  # example:
  #
  #   global_option :_v
  #
  # Then -v could appear anywhere in the command line, even on the end,
  # and still work as expected.
  #
  #   % mycmd jump -h 3 -v
  #++
  #
  # == Missing Options
  #
  # You can use #option_missing to catch any options that are not explicility
  # defined.
  #
  # The method signature should look like:
  #
  #   option_missing(option_name, args)
  #
  # Example:
  #   def option_missing(option_name, args)
  #     p args if $debug
  #     case option_name
  #       when 'p'
  #         @a = args[0].to_i
  #         @b = args[1].to_i
  #         2
  #       else
  #         raise InvalidOptionError(option_name, args)
  #     end
  #   end
  #
  # Its return value should be the effective "arity" of that options -- that is,
  # how many arguments it consumed ("-p a b", for example, would consume 2 args:
  # "a" and "b"). An arity of 1 is assumed if nil or false is returned.

  class Command::Options

    def self.parse(*line_and_options)
      o = new
      o.parse(*line_and_options)
      o
    end

    def initialize(delegate=nil)
      @__self__ = delegate || self
    end

    # Parse line for options in the context self.
    #
    # Options:
    #
    #   :pass => true || false
    #
    # Setting this to true prevents the parse_missing routine from running.
    #
    #   :only => [ global options, ... ]
    #
    # When processing global options, we only want to parse selected options.
    # This also set +pass+ to true.
    #
    #   :stop => true || false
    #
    # If we are parsing options for the *main* command and we are allowing
    # subcommands, then we want to stop as soon as we get to the first non-option,
    # because that non-option will be the name of our subcommand and all options that
    # follow should be parsed later when we handle the subcommand.
    # This also set +pass+ to true.

    def parse(*line_and_options)
      __self__ = @__self__

      if Hash === line_and_options.last
        options = line_and_options.pop
        line    = line_and_options.first
      else
        options = {}
        line    = line_and_options.first
      end

      case line
      when String
        argv = Shellwords.shellwords(line)
      when Array
        argv = line.dup
      else
        argv = ARGV.dup
      end

      only = options[:only]                      # only parse these options
      stop = options[:stop]                      # stop at first non-option
      pass = options[:pass] || only || stop      # don't run options_missing

      if $debug
        puts(only ? "\nGlobal parsing..." : "\nParsing...")
      end

      puts "# line: #{argv.inspect}" if $debug

      # Split single letter option groupings into separate options.
      # ie. -xyz => -x -y -z
      argv = argv.collect { |arg|
        if md = /^-(\w{2,})/.match( arg )
          md[1].split(//).collect { |c| "-#{c}" }
        else
          arg
        end
      }.flatten

      index = 0

      until index >= argv.size
        arg = argv.at(index)
        break if arg == '--'  # POSIX compliance
        if arg[0,1] == '-'
          puts "# option: #{arg}" if $debug
          cnt = (arg[0,2] == '--' ? 2 : 1)
          #opt  = Option.new(arg)
          #name = opt.methodize
          name = arg.sub(/^-{1,2}/,'')
          skip = only && only.include?(name)
          unam = ('__'*cnt)+name
          if __self__.respond_to?(unam)
            puts "# method: #{uname}" if $debug
            meth = method(unam)
            arity = meth.arity
            if arity < 0
              meth.call(*argv.slice(index+1..-1)) unless skip
              arity[index..-1] = nil # Get rid of the *name* and values
            elsif arity == 0
              meth.call unless skip
              argv.delete_at(index) # Get rid of the *name* of the option
            else
              meth.call(*argv.slice(index+1, arity)) unless skip
              #argv.delete_at(index) # Get rid of the *name* of the option
              #arity.times{ argv.delete_at(index) } # Get rid of the *value* of the option
              arity[index,arity] = nil
            end
          elsif __self__.respond_to?(name+'=')
            puts "# method: #{name}=" if $debug
            __self__.send(name+'=', *argv.slice(index+1, 1)) unless skip
            argv.delete_at(index) # Get rid of the *name* of the option
            argv.delete_at(index) # Get rid of the *value* of the option
          elsif __self__.respond_to?(name+'!')
            puts "# method: #{name}!" if $debug
            __self__.send(name+'!') unless skip
            argv.delete_at(index) # Get rid of the *name* of the option
          else
             index += 1
          end
        else
          index += 1
          break if stop
        end
      end
      # parse missing ?
      argv = parse_missing(argv) unless pass
      # return the remaining argv
      puts "# return: #{argv.inspect}" if $debug
      return argv
    end

    #

    def parse_missing(argv)
      argv.each_with_index do |a,i|
        if a =~ /^-/
          #raise InvalidOptionError.new(a) unless @__self__.respond_to?(:option_missing)
          kept = @__self__.option_missing(a, *argv[i+1,1])
          argv.delete_at(i) if kept  # delete if value kept
          argv.delete_at(i)          # delete option
        end
      end
      return argv
    end

    #

    def option_missing(opt, arg=nil)
      raise InvalidOptionError.new(opt)
      #  #$stderr << "Unknown option '#{arg}'.\n"
      #  #exit -1
    end

    #

    def to_h
      opts = @__self__.public_methods(true).select{ |m| m =~ /^[A-Za-z0-9]+[=!]$/ || m =~ /^[_][A-Za-z0-9]+$/ }
      #opts.reject!{ |k| k =~ /_$/ }
      opts.collect!{ |m| m.chomp('=').chomp('!') }
      opts.inject({}) do |h, m|
        k = m.sub(/^_+/, '')
        v = @__self__.send(m)
        h[k] = v if v
        h
      end

      #@__self__.instance_variables.inject({}) do |h, v|
      #  next h if v == "@__self__"
      #  h[v[1..-1]] = @__self__.instance_variable_get(v); h
      #end
    end

    # Provides a very basic usage help string.
    #
    # TODO Add support for __options.
    def usage
      str = []
      public_methods(false).sort.each do |meth|
        meth = meth.to_s
        case meth
        when /^_/
          opt = meth.sub(/^_+/, '')
          meth = method(meth)
          if meth.arity == 0
            str << (opt.size > 1 ? "[--#{opt}]" : "[-#{opt}]")
          elsif meth.arity == 1
            str << (opt.size > 1 ? "[--#{opt} value]" : "[-#{opt} value]")
          elsif meth.arity > 0
            v = []; meth.arity.times{ |i| v << 'value' + (i + 1).to_s }
            str << (opt.size > 1 ? "[--#{opt} #{v.join(' ')}]" : "[-#{opt} #{v.join(' ')}]")
          else
            str << (opt.size > 1 ? "[--#{opt} *values]" : "[-#{opt} *values]")
          end
        when /=$/
          opt = meth.chomp('=')
          str << (opt.size > 1 ? "[--#{opt} value]" : "[-#{opt} value]")
        when /!$/
          opt = meth.chomp('!')
          str << (opt.size > 1 ? "[--#{opt}]" : "[-#{opt}]")
        end
      end
      return str.join(" ")
    end

    #

    def self.usage_class(usage)
      c = Class.new(self)
      argv = Shellwords.shellwords(usage)
      argv.each_with_index do |name, i|
        if name =~ /^-/
          if argv[i+1] =~ /^[(.*?)]/
            c.class_eval %{
              attr_accessor :#{name}
            }
          else
            c.class_eval %{
              attr_reader :#{name}
              def #{name}! ; @#{name} = true ; end
            }
          end
        end
      end
      return c
    end

  end

=end
