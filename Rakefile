#!/usr/bin/env rake
require 'rake/testtask'

STDOUT.sync = true
current_dir = File.dirname(__FILE__)

task :default => [ 'test', 'foodcritic' ]

###################################

namespace :vagrant do

  desc "Destroys & recreates vagrant box"
  task :rebuild => [:build_cookbooks, :foodcritic] do
    puts "Recreating vagrant box..."
    vagrant = get_vagrant
    vagrant.cli("destroy", "--force")
    vagrant.cli("up")
  end

  desc "Re-runs chef-solo on vagrant box"
  task :converge => [:build_cookbooks, :foodcritic] do
    puts "Starting Chef run on vagrant box..."
    get_vagrant.cli("provision")
  end

end

####################################

namespace :solo do

  desc "Runs chef-solo on current machine"
  task :converge => [:build_cookbooks, :foodcritic] do
    puts "Starting Chef run..."
    pty_exec "chef-solo -c #{current_dir}/solo.rb"
  end

end

###################################

desc "Copy all chef defined in ./Cheffile into /cookbooks ready for chef run"
task :build_cookbooks do
	puts "Building cookbooks using ./Cheffile ...."
	pty_exec "librarian-chef update" 
	pty_exec "librarian-chef show" 
end

Rake::TestTask.new do |t|
  t.libs.push "lib"
  t.test_files = FileList['cookbooks/test/**/*_spec.rb']
  t.verbose = true
end

desc "Runs foodcritic linter"
task :foodcritic => [:build_cookbooks] do
  if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
    pty_exec "foodcritic -f any -f ~FC005 cookbooks-sources/pressupbox cookbooks-sources/app_containers"
  else
    puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
  end
end


###########################
def pty_exec(cmd)
  is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
  if is_windows then 
    puts `#{cmd}`
    else
      require 'pty'
    PTY.spawn( cmd ) do |stdin, stdout, pid|
      begin
        stdin.each { |line| print line }
      rescue Errno::EIO
      end
    end
  end
rescue 
  puts "#{cmd} - child process exited!"
end

def get_vagrant
  require 'vagrant'
  Vagrant::Environment.new(:ui_class => ::Vagrant::UI::Colored)
end
