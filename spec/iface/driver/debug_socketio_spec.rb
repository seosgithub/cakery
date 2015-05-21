Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'

#Relates to the debug server for drivers that declare "socket_io" in their debug_attach

RSpec.describe "iface:driver:debug_server_ws_spec" do
  include_context "iface:driver"
  module_dep "debug"

  it "does attach to socket.io server when one is present" do
    settings_dep "debug_attach", "socket_io"

    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/debug_socket_server.js", /STARTED/ do |inp, out|
      expect(out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)
    end
  end

  it "debug_server ---[if]---> driver ---[int]---> debug_server" do
    settings_dep "debug_attach", "socket_io"

    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/debug_socket_server.js", /STARTED/ do |debug_in, debug_out|
      expect(debug_out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)

      #Request attach
      debug_in.puts({type: "attach", msg: {}}.to_json)

      #This event sends back an int event named spec with no parameters
      debug_in.puts({type: "if_dispatch", msg: [[0, 0, "if_debug_spec_send_int_event"]]}.to_json)

      expect(debug_out).to readline_and_equal_x_within_y_seconds("int_dispatch", 5.seconds)
      expect(debug_out).to readline_and_equal_json_x_within_y_seconds([0, "spec"], 5.seconds)
      
      #We expect nothing to come out of the rest of the pipe
      expect(@pipe).not_to readline_and_equal_x_within_y_seconds([0, "spec"], 5.seconds)
    end
  end

  it "Interrupt requests from the debug server should go to emulated kernel (stdout of the pipe)" do
    settings_dep "debug_attach", "socket_io"

    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/debug_socket_server.js", /STARTED/ do |debug_in, debug_out|
      expect(debug_out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)

      #Request attach
      debug_in.puts({type: "attach", msg: {}}.to_json)

      #Send an int event to the debug server
      debug_in.puts({type: "int_dispatch", msg: [0, "spec"]}.to_json)

      #We expect the stdout to now have the message we just sent
      expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "spec"], 5.seconds)
    end
  end

  it "if_dispatch messages received from the emulated kernel will be sent to the debug server" do
    settings_dep "debug_attach", "socket_io"

    #Start up the node server and wait for a CLIENT CONNECTED response
    sh2 "node", "./spec/iface/driver/assets/debug_socket_server.js", /STARTED/ do |debug_in, debug_out|
      expect(debug_out).to readline_and_equal_x_within_y_seconds("CLIENT CONNECTED", 10.seconds)

      #Request attach
      debug_in.puts({type: "attach", msg: {}}.to_json)

      #Simulate an if_dispatch message comming from the kernel (stdin)
      @pipe.puts [[0, 0, "ping"]].to_json

      #We expect the stdout to now have the message we just sent
      expect(debug_out).to readline_and_equal_x_within_y_seconds("if_dispatch", 5.seconds)
      expect(debug_out).to readline_and_equal_json_x_within_y_seconds([[0, 0, "ping"]], 5.seconds)
    end
  end
end
