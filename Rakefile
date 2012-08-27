#!/usr/bin/env rake
require 'rake/testtask'

STDOUT.sync = true
current_dir = File.dirname(__FILE__)

def get_vagrant
  require 'vagrant'
  Vagrant::Environment.new(:ui_class => ::Vagrant::UI::Colored)
end

namespace :vagrant do

  desc "Destroys & recreates vagrant box"
  task :rebuild => [:foodcritic] do
    puts "Recreating vagrant box..."
    vagrant = get_vagrant
    vagrant.cli("destroy", "--force")
    vagrant.cli("up")
  end

  desc "Re-runs chef-solo on vagrant box"
  task :converge => [:foodcritic] do
    puts "Starting Chef run on vagrant box..."
    get_vagrant.cli("provision")
  end

end

namespace :solo do

  desc "Runs chef-solo on current machine"
  task :converge => [:foodcritic] do
    puts "Starting Chef run..."
    puts `chef-solo -c #{current_dir}/solo.rb`
  end

end

desc "Copy all chef defined in ./Cheffile into /cookbooks ready for chef run"
task :build_cookbooks do
	puts "Building cookbooks using ./Cheffile ...."
	puts `librarian-chef update` 
	puts `librarian-chef show` 
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['cookbooks/test/**/*_spec.rb']
  t.verbose = true
end

desc "Runs foodcritic linter"
task :foodcritic => [:build_cookbooks] do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    sh "foodcritic -f any -f ~FC005 cookbooks-sources/pressupbox cookbooks-sources/app_containers"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end

task :default => [ 'test', 'foodcritic' ]
