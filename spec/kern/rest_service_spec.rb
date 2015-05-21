#Anything and everything to do with view controllers (not directly UI) above the driver level

Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/kern.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "kern:rest_service_spec" do
  include_context "kern"

  #Can initialize a controller via embed and have the correct if_dispatch messages
  it "Can initiate a controller via _embed" do
    #Compile the controller
    ctx = flok_new_user File.read('./spec/kern/assets/rest_service.rb')

    #Run the embed function
    ctx.eval %{
      //Call embed on main root view
      base = _embed("my_controller", 0, {}, null);

      //Drain queue with a test event
      int_dispatch([3, "int_event", base, "start_request", {}]);
    }

    base = ctx.eval("base")

    @driver.mexpect("if_init_view", ["test_view", {}, base+1, ["main", "hello", "world"]])
    @driver.mexpect("if_controller_init", [base, base+1, "my_controller", {}])
    @driver.mexpect("if_attach_view", [base+1, 0])
    @driver.mexpect("if_event", [base, "action", {"from" => nil, "to" => "my_action"}])

    #Emulate the if_net driver
    if_net_req = @driver.get("if_net_req", 1) #1 is the network queue

    #int_net_cb(tp, success, info)
    secret = SecureRandom.hex
    @driver.int "int_net_cb", [if_net_req[3], true, {:secret => secret}] #if_net_req[3] is the telepointer

    #Now we expect to have 'response' set as the controller event handler "request_response"
    #should have been called
    response = JSON.parse(ctx.eval("JSON.stringify(response)"))
    expect(response).to eq({"success"=> true, "info" => {"secret" => secret}})
  end
end
