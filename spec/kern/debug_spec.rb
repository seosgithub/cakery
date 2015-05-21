Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/kern.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

#The debug controller / ui spec

RSpec.describe "kern:debug_spec" do
  include_context "kern"

 it "Can retreive the controller's context" do
    #Compile the controller
    ctx = flok_new_user File.read('./spec/kern/assets/controller_context.rb')

    #Do not run anything
    ctx.eval %{
      //Call embed on main root view
      base = _embed("my_controller", 0, {}, null);

      //Drain queue
      int_dispatch([]);
    }

    base = ctx.eval("base")

    @driver.mexpect("if_init_view", ["my_view", {}, base+1, ["main"]])
    @driver.mexpect("if_controller_init", [base, base+1, "my_controller", {"hello" => "world"}])
    @driver.mexpect("if_attach_view", [base+1, 0])
    @driver.mexpect("if_event", [base, "action", {"from" => nil, "to" => "index"}])

    #Request context for view controller
    @driver.int "int_debug_controller_context", [base]
    @driver.mexpect("if_event", [-333, "debug_controller_context_res", {
      "hello" => "world"
    }])
  end
end
