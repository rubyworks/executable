require 'executable/source'
require 'executable/core_ext'

module Executable

  # Encpsulates command help for defining and displaying well formated help
  # output in plain text or via manpages if found.
  #
  class Help

    #
    def self.section(name, &default)
      define_method("default_#{name}", &default)
      class_eval %{
        def #{name}(text=nil)
          @#{name} = text.to_s unless text.nil?
          @#{name} ||= default_#{name}
        end
        def #{name}=(text)
          @#{name} = text.to_s
        end
      }
    end

    # Setup new help object.
    def initialize(cli_class)
      @cli_class = cli_class

      @usage      = nil
      @decription = nil
      @copying    = nil
      @see_also   = nil

      @options = {}
      @subcmds = {}
    end

    #alias_method :inspect, :to_s

    # Set file and line under which the Executable object is defined.
    #
    # @deprecated
    def setup(file, line=nil)
      @file = file
      @line = line
    end

    #
    # The CLI::Base subclass to which this help applies.
    #
    attr :cli_class

    #
    # Get or set command name.
    # 
    # By default the name is assumed to be the class name, substituting
    # dashes for double colons.
    #
    # @method name(text=nil)
    #
    section(:name) do
      cli_class.name.sub(/\#\<.*?\>\:\:/,'').downcase.gsub('::','-')
    end

    #
    # Get or set command usage string.
    #
    # @method usage(text=nil)
    #
    section(:usage) do
      "Usage: " + name + ' [options...] [subcommand]'
    end

    #
    # Get or set command description.
    #
    # @method description(text=nil)
    #
    section(:description) do
      nil
    end

    #
    # Get or set copyright text.
    #
    # @method copyright(text=nil)
    #
    section(:copyright) do
      'Copyright (c) ' + Time.now.strftime('%Y')
    end

    #
    # Get or set "see also" text.
    #
    # @method see_also(text=nil)
    #
    section(:see_also) do
      nil
    end

    #
    # Set description of an option.
    #
    def option(name, description)
      @options[name.to_s] = description
    end

    #
    # Set desciption of a subcommand.
    #
    def subcommand(name, description)
      @subcmds[name.to_s] = description
    end

    #
    # Show help.
    #
    # @todo man-pages will probably fail on Windows
    #
    def show_help(hint=nil)
      if file = manpage(hint)
        system "man #{file}"
      else
        puts text  # ronn
      end
    end

    #
    # Get man-page if there is one.
    #
    def manpage(hint=nil)
      @manpage ||= (
        man  = []
        dir  = @file ? File.dirname(@file) : nil
        glob = "man/#{name}.1"

        if hint
          if File.exist?(hint)
            return hint
          elsif File.directory?(hint)
            dir = hint
          else
            glob = hint if hint
          end
        end

        if dir
          while dir != '/'
            man.concat(Dir[File.join(dir, glob)])
            #man.concat(Dir[File.join(dir, "man/man1/#{name}.1")])
            #man.concat(Dir[File.join(dir, "man/#{name}.1.ronn")])
            #man.concat(Dir[File.join(dir, "man/man1/#{name}.1")])
            break unless man.empty?
            dir = File.dirname(dir)
          end
        end

        man.first
      )
    end

    #
    # Generate plain text output.
    #
    def text
      commands = text_subcommands
      options  = text_options

      s = []

      s << usage
      s << text_description

      if !commands.empty?
        s << "COMMANDS\n" + commands.map{ |cmd, desc|
          "  %-17s %s" % [cmd, desc] 
        }.join("\n")
      end

      if !options.empty?
        s << "OPTIONS\n" + options.map{ |max, opt|
          "  %2s%-#{max}s %s" % [opt.mark, opt.usage, opt.description]
        }.join("\n")
      end

      s << copyright
      s << see_also

      s.compact.join("\n\n")
    end

    #
    alias_method :to_s, :text

    #
    # Generate a ronn-formated Markdown.
    #
    def ronn
      commands = text_subcommands
      options  = text_options

      s = []

      h = "#{name}(1) - #{text_description}"
      s << h + "\n" + ("=" * h.size)

      s << "## SYNOPSIS"
      s << "`" + name + "` [options...] [subcommand]"

      s << "## DESCRIPTION"
      s << text_description

      if !commands.empty?
        s << "## COMMANDS"
        s << commands.map{ |cmd, desc|
          "  * `%s:`\n    %s" % [cmd, desc] 
        }.join("\n")
      end

      if !options.empty?
        s << "## OPTIONS"
        s << options.map{ |max, opt|
          "  * `#{opt.mark}%s`:\n    %s" % [opt.usage, opt.description]
        }.join("\n\n")
      end

      if copyright && !copyright.empty?
        s << "## COPYRIGHT"
        s << copyright
      end

      if see_also && !see_also.empty?
        s << "## SEE ALSO"
        s << see_also
      end

      s.compact.join("\n\n")
    end

    #
    # Description of command in printable form.
    # But will return +nil+ if there is no description.
    #
    # @return [String,NilClass] command description
    #
    def text_description
      return description if description
      #return Source.get_above_comment(@file, @line) if @file

      if main = method_list.find{ |m| m.name == :call }
        main.comment
      else
        nil
      end
    end

    #
    # List of subcommands converted to a printable string.
    # But will return +nil+ if there are no subcommands.
    #
    # @return [String,NilClass] subcommand list text
    #
    def text_subcommands
      commands = @cli_class.subcommands
      commands.map do |cmd, klass|
        desc = klass.help.text_description.to_s.split("\n").first
        [cmd, desc]
      end
    end

    #
    # List of options coverted to a printable string.
    # But will return +nil+ if there are no options.
    # 
    # @return [Array<Fixnum, Options>] option list for output
    #
    def text_options
      option_list.each do |opt|
        if @options.key?(opt.name)
          opt.description = @options[opt.name]
        end
      end    

      max = option_list.map{ |opt| opt.usage.size }.max + 2

      option_list.map do |opt|
        [max, opt]
      end
    end

    #
    #def text_common_options
      #s << "\nCOMMON OPTIONS:\n\n"
      #global_options.each do |(name, meth)|
      #  if name.size == 1
      #    s << "   -%-15s %s\n" % [name, descriptions[meth]]
      #  else
      #    s << "  --%-15s %s\n" % [name, descriptions[meth]]
      #  end
      #end
    #end

    #
    def option_list
      @option_list ||= (
        method_list.map do |meth|
          case meth.name
          when /^(.*?)[\!\=]$/
            Option.new(meth)
          end
        end.compact.sort
      )
    end

  private

    # Produce a list relavent methods.
    #
    def method_list
      list      = []
      methods   = []
      stop_at   = cli_class.ancestors.index(Executable::Base) || cli_class.ancestors.index(Executable) || -1
      ancestors = cli_class.ancestors[0...stop_at]
      ancestors.reverse_each do |a|
        a.instance_methods(false).each do |m|
          list << cli_class.instance_method(m)
        end
      end
      list
    end

    # Encapsualtes a command line option.
    class Option
      def initialize(method)
        @method = method
      end

      def name
        @method.name.to_s.chomp('!').chomp('=')
      end

      def comment
        @method.comment
      end

      def description
        @description ||= comment.split("\n").first
      end

      # Set description manually.
      def description=(desc)
        @description = desc
      end

      def parameter
        begin
          @method.owner.instance_method(@method.name.to_s.chomp('=') + '?')
          false
        rescue
          param = @method.parameters.first
          param.last if param
        end
      end

      #
      def usage
        if parameter
          "#{name}=#{parameter.to_s.upcase}"
        else
          "#{name}"
        end
      end

      def <=>(other)
        self.name <=> other.name
      end

      #
      def mark
        name.to_s.size == 1 ? '-' : '--'
      end

    end
  end

end
