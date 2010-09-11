require 'rake/testtask'

PKG_NAME = 'trinket'
PKG_VERSION = '0.1'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run the unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end
