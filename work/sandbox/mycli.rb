# Executable is the sup'd-up base class for creating robust, inheritable and
# reusable command line interfaces.

 class MyCLI
   include Executable

   # foo --debug

   def debug?
     $DEBUG
   end

   def debug=(bool)
     $DEBUG = bool
   end

   # $ foo remote

   class Remote

     # $ foo remote --verbose

     def verbose?
       @verbose
     end

     def verbose=(bool)
       @verbose = bool
     end

     # $ foo remote --force

     def force?
       @force
     end

     def force=(bool)
       @force = bool
     end

     # $ foo remote --output <path>

     def output=(path)
       @path = path
     end

     # $ foo remote -o <path>

     alias_method :o=, :output=

     # $ foo remote add

     class Add < self

       def main(name, branch)
         # ...
       end

     end

     # $ foo remote show

     class Show < self

       def main(name)
         # ...
       end

     end

   end

 end


