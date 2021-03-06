require 'executable/core_ext'

module Executable

  # Encpsulates command help for defining and displaying well formated help
  # output in plain text, markdown or via manpages if found.
  #
  # Creating text help in the fly is fine for personal projects, but
  # for production app, ideally you want to have man pages. You can
  # use the #markdown method to generate `.ronn` files and use the
  # ronn tool to build manpages for your project. There is also the
  # binman and md2man projects which can be used similarly.
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

    #
    # Setup new help object.
    #
    def initialize(cli_class)
      @cli_class = cli_class

      @name       = nil
      @usage      = nil
      @decription = nil
      @copying    = nil
      @see_also   = nil

      @options = {}
      @subcmds = {}
    end

    #
    alias_method :inspect, :to_s

    #
    # The Executable subclass to which this help applies.
    #
    attr :cli_class

    #
    # Get or set command name.
    # 
    # By default the name is assumed to be the class name, substituting
    # dashes for double colons.
    #
    # @todo Should this instead default to `File.basename($0)` ?
    #
    # @method name(text=nil)
    #
    section(:name) do
      cli_class.usage_name
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
    # @todo man-pages will probably fail on Windows.
    #
    def show_help(hint=nil)
      if file = manpage(hint)
        show_manpage(file)
      else
        puts self
      end
    end

    #
    alias :show :show_help

    #
    def show_manpage(file)
      #exec "man #{file}"
      system "man #{file}"
    end

    #
    # Get man-page if there is one.
    #
    def manpage(dir=nil)
      @manpage ||= (
        man = []
        dir = nil

        if dir
          raise unless File.directory?(dir)
        end

        if !dir && call_method
          file, line = call_method.source_location
          dir = File.dirname(file)
        end

        man_name = name.gsub(/\s+/, '-') + '.1'

        if dir
          glob = "man/{man1/,}#{man_name}"
          lookup(glob, dir)
        else
          nil
        end
      )
    end

    #
    # Render help text to a given +format+. If no format it given
    # then renders to plain text.
    #
    def to_s(format=nil)
      case format
      when :markdown, :md
        markdown
      else
        text
      end
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
        s << "OPTIONS\n" + options.map{ |max, opts, desc|
          "  %-#{max}s %s" % [opts.join(' '), desc]
        }.join("\n")
      end

      s << copyright
      s << see_also

      s.compact.join("\n\n")
    end

    #
    alias_method :txt, :text

    #
    # Generate a RONN-style Markdown.
    #
    def markdown
      commands = text_subcommands
      options  = text_options
      dashname = name.sub(/\s+/, '-')

      s = []

      h = "#{dashname}(1) - #{text_description}"
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
        s << options.map{ |max, opts, desc|
          "  * `%s`:\n    %s" % [opts.join(' '), desc]
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
    alias_method :md, :markdown

    #
    # Description of command in printable form.
    # But will return +nil+ if there is no description.
    #
    # @return [String,NilClass] command description
    #
    def text_description
      return description if description
      #return Source.get_above_comment(@file, @line) if @file

      call_method ? call_method.comment : nil
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

      # if two options have the same description, they must aliases
      aliased_options = option_list.group_by{ |opt| opt.description }

      list = aliased_options.map do |desc, opts|
        [opts.map{ |o| "%s%s" % [o.mark, o.usage] }, desc]
      end

      max = list.map{ |opts, desc| opts.join(' ').size }.max.to_i + 2

      list.map do |opts, desc|
        [max, opts, desc]
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

    #
    def call_method
      @call_method ||= method_list.find{ |m| m.name == :call }
    end

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
        a.public_instance_methods(false).each do |m|
          list << cli_class.instance_method(m)
        end
      end
      list #.uniq
    end

    #
    #
    #
    def lookup(glob, dir)
      dir  = File.expand_path(dir)
      root = '/'
      home = File.expand_path('~')
      list = []

      while dir != home && dir != root
        list.concat(Dir.glob(File.join(dir, glob)))
        break unless list.empty?
        dir = File.dirname(dir)
      end

      list.first
    end

    # Encapsualtes a command line option.
    #
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
