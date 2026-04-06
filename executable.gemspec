Gem::Specification.new do |s|
  s.name        = 'executable'
  s.version     = '1.3.0'
  s.summary     = 'Commandline Object Mapper'
  s.description = 'Think of Executable as a COM, a Commandline Object Mapper, ' \
                  'in much the same way that ActiveRecord is an ORM. A class utilizing ' \
                  'Executable can define a complete command line tool using nothing more ' \
                  "than Ruby's own method definitions."

  s.authors     = ['Trans']
  s.email       = ['transfire@gmail.com']

  s.homepage    = 'https://github.com/rubyworks/executable'
  s.license     = 'BSD-2-Clause'

  s.required_ruby_version = '>= 3.1'

  s.files       = Dir['lib/**/*', 'LICENSE.txt', 'README.md', 'HISTORY.md', 'demo/**/*']
  s.require_paths = ['lib']

  s.add_development_dependency 'rake', '>= 13'
  s.add_development_dependency 'minitest', '>= 5'
end
