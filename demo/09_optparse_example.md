## OptionParser Example

This example mimics the one given in optparse.rb documentation.

    require 'ostruct'
    require 'time'

    class ExampleCLI < Executable::Command

      CODES = %w[iso-2022-jp shift_jis euc-jp utf8 binary]
      CODE_ALIASES = { "jis" => "iso-2022-jp", "sjis" => "shift_jis" }

      attr :options

      def initialize
        super
        reset
      end

      def reset
        @options = OpenStruct.new
        @options.library = []
        @options.inplace = false
        @options.encoding = "utf8"
        @options.transfer_type = :auto
        @options.verbose = false
      end

      # Require the LIBRARY before executing your script
      def require=(lib)
        options.library << lib
      end
      alias :r= :require=

      # Edit ARGV files in place (make backup if EXTENSION supplied)
      def inplace=(ext)
        options.inplace = true
        options.extension = ext
        options.extension.sub!(/\A\.?(?=.)/, ".")  # ensure extension begins with dot.
      end
      alias :i= :inplace=

      # Delay N seconds before executing
      # Cast 'delay' argument to a Float.
      def delay=(n)
        options.delay = n.to_float
      end

      # Begin execution at given time
      # Cast 'time' argument to a Time object.
      def time=(time)
        options.time = Time.parse(time)
      end
      alias :t= :time=

      # Specify record separator (default \\0)
      # Cast to octal integer.
      def irs=(octal)
        options.record_separator = octal.to_i(8)
      end
      alias :F= :irs=

      # Example 'list' of arguments
      # List of arguments.
      def list=(args)
        options.list = list.split(',')
      end

      # Keyword completion.  We are specifying a specific set of arguments (CODES
      # and CODE_ALIASES - notice the latter is a Hash), and the user may provide
      # the shortest unambiguous text.
      CODE_LIST = (CODE_ALIASES.keys + CODES)

      help.option(:code, "Select encoding (#{CODE_LIST})")

      # Select encoding
      def code=(code)
        codes = CODE_LIST.select{ |x| /^#{code}/ =~ x }
        codes = codes.map{ |x| CODE_ALIASES.key?(x) ? CODE_ALIASES[x] : x }.uniq
        raise ArgumentError unless codes.size == 1
        options.encoding = codes.first
      end

      # Select transfer type (text, binary, auto)
      # Optional argument with keyword completion.
      def type=(type)
        raise ArgumentError unless %w{text binary auto}.include(type.downcase)
        options.transfer_type = type.downcase
      end

      # Run verbosely
      # Boolean switch.
      def verbose=(bool)
        options.verbose = bool
      end
      def verbose?
        @options.verbose
      end
      alias :v= :verbose=
      alias :v? :verbose?

      # Show this message
      # No argument, shows at tail.  This will print an options summary.
      def help!
        puts help_text
        exit
      end
      alias :h! :help!

      # Show version
      # Another typical switch to print the version.
      def version?
        puts Executor::VERSION
        exit
      end

      #
      def call
        # ... main procedure here ...
      end
    end

We will run some scenarios on this example to make sure it works.

   cli = ExampleCLI.execute('-r=facets')
   cli.options.library.assert == ['facets']

Make sure time option parses.

   cli = ExampleCLI.execute('--time=2010-10-10')
   cli.options.time.assert == Time.parse('2010-10-10')

Make sure code lookup words and is limted to the selections provided.

   cli = ExampleCLI.execute('--code=ji')
   cli.options.encoding.assert == 'iso-2022-jp'

   expect ArgumentError do
     ExampleCLI.execute('--code=xxx')
   end

Ensure +irs+ is set to an octal number.

   cli = ExampleCLI.execute('-F 32')
   cli.options.record_separator.assert == 032

Ensure extension begins with dot and inplace is set to true.

   cli = ExampleCLI.execute('--inplace txt')
   cli.options.extension.assert == '.txt'
   cli.options.inplace.assert == true

