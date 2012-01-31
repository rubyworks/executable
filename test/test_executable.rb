$:.unshift(File.dirname(__FILE__)+'/../lib')

require 'microtest'
require 'ae'

require 'executable'

class ExecutableTestCase < MicroTest::TestCase

  class MyCommand 
    include Executable

    attr_reader :size, :quiet, :file

    def initialize
      @file = 'hey.txt' # default
    end

    def quiet=(bool)
      @quiet = bool
    end

    def quiet?
      @quiet  
    end

    def size=(integer)
      @size = integer.to_i
    end

    def file=(fname)
      @file = fname
    end

    def call(*args)
      @args = args
    end
  end

  def test_boolean_optiion
    mc = MyCommand.execute('--quiet')
    mc.assert.quiet?
  end

  def test_integer_optiion
    mc = MyCommand.execute('--size=4')
    mc.size.assert == 4
  end

  def test_default_value
    mc = MyCommand.execute('')
    mc.file.assert == 'hey.txt'
  end

  #def usage_output
  #  MyCommand.help.usage.assert == "{$0} [options] [subcommand]"
  #end

end
