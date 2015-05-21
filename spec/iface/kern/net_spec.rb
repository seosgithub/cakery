Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:kern:net" do
  module_dep "net"
  include_context "iface:kern"

  #A callback was registered in the kernel for testing purposes
  it "A mock network callback should invoke the '-3209284741' telepointer callback and set int_net_cb_spec" do
    @secret = SecureRandom.hex

    #Wait for response
    @pipe.puts [0, "ping"].to_json; @pipe.readline_timeout

    @pipe.puts [3, "int_net_cb", -3209284741, true, {"secret" => @secret}].to_json
    @pipe.puts [0, "get_int_net_cb_spec"].to_json

    res = [
      [0, 1, "get_int_net_cb_spec", [-3209284741, true, {"secret"=>@secret}]]
    ]

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)
  end
end
