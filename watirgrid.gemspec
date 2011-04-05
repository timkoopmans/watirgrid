# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{watirgrid}
  s.version = "1.0.3.pre"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tim Koopmans"]
  s.date = %q{2011-04-05}
  s.description = %q{WatirGrid allows for distributed testing across a grid network using Watir.}
  s.email = %q{tim.koops@gmail.com}
  s.executables = ["controller", "provider"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "EXAMPLES.rdoc",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "bin/controller",
     "bin/provider",
     "examples/basic/example_safariwatir.rb",
     "examples/basic/example_webdriver.rb",
     "examples/basic/example_webdriver_remote.rb",
     "examples/cucumber/example.feature",
     "examples/cucumber/step_definitions/example_steps.rb",
     "lib/controller.rb",
     "lib/extensions/remote.rb",
     "lib/provider.rb",
     "lib/watirgrid.rb",
     "rdoc/logo.png",
     "spec/grid_spec.rb",
     "spec/gridinit_spec.rb",
     "spec/memory_spec.rb",
     "spec/spec_helper.rb",
     "spec/utilities_spec.rb",
     "spec/webdriver_remote_spec.rb",
     "spec/webdriver_spec.rb",
     "watirgrid.gemspec"
  ]
  s.homepage = %q{http://github.com/90kts/watirgrid}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{WatirGrid: Web Application Testing in Ruby across a grid network.}
  s.test_files = [
    "spec/grid_spec.rb",
     "spec/gridinit_spec.rb",
     "spec/memory_spec.rb",
     "spec/spec_helper.rb",
     "spec/utilities_spec.rb",
     "spec/webdriver_remote_spec.rb",
     "spec/webdriver_spec.rb",
     "examples/basic/example_safariwatir.rb",
     "examples/basic/example_webdriver.rb",
     "examples/basic/example_webdriver_remote.rb",
     "examples/cucumber/step_definitions/example_steps.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

