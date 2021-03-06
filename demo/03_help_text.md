## Command Help

Executable Commands can generate help output. It does this by extracting
the commenst associated with the option methods. A description of the
command itself is taken from the comment on the `#call` method. Only
the first line of a comment is used, so the reset of the comment can
still be catered to documention tools such as YARD and RDoc.

Let's setup an example CLI subclass to demonstrate this.

    class MyCLI < Executable::Command

      # This is global option -g.
      # Yadda yadda yadda...
      def g=(bool)
        @g = bool
      end

      def g?; @g; end

      # Subcommand `c1`.
      class C1 < self

        # This does c1.
        def call(*args)
        end

        # This is option --o1 for c1.
        def o1=(value)
        end

        # This is option --o2 for c1.
        def o2=(value)
        end

      end

      # Subcommand `c2`.
      class C2 < self

        # This does c2.
        def call(*args)
        end

        # This is option --o1 for c2.
        def o1=(value)
        end

        # This is option --o2 for c2.
        def o2=(value)
        end

      end

    end

=== Plain Text

The help output,

    @out = MyCLI::C1.help.to_s

should be clearly laid out as follows:

    Usage: my c1 [options...] [subcommand]

    This does c1.

    OPTIONS
       -g          This is global option -g.
      --o1=VALUE   This is option --o1 for c1.
      --o2=VALUE   This is option --o2 for c1.

    Copyright (c) 2012

=== Markdown

The help feature can also output ronn-style markdown,

    @out = MyCLI::C1.help.markdown

should be clearly laid out as follows:

    my-c1(1) - This does c1.
    ========================

    ## SYNOPSIS

    `my c1` [options...] [subcommand]

    ## DESCRIPTION

    This does c1.

    ## OPTIONS

      * `-g`:
        This is global option -g.

      * `--o1=VALUE`:
        This is option --o1 for c1.

      * `--o2=VALUE`:
        This is option --o2 for c1.

    ## COPYRIGHT

    Copyright (c) 2012

