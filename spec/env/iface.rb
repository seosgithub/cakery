require 'json'
require './spec/lib/rspec_extensions'
require 'open3'
require 'timeout'
require 'securerandom'
require './lib/flok'
require './spec/lib/io_extensions'
require './spec/lib/helpers'

shared_context "iface:kern" do
  before(:each) do
    @pipe = IO.popen("rake pipe:kern", "r+")
    @pid = @pipe.pid
    @mods = Flok::Platform.mods ENV['PLATFORM'], ENV['FLOK_ENV']
  end

  after(:each) do
    begin
      Process.kill(:KILL, @pid)
    rescue Errno::ESRCH
    end
  end
end

shared_context "iface:driver" do
  include SpecHelpers
  before(:each) do 
    @pipe = IO.popen("rake pipe:driver", "r+") 
    @pid = @pipe.pid
    @mods = Flok::Platform.mods ENV['PLATFORM'], ENV['FLOK_ENV']
    
    $stderr.puts "starting, PID = #{@pid}"
  end

  after(:each) do
    begin
      @pipe.close
      Process.kill(:INT, @pid)
    rescue Errno::ESRCH
      $stderr.puts "err, no process"
    end
  end
end

#Get a list of modules based on the platform and environment
def mods
  Flok::Platform.mods ENV['PLATFORM'], ENV['FLOK_ENV']
end

def config_yml
  Flok::Platform.config_yml ENV['PLATFORM'], ENV['FLOK_ENV']
end

#Ensure this platform supports a module, or skip the test (used inside before(:each) describe block, or `it` block)
def module_dep name
  before(:each) do
    skip "#{ENV["PLATFORM"].inspect} does not support #{name.inspect} module in config.yml" unless mods.include? name
  end
end

#Require a key value to be a apart of the config yml
def settings_dep key, value
  raise "#{ENV["PLATFORM"].inspect} does not support #{key.inspect} configuration in config.yml" unless config_yml.include? key
  skip "#{ENV["PLATFORM"].inspect} #{key.inspect} is not #{value.inspect} in config.yml; it is #{config_yml[key].inspect}"  unless value == config_yml[key]
end
