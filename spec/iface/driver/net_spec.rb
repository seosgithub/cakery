Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:driver:net" do
  module_dep "net"
  include_context "iface:driver"

  it "Can call a network request" do
    web = Webbing.get "/" do
      @hit = true
      {}
    end

    @ptr = SecureRandom.hex
    @pipe.puts [[1, 4, "if_net_req", "GET", "http://127.0.0.1:#{web.port}", {}, @ptr]].to_json

    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout

    expect(@hit).to eq(true)

    web.kill
  end

  it "Can call a network request with parameters" do
    @secret = SecureRandom.hex
    web = Webbing.get "/" do |params|
      @rcv_secret = params['secret']
      {}
    end

    @ptr = SecureRandom.hex
    @pipe.puts [[1, 4, "if_net_req", "GET", "http://127.0.0.1:#{web.port}", {'secret' => @secret}, @ptr]].to_json

    #Wait for response
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout

    expect(@rcv_secret).to eq(@secret)

    web.kill
  end

  it "Does send a network interupt int_net_cb with success and the correct payload" do
    @secret = SecureRandom.hex
    @secret2 = SecureRandom.hex
    @secret2msg = {"secret2" => @secret2}
    web = Webbing.get "/" do |params|
      @rcv_secret = params['secret']

      @secret2msg
    end

    #Wait for response
    @ptr = SecureRandom.hex
    @pipe.puts [[1, 4, "if_net_req", "GET", "http://127.0.0.1:#{web.port}", {'secret' => @secret}, @ptr]].to_json

    res = [3, "int_net_cb", @ptr, true, @secret2msg]
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds(res, 5.seconds)

    web.kill
  end

  it "Does send a network interupt int_net_cb with error and the correct payload" do
    #Wait for response
    @ptr = SecureRandom.hex
    @pipe.puts [[1, 4, "if_net_req", "GET", "http://no_such_url#{SecureRandom.hex}.com", {}, @ptr]].to_json

    matcher = proc do |x|
      x = JSON.parse(x)
      a = ->(e){e.class == String && e.length > 0} #Error message should be a string that's not blank
      expect(x).to look_like [3, "int_net_cb", @ptr, false, a]
      true
    end

    expect(@pipe).to readline_and_equal_proc_x_within_y_seconds(matcher, 5.seconds)
  end
end
