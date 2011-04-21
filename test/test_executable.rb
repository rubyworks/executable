require 'executable'

class TestExecutable < Test::Unit::TestCase

  class SampleCli
    include Executable

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

  #
  def test_parse_without_option
    s = SampleCli.new
    s.execute!("jump")
    assert_equal(s.result, ["jump"])
  end

  #
  def test_parse_with_option
    s = SampleCli.new
    s.execute!("jump --output=home")
    assert_equal(s.result, ['output: home', 'jump'])
  end

end

