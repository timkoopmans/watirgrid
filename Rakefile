require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "watirgrid"
    gem.summary = %Q{WatirGrid: Web Application Testing in Ruby across a grid network.}
    gem.description = %Q{WatirGrid allows for distributed testing across a grid network using Watir.}
    gem.email = "tim.koops@gmail.com"
    gem.homepage = "http://github.com/90kts/watirgrid"
    gem.authors = ["Tim Koopmans"]
    gem.version = "1.1.0"
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
desc "Run unit tests for Watir, FireWatir and SafariWatir"
Spec::Rake::SpecTask.new('unit_tests_watir') do |t|
  t.spec_files = FileList['spec/**/grid_spec.rb']
  t.spec_opts = ["--format", "nested", "-c"]
  t.fail_on_error = false
end

desc "Run unit tests for WebDriver"
Spec::Rake::SpecTask.new('unit_tests_webdriver') do |t|
  t.spec_files = FileList['spec/**/webdriver_spec.rb']
  t.spec_opts = ["--format", "nested", "-c"]
  t.fail_on_error = false
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "watirgrid #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
