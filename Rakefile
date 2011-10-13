require 'rake/clean'
require 'rspec/core/rake_task'
require 'jeweler'

Jeweler::Tasks.new do |gem|
  gem.name = "sinatra-can"
  gem.version = "0.1.6"
  gem.summary = "CanCan wrapper for Sinatra."
  gem.description = "CanCan (Rails' authorization library) wrapper for Sinatra. Works with the latest CanCan version."
  gem.email = "shferreira@me.com"
  gem.homepage = "http://github.com/shf/sinatra-can"
  gem.authors = [ "Silvio Henrique Ferreira" ]
  gem.add_dependency "sinatra", ">= 1.0.0"
  gem.add_dependency "cancan", ">= 1.6.0"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rack-test"
  gem.add_development_dependency "rcov"
  gem.add_development_dependency "jeweler"
end
Jeweler::GemcutterTasks.new

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
  t.rspec_opts = '--color'
  t.rcov = true
  t.rcov_opts = ['--exclude', 'gems/']
end
