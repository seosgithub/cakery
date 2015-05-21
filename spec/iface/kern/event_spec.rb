Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:kern:event" do
  module_dep "event"
  include_context "iface:kern"

  #A callback was registered in the kernel for testing purposes
  it "An event sent to the kernel will dispatch the `spec_event_handler` function and send the same info `int_event` received." do
    @secret = SecureRandom.hex

    #Wait for response
    @pipe.puts [0, "ping"].to_json; @pipe.readline_timeout

    #Send the event, we should get something back
    @pipe.puts [3, "int_event", 3848392, "my_event", {"secret" => @secret}].to_json

    res = [
      [0, 3, "if_event", 3848392, "my_event", {"secret"=>@secret}]
    ]

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)
  end

  it "An event sent to the kernel will NOT dispatch the `spec_event_handler` if it has been de-registered" do
    @secret = SecureRandom.hex

    #Wait for response
    @pipe.puts [0, "ping"].to_json; @pipe.readline_timeout

    #De-register event function
    @pipe.puts [0, "int_spec_event_dereg"].to_json

    #Send the event, we should get something back
    @pipe.puts [3, "int_event", 3848392, "my_event", {"secret" => @secret}].to_json

    res = [
      [0, 3, "if_event", 3848392, "my_event", {"secret"=>@secret}]
    ]

    expect(@pipe).not_to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)
  end
end
