require File.expand_path('../lib/kbam/version', __FILE__)

Gem::Specification.new do |s|
  s.name     = %q{kbam}
  s.version  = Kbam::VERSION
  s.author   = "Leopold Burdy"
  s.license  = "MIT"
  s.email    = %q{nerd@whiteslash.eu}
  s.homepage = %q{https://github.com/vilnius-leopold}
  s.summary  = %q{MySQL query string builder for ruby.}
  s.files    = `git ls-files README.md LICENSE lib`.split
end