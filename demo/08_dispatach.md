## Legacy/Dispath

The Dispatch mixin, which is also called Legacy b/c this is how older
version of Executable worked, provides Executable with a `#call` method
that automatically routes the to a method given by the first argument.

  class DispatchExample < Executable::Command
    include Legacy

    attr :result

    def foo
      @result = :foo
    end

    def bar
      @result = :bar
    end

  end

Now when we invoke the command, the 

  eg = DispatchExample.run('foo')
  eg.result.assert == :foo

  eg = DispatchExample.run('bar')
  eg.result.assert == :bar

