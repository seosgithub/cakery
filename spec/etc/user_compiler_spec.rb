#Load all the test files in ./user_compiler/*.js

Dir.chdir File.join File.dirname(__FILE__), '../../'
require './lib/flok'


#Testing the compilation of controller/action user files into javascript counterparts
RSpec.describe "User compiler" do
  #Return a v8 instance of a compiled js file
  def compile fn
    compiler = Flok::UserCompiler
    js_src(fn)
    js_res = compiler.compile(js_src(fn))
    ctx = V8::Context.new
    ctx.eval js_res
    ctx
  end

  #Get the source for a file in  ./user_compiler/*.rb
  def js_src fn
    Dir.chdir File.join(File.dirname(__FILE__), "user_compiler") do
      return File.read(fn+'.rb')
    end
  end

  it "Can load the ruby module" do
    compiler = Flok::UserCompiler
    puts compiler
  end

  it "Can compile a controller and give up the root view" do
    ctx = compile "controller0"
    root_view = ctx.eval "ctable.my_controller.root_view"
    expect(root_view).to eq("test_view")
  end

  it "Can compile a controller and contain a list of actions" do
    ctx = compile "controller0"
    actions = ctx.eval "Object.keys(ctable.my_controller.actions).length"
    expect(actions).to eq(1)
  end

  it "Can compile a controller with an action that contains an on_entry" do
    ctx = compile "controller0"
    on_entry = ctx.eval "ctable.my_controller.actions.my_action.on_entry"
    expect(on_entry).not_to eq(nil)
  end

  it "Can compile a controller with an action that contains the name" do
    ctx = compile "controller0"
    on_entry = ctx.eval "ctable.my_controller.name"
    expect(on_entry).to eq("my_controller")
  end


  it "Can compile a controller with an action that contains an event that responds to hello" do
    ctx = compile "controller0"
    hello_event_function = ctx.eval "ctable.my_controller.actions.my_action.handlers.hello"
    expect(hello_event_function).not_to eq(nil)
  end

  it "Can compile a controller with spot names" do
    ctx = compile "controller0"
    spot_names = JSON.parse(ctx.eval "JSON.stringify(ctable.my_controller.spots)")
    expect(spot_names).to include "hello"
    expect(spot_names).to include "world"
    expect(spot_names).to include "main" #Should be added by default
  end
end
