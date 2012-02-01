---
source:
- meta
authors:
- name: 7rans
  email: transfire@gmail.com
copyrights:
- holder: Rubyworks
  year: '2008'
  license: BSD-2-Clause
replacements: []
alternatives: []
requirements:
- name: qed
  groups:
  - test
  development: true
- name: ae
  groups:
  - test
  development: true
- name: detroit
  groups:
  - build
  development: true
- name: simplecov
  groups:
  - build
  development: true
dependencies: []
conflicts: []
repositories:
- uri: git://github.com/rubyworks/executable.git
  scm: git
  name: upstream
resources:
  home: http://rubyworks.github.com/executable
  code: http://github.com/rubyworks/executable
  bugs: http://github.com/rubyworks/executable/issues
  mail: http://groups.google.com/rubyworks-mailinglist
  chat: irc://#rubyworks
extra: {}
load_path:
- lib
revision: 0
created: '2008-08-08'
summary: Commandline Object Mapper
version: 1.2.0
name: executable
title: Executable
description: ! 'Think of Executable as a *COM*, a Commandline Object Mapper,

  in much the same way that ActiveRecord is an ORM,

  an Object Relational Mapper. A class utilizing Executable

  can define a complete command line tool using nothing more

  than Ruby''s own method definitions.'
organization: rubyworks
date: '2012-01-31'
