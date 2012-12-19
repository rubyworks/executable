[Website](http://rubyworks.github.com/executable) |
[Report Issue](http://github.com/rubyworks/executable/features) |
[Source Code](http://github.com/rubyworks/executable)
( [![Build Status](https://secure.travis-ci.org/rubyworks/indexer.png)](http://travis-ci.org/rubyworks/indexer) )


# Executable

Executable is to the commandline, what ActiveRecord is the database. 
You can think of Executable as a *COM*, a Command-line Object Mapper,
just as ActiveRecord is an ORM (Object Relational Mapper). Any class
mixing in Executable or subclassing Executable::Command can define
a complete command line tool using nothing more than Ruby's standard
syntax. No special DSL is required. 


## Features

* Easy to use, just mixin or subclass.
* Define #call to control the command procedure.
* Public writers become options.
* Namespace children become subcommands.
* Or easily dispatch subcommands to public methods.
* Generate help in plain text or markdown.


## Limitations

* Ruby 1.9+ only.
* Help doesn't handle aliases well (yet).


## Instructions

CLIs can be built by using a Executable as a mixin, or by subclassing 
`Executable::Command`. Methods seemlessly handle command-line options.
Writer methods (those ending in '=') correspond to options and query
methods (those ending in '?') modify them to be boolean switches. 

For example, here is a simple "Hello, World!" commandline tool.

```ruby
    require 'executable'

    class HelloCommand
      include Executable

      # Say it in uppercase?
      def loud=(bool)
        @loud = bool
      end

      #
      def loud?
        @loud
      end

      # Show this message.
      def help!
        cli.show_help
        exit
      end
      alias :h! :help1

      # Say hello.
      def call(name)
        name = name || 'World'
        str  = "Hello, #{name}!"
        str  = str.upcase if loud?
        puts str
      end
    end
```

To make the command available on the command line, add an executable
to your project calling the #execute or #run methods.

```ruby
    #!usr/bin/env ruby
    require 'hello.rb'
    HelloCommand.run
```

If we named this file `hello`, set its execute flag and made it available
on our systems $PATH, then:

```
    $ hello
    Hello, World!

    $ hello John
    Hello, John!

    $ hello --loud John
    HELLO, JOHN!
```

Executable can also generate help text for commands.

```
    $ hello --help
    USAGE: hello [options]

    Say hello.

    --loud      Say it in uppercase?
    --help      Show this message
```

If you look back at the class definition you can see it's pulling
comments from the source to provide descriptions. It pulls the 
description for the command itself from the `#call` method.

Basic help like this is fine for personal tools, but for public facing
production applications it is desirable to utilize manpages. To this end,
Executable provides Markdown formatted help as well. We can access this,
for example, via `HelloCommand.help.markdown`. The idea with this is that
we can save the output to `man/hello.ronn` or copy it the top of our `bin/`
file, edit it to perfection and then use tools such a [ronn](https://github.com/rtomayko/ronn),
[binman](https://github.com/sunaku/binman) or [md2man](https://github.com/sunaku/md2man)
to generate the manpages. What's particularly cool about Executable,
is that once we have a manpage in the standard `man/` location in our project,
the `#show_help` method will use it instead of the plain text.

For a more detail example see [QED](demo.html)
and [API](http://rubydoc.info/gems/executable/frames) documentation.


## Installation

Install with RubyGems in the usual fashion.

```
    $ gem install executable
```

## Contributing

Executable is a [Rubyworks](http://rubyworks.github.com) project. As such it largely
uses in-house tools for development.

### Submitting Patches

If it is a very small change, just pasting it to an issue is fine. For anything more than
this please send us a traditional patch, but even better use Github pull requests. 
Good contributions have the following:

* Well documented code following the conventions of the project.
* Clearly written tests with good test coverage written using the project's chosen test framework.
* Use of a git topic branch to keep the change set well isolated.

The more of these bullet points a pull request covers, the more likely and quickly it will
be accepted and merged.

### Testing

[QED](http://rubyworks.github.com/qed) and [Microtest](http://rubyworks.github.com/microtest)
are used for this project. To run the QED demos just run the `qed` command, probably with bundler,
so `bundle exec qed`. And to run the microtests you can use `rubytest test/`, again with bundler,
`bundle exec rubytest test/`.

### Getting In Touch

For direct dialog we have an IRC channel, #rubyworks on freenode. But it's not always manned,
so a [mailing list](http://groups.google.com/groups/rubyworks-mailinglist) is also available.
Of course these days, the GitHub [issues page](http://github.com/rubyworks/executable) is
generally the place get in touch for anything specific to this project.


## Copyrights

Executable is copyrighted open source software.

    Copyright (c) 2008 Rubyworks (BSD-2-Clause)

It can be distributed and modified in accordance with the **BSD-2-Clause** license.

See LICENSE.txt for details.
