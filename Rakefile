require 'rubygems/package_task'

gemspec = Gem::Specification.load('executable.gemspec')

Gem::PackageTask.new(gemspec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc "Run tests"
task :test do
  sh 'ruby -Ilib test/test_executable.rb'
end

task :default => :test
