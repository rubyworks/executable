require 'cliable'
require 'test/unit'

class TestCliable < Test::Unit::TestCase

  class SampleCli
    include Cliable

    attr :result

    def initialize
      @result = []
    end

    def output=(value)
      @result << "output: #{value}"
    end

    def jump
      @result << "jump"
    end
  end

  def test_parse
    s = SampleCli.new
    s.execute_command("jump --output=home")
    assert_equal(s.result, ['output: home', 'jump'])
  end

end

