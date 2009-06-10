# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{railroad_xing}
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["royw"]
  s.date = %q{2009-06-10}
  s.default_executable = %q{railroad}
  s.email = %q{roy@wright.org}
  s.executables = ["railroad"]
  s.extra_rdoc_files = [
    "ChangeLog",
     "README"
  ]
  s.files = [
    ".gitignore",
     "AUTHORS",
     "COPYING",
     "ChangeLog",
     "INSTALL",
     "README",
     "Rakefile",
     "VERSION",
     "bin/railroad",
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
     "lib/railroad/rails_framework.rb",
     "railroad_xing.gemspec"
  ]
  s.homepage = %q{http://github.com/royw/railroad_xing}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A DOT diagram generator for Ruby web applications (Rails, Merb)}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
