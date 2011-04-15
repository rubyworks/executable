task :default => [:test]

desc "run tests"
task :test do
  sh "ruby -rtest/unit -Ilib test/*.rb"
end

desc "run tests with turn"
task :turn do
  sh "turn -T -Ilib test/*.rb"
end

desc "convert README to site/readme.html"
task :readme do
  sh "malt README.rdoc > site/readme.html"
end
