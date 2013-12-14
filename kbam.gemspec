# cat kbam.gemspec

Gem::Specification.new do |s|
  s.name        = 'kbam'
  s.version     = '0.2.0'
  s.date        = '2013-09-21'
  s.summary     = "K'bam!"
  s.description = "Simple gem that makes working with raw MySQL in Ruby efficient and fun! It's basically a query string builder (not an ORM!) that takes care of sanatization and sql chaining. Only supports SELECT statements (currently?)."
  s.authors     = ["Leopold Burdyl"]
  s.email       = 'nerd@whiteslash.eu'
  s.files       = ["lib/kbam.rb"]
  s.homepage    =
    'https://github.com/vilnius-leopold/kbam.rb'
  s.license       = 'MIT'
  s.add_runtime_dependency "mysql2",
    [">= 0.3.13"] #only tested for this version. but probably compatable with others too!
  s.add_runtime_dependency "colorize",
    [">= 0.5.8"] #REALLY?! O.k. not really but I wanted it to look nice ;)
end