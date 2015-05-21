Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'

#socket.io behaves erraticly under phantomjs, it dislikes multiple run-loops so you must
#make all calls via one @pipe.puts with pipelining

RSpec.describe "iface:driver:sockio_spec" do
  include_context "iface:driver"
  module_dep "sockio"

  it "does allow calling of sockio functions" do
    @pipe.puts [[0, 2, "if_sockio_init", "test", 0]].to_json
    @pipe.puts [[0, 3, "if_sockio_fwd", "hello", "test", 0]].to_json
    @pipe.puts [[0, 3, "if_sockio_send", "hello", {}]].to_json

    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout
  end

  it "does forward given socket.io events as events to a controller" do
    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/sockio_server.js", /STARTED/ do |server_in, server_out|
      #Start forwarding information to base pointer 0
      @pipe.puts [[0, 2, "if_sockio_init", "http://localhost:9998", 0, 3, "if_sockio_fwd", 0, "test", 0]].to_json

      #Expect the server to get a client connection
      expect(server_out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)

      #Now tell the server to send a message
      msg_type = "test"
      msg_info = {"info" => msg_type}
      server_in.puts({type: msg_type, msg: msg_info}.to_json)

      #Now expect that the driver attempts to dispatch the message
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([3, "int_event", 0, msg_type, msg_info], 10.seconds)
    end
  end

  it "does send messages from the given socket.io" do
    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/sockio_server.js", /STARTED/ do |server_in, server_out|
      #Start forwarding information to base pointer 0
      @pipe.puts [[0, 2, "if_sockio_init", "http://localhost:9998", 0, 3, "if_sockio_send", 0, "test", {"hello" => "world"}]].to_json

      #Expect the server to get a client connection
      expect(server_out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)

      #Expect the server to receive a response
      expect(server_out).to readline_and_equal_json_x_within_y_seconds({"hello" => "world"}, 5.seconds) 
    end
  end
end
