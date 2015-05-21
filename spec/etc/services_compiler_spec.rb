Dir.chdir File.join File.dirname(__FILE__), '../../'
require './lib/flok'
require './spec/env/etc'

RSpec.describe "lib/services_compiler" do
  #Return a v8 instance of a compiled js file
  def compile fn
    compiler = Flok::ServicesCompiler
    js_src(fn)
    js_res = compiler.compile(js_src(fn))
    ctx = V8::Context.new
    ctx.eval js_res
    ctx
  end

  #Get the source for a file in  ./service_compiler/*.rb
  def js_src fn
    Dir.chdir File.join(File.dirname(__FILE__), "service_compiler") do
      return File.read(fn+'.rb')
    end
  end

  it "Can call compile method and get on_init" do
    ctx = compile "service0"

    #The service defines a variable in on_init, this should be always accessible
    res = ctx.eval("test_service_var")
    expect(res).to eq(true)
  end

  it "Can call compile method and get on_request" do
    ctx = compile "service0"

    #Should be able to call on_request generated request function
    ctx.eval('service_test_req({}, 0, "test")')

    #That should have set a variable
    res = JSON.parse(ctx.eval("JSON.stringify(test_service_request)"))
    expect(res).to eq([{}, 0, "test"])
  end
end
