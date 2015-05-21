Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:kern:debug" do
  module_dep "event"
  include_context "iface:kern"

  #A callback was registered in the kernel for testing purposes
  it "Can call if_debug_eval" do
    #Wait for response
    @pipe.puts [0, "ping"].to_json; @pipe.readline_timeout

    #Send the event, we should get something back
    @pipe.puts [1, "int_debug_eval", "var x = 4; x"].to_json

    res = [
      [0, 3, "if_event", -333, "eval_res", {"res" => 4}]
    ]

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)
  end

  #Cann call the debug_eval_spec
  it "Can call the debug_eval_spec function" do
    #Wait for response
    @pipe.puts [0, "ping"].to_json; @pipe.readline_timeout

    #Send the event, we should get something back
    @pipe.puts [1, "int_debug_eval", "debug_eval_spec()"].to_json

    res = [
      [0, 3, "if_event", -333, "eval_res", {"res" => "hello"}]
    ]

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)
  end
end
