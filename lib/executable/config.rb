module Executable

  # Config is essentially an OpenHash.
  class Config < Hash
    def method_missing(s, *a, &b)
      name = s.to_s
      case name
      when /=$/
        self[name.chomp('=')] = a.first
      else
        self[name]
      end
    end
  end

end
