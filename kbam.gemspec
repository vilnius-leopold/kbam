# cat kbam.gemspec

Gem::Specification.new do |spec|
  spec.name        = 'kbam'
  spec.version     = '0.3.0'
  spec.date        = '2013-09-21'
  spec.summary     = "K'bam!"
  spec.description = "Simple gem that makes working with raw MySQL in Ruby efficient and fun! It's basically a query string builder (not an ORM!) that takes care of sanatization and sql chaining. Only supports SELECT statements (currently?)."
  spec.authors     = ["Leopold Burdyl"]
  spec.email       = 'nerd@whiteslash.eu'
  spec.files       = ["lib/kbam.rb"]
  spec.homepage    =
    'https://github.com/vilnius-leopold/kbam.rb'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.0.0'
  spec.add_runtime_dependency "mysql2",
    [">= 0.3.13"] #only tested for this version. but probably compatable with others too!
  spec.add_runtime_dependency "colorize",
    [">= 0.5.8"] #REALLY?! O.k. not really but I wanted it to look nice ;)
end