require File.expand_path('../lib/kbam/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name        = 'kbam'
  spec.version     = Kbam::VERSION
  spec.date        = '2013-12-16'
  spec.summary     = "K'bam! UNSTABLE - only for testing!"
  spec.description = "Simple gem that makes working with raw MySQL in Ruby efficient and fun! It's basically a query string builder (not an ORM!) that takes care of sanatization and sql chaining."
  spec.authors     = ["Leopold Burdyl"]
  spec.email       = 'nerd@whiteslash.eu'
  spec.files       = Dir["lib/**/**"]
  spec.homepage    = 'https://github.com/vilnius-leopold/kbam'
  spec.license     = 'MIT'
  
  # Ruby version
  spec.required_ruby_version = '>= 2.0.0'

  # Dependencies
  spec.add_runtime_dependency "mysql2",
    [">= 0.3.13"] # only tested for this version. but probably compatable with others too!
  spec.add_runtime_dependency "colorize",
    [">= 0.5.8"] # REALLY?! O.k. not really but I wanted it to look nice ;)
end