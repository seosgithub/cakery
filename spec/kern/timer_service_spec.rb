Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/kern.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "kern:timer_service_spec" do
  include_context "kern"

  #Can initialize a controller via embed and have the correct if_dispatch messages
  it "Can initiate a controller via _embed" do
    #Compile the controller
    ctx = flok_new_user File.read('./spec/kern/assets/timer_service.rb')

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

    #Emulate the if_timer driver
    @driver.int("int_timer")
    @driver.int("int_timer")
    @driver.int("int_timer")
    @driver.int("int_timer")

    response = ctx.eval("did_tick")
    expect(response).to eq(true)
  end
end
