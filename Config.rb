#!/usr/bin/env ruby

# Setup QED.
config :qed do
  # Create coverage report.
  profile :cov do
    require 'simplecov'
    SimpleCov.start do
      coverage_dir 'log/coverage'
      add_filter "/demo/"
      #add_group "RSpec", "lib/assay/rspec.rb"
    end
  end
end