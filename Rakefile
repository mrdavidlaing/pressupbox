#!/usr/bin/env rake
require 'rake/testtask'

desc "Initialise / update chef cookbooks as defined in ./Cheffile"
task :update_chef_repo do
	puts "Initializing chef repo using ./Cheffile"
	puts `librarian-chef update` 
	puts `librarian-chef show` 
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['cookbooks/test/**/*_spec.rb']
  t.verbose = true
end

desc "Runs foodcritic linter"
task :foodcritic do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sh "foodcritic -f any -f ~FC005 cookbooks/pressupbox cookbooks/app_containers"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

task :default => [ 'test', 'foodcritic' ]
