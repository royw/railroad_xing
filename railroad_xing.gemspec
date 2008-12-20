SPEC = Gem::Specification.new do |s|
  s.name         = "railroad_xing"
  s.version      = "0.5.0.1"
  s.authors      = ["Javier Smaldone", "Roy Wright"]
  s.email        = "roy@wright.org"
  s.homepage     = "http://github.com/royw/railroad_xing"
  # s.rubyforge_project = "railroad"
  s.platform     = Gem::Platform::RUBY
  s.summary      = "A DOT diagram generator for Ruby web applications (Rails, Merb)"
  s.files        = [
                      "ChangeLog", 
                      "COPYING", 
                      "railroad_xing.gemspec",
                      "lib/railroad/aasm_diagram.rb",
                      "lib/railroad/app_diagram.rb",
                      "lib/railroad/ar_model.rb",
                      "lib/railroad/controllers_diagram.rb",
                      "lib/railroad/diagram_graph.rb",
                      "lib/railroad/dm_model.rb",
                      "lib/railroad/framework_factory.rb",
                      "lib/railroad/merb_framework.rb",
                      "lib/railroad/model_factory.rb",
                      "lib/railroad/models_diagram.rb",
                      "lib/railroad/options_struct.rb",
                      "lib/railroad/rails_framework.rb"
                   ]
  s.bindir       = "bin"
  s.executables  = ["railroad"]
  s.default_executable = "railroad"
  s.has_rdoc     = true
  s.extra_rdoc_files = ["README", "COPYING"]
end
