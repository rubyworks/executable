

  # Manage source lookup.
  #
  module Source
    extend self

    # Read and cache file.
    #
    # @param file [String] filename, should be full path
    #
    # @return [Array] file content in array of lines
    def read(file)
      @read ||= {}
      @read[file] ||= File.readlines(file)
    end

    # Get comment from file searching up from given line number.
    #
    # @param file [String] filename, should be full path
    # @param line [Integer] line number in file
    #
    def get_above_comment(file, line)
      get_above_comment_lines(file, line).join("\n").strip
    end

    # Get comment from file searching up from given line number.
    #
    # @param file [String] filename, should be full path
    # @param line [Integer] line number in file
    #
    def get_above_comment_lines(file, line)
      text  = read(file)
      index = line - 1
      while index >= 0 && text[index] !~ /^\s*\#/
        return [] if text[index] =~ /^\s*end/
        index -= 1
      end
      rindex = index
      while text[index] =~ /^\s*\#/
        index -= 1
      end
      result = text[index..rindex]
      result = result.map{ |s| s.strip }
      result = result.reject{ |s| s[0,1] != '#' }
      result = result.map{ |s| s.sub(/^#/,'').strip }
      #result = result.reject{ |s| s == "" }
      result
    end

    # Get comment from file searching down from given line number.
    #
    # @param file [String] filename, should be full path
    # @param line [Integer] line number in file
    #
    def get_following_comment(file, line)
      get_following_comment_lines(file, line).join("\n").strip
    end

    # Get comment from file searching down from given line number.
    #
    # @param file [String] filename, should be full path
    # @param line [Integer] line number in file
    #
    def get_following_comment_lines(file, line)
      text  = read(file)
      index = line || 0
      while text[index] !~ /^\s*\#/
        return nil if text[index] =~ /^\s*(class|module)/
        index += 1
      end
      rindex = index
      while text[rindex] =~ /^\s*\#/
        rindex += 1
      end
      result = text[index..(rindex-2)]
      result = result.map{ |s| s.strip }
      result = result.reject{ |s| s[0,1] != '#' }
      result = result.map{ |s| s.sub(/^#/,'').strip }
      result.join("\n").strip
    end

  end


