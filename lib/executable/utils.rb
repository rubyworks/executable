module Executable

  # Some handy-dandy CLI utility methods.
  #
  module Utils
    extend self

    # TODO: Maybe #ask chould serve all purposes depending on degfault?
    # e.g. `ask?("ok?", default=>true)`, would be same as `yes?("ok?")`.

    # Strings to interprest as boolean values.
    BOOLEAN_MAP = {"y"=>true, "yes"=>true, "n"=>false, "no"=>false}

    # Query the user for a yes/no answer, defaulting to yes.
    def yes?(question, options={})
      print "#{question} [Y/n] "
      input  = STDIN.readline.chomp.downcase
      BOOLEAN_MAP[input] || true
    end

    # Query the user for a yes/no answer, defaulting to no.
    def no?(question, options={})
      print "#{question} [y/N] "
      input  = STDIN.readline.chomp.downcase
      BOOLEAN_MAP[input] || false
    end

    # Query the user for an answer.
    def ask(question, options={})
      print "#{question} [default: #{options[:default]}] "
      reply = STDIN.readline.chomp
      if reply.empty?
        options[:default]
      else
        reply
      end
    end

  end

end
