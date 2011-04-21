--- 
name: executable
spec_version: 1.0.0
repositories: 
  public: git://github.com/rubyworks/cliable.git
title: Executable
requires: 
- group: 
  - test
  name: turn
  version: 0+
resources: 
  code: http://github.com/rubyworks/executable
  home: http://rubyworks.github.com/executable
manifest: 
- lib/executable.rb
- meta/license/Apache2.txt
- test/test_executable.rb
- Profile
- README.rdoc
- History.rdoc
- Version
- NOTICE.rdoc
version: 1.1.0
licenses: 
- Apache 2.0
copyright: Copyright (c) 2008 Thomas Sawyer
description: The Executable mixin is a very quick and and easy way to make almost any class usable via a command line interface. It simply uses writer methods as option setters, and the first command line argument as the method to call, with the subsequent arguments passed to the method.
summary: Any class, a command-line interface.
authors: 
- Thomas Sawyer
collection: RubyWorks
created: 2008-08-08
