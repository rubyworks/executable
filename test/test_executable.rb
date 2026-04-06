require 'minitest/autorun'
require 'executable'

class ExecutableTest < Minitest::Test

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

  def test_boolean_option
    mc = MyCommand.execute('--quiet')
    assert mc.quiet?
  end

  def test_integer_option
    mc = MyCommand.execute('--size=4')
    assert_equal 4, mc.size
  end

  def test_default_value
    mc = MyCommand.execute('')
    assert_equal 'hey.txt', mc.file
  end

end
