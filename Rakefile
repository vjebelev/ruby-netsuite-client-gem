require 'rubygems'
require 'rake'
require 'rake/testtask'
#require 'rake/rdoctask'
#require 'rake/packagetask'
#require 'rake/gempackagetask'
require File.join(File.dirname(__FILE__), 'lib', 'netsuite_client')

desc "Default Task"
task :default => [ :test ]

# Run the unit tests

task :test => [:netsuite_client_test]
  
desc "Run all unit tests"
Rake::TestTask.new(:netsuite_client_test) do |t|
  t.libs << "test" 
  t.test_files = Dir.glob("test/*_test.rb")
  t.verbose = true
end
