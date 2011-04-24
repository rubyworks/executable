--- !ruby/object:Gem::Specification 
name: executable
version: !ruby/object:Gem::Version 
  hash: 19
  prerelease: false
  segments: 
  - 1
  - 1
  - 0
  version: 1.1.0
platform: ruby
authors: 
- Thomas Sawyer
autorequire: 
bindir: bin
cert_chain: []

date: 2011-04-21 00:00:00 -04:00
default_executable: 
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
email: transfire@gmail.com
executables: []

extensions: []

extra_rdoc_files: 
- README.rdoc
files: 
- lib/executable.rb
- meta/license/Apache2.txt
- test/test_executable.rb
- Profile
- README.rdoc
- History.rdoc
- Version
- NOTICE.rdoc
has_rdoc: true
homepage: http://rubyworks.github.com/executable
licenses: 
- Apache 2.0
post_install_message: 
rdoc_options: 
- --title
- Executable API
- --main
- README.rdoc
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
rubygems_version: 1.3.7
signing_key: 
specification_version: 3
summary: Any class, a command-line interface.
test_files: 
- test/test_executable.rb
