require 'rubygems'
SPEC = Gem::Specification.new do |s|
  s.name         = "railroad_xing"
  s.version      = "0.5.0.1"
  s.author       = "Roy Wright"
  s.email        = "roy@wright.org"
  s.homepage     = "http://github.com/royw/railroad_xing"
  # s.rubyforge_project = "railroad"
  s.platform     = Gem::Platform::RUBY
  s.summary      = "A DOT diagram generator for Ruby web applications (Rails, Merb)"
  s.files        = Dir.glob("lib/railroad/*.rb") + 
                   ["ChangeLog", "COPYING", "railroad_xing.gemspec"]
  s.bindir       = "bin"
  s.executables  = ["railroad"]
  s.default_executable = "railroad"
  s.has_rdoc     = true
  s.extra_rdoc_files = ["README", "COPYING"]
end
