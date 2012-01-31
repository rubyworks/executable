class UnboundMethod
  if !method_defined?(:source_location)
    if Proc.method_defined? :__file__  # /ree/
      def source_location
        [__file__, __line__] rescue nil
      end
    elsif defined?(RUBY_ENGINE) && RUBY_ENGINE =~ /jruby/
      require 'java'
      def source_location
        to_java.source_location(Thread.current.to_java.getContext())
      end
    end
  end

  #
  def comment
    Source.get_above_comment(*source_location)
  end
end

