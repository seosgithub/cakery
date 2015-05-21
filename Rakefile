require 'rspec/core/rake_task'
require "bundler/gem_tasks"
require "fileutils"
require './lib/dur'

#Gem things
#############################################################################
#Upgrade version of gem
def upgrade_version
  versionf = './lib/dur/version.rb'
  require versionf

  #Upgrade version '0.0.1' => '0.0.2'
  version = dur::VERSION
  new_version = version.split(".")
  new_version[2] = new_version[2].to_i + 1
  new_version = new_version.join(".")

  sreg = "s/#{version}/#{new_version}/"
  puts `sed #{sreg} #{versionf} > tmp; cp tmp #{versionf}`
  `rm tmp`

  return new_version
end

task :push do
  version = upgrade_version
  `git add .`
  `git commit -a -m 'gem #{version}'`
  `git push`
  `git tag #{version}`
  `git push origin #{version}`
  `gem build dur.gemspec`
  `gem push dur-#{version}.gem`
  `rm dur-#{version}.gem`
end

#############################################################################
RSpec::Core::RakeTask.new(:spec)
