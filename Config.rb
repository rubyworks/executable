#!/usr/bin/env ruby

# Code coverage.
profile :cov do

  # Setup QED.
  config :qed do
    require 'simplecov'
    SimpleCov.start do
      coverage_dir 'log/coverage'
      add_filter "/demo/"
      #add_group "RSpec", "lib/assay/rspec.rb"
    end
  end

end
