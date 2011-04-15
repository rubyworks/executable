--- !ruby/object:Gem::Specification 
name: executable
version: !ruby/object:Gem::Version 
  hash: 23
  prerelease: 
  segments: 
  - 1
  - 0
  - 0
  version: 1.0.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-04-15 00:00:00 Z
dependencies: 
- !ruby/object:Gem::Dependency 
  name: turn
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    none: false
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        hash: 3
        segments: 
        - 0
        version: "0"
  type: :development
  version_requirements: *id001
description: The Executable mixin is a very quick and and easy way to make almost any class usable via a command line interface. It simply uses writer methods as option setters, and the first command line argument as the method to call, with the subsequent arguments passed to the method.
email: ""
executables: []

extensions: []

extra_rdoc_files: 
- README
files: 
- lib/executable.rb
- test/test_executable.rb
- Rakefile
- PROFILE
- LICENSE
- README
- HISTORY
homepage: http://rubyworks.github.com/executable
licenses: 
- Apache 2.0
post_install_message: 
rdoc_options: 
- --title
- Executable API
- --main
- README
require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  none: false
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      hash: 3
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: executable
rubygems_version: 1.7.2
signing_key: 
specification_version: 3
summary: Any class, a command-line interface.
test_files: 
- test/test_executable.rb
