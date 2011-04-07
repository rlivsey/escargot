require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the elastic_rails plugin.'
Rake::TestTask.new(:test) do |t|
  adapter = ENV["ADAPTER"] || "active_record"

  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/*_test.rb', "test/#{adapter}/*_test.rb"
  t.verbose = true
end

desc 'Generate documentation for the elastic_rails plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ElasticRails'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end