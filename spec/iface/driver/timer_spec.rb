Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:driver:timer" do
  module_dep "net"
  include_context "iface:driver"

  it "Can call initiate a timer" do
    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout

    @pipe.puts [[3, 1, "if_timer_init", 3]].to_json

    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout
  end

  it "Does receive ticks back when timer is initiated" do
    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout

    @pipe.puts [[3, 1, "if_timer_init", 4]].to_json

    #Wait to start until after the 1st event fires to make sure timer started up
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "int_timer"], 5.seconds)
    start_time = Time.now.to_i
    25.times do
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "int_timer"], 2.seconds)
    end
    end_time = Time.now.to_i

    #Just leave some room for connection latency, etc.
    expect(end_time - start_time).to be < 10 
    expect(end_time - start_time).to be > 5
  end
end
