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
  alias :h! :help!

  # Say hello.
  def call(name=nil)
    name = name || 'World'
    str  = "Hello, #{name}!"
    str  = str.upcase if loud?
    puts str
  end
end

HelloCommand.execute

