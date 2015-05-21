Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'

RSpec.describe "iface:driver:ping_spec" do
  include_context "iface:driver"

  it "supports ping" do
    @pipe.puts [[0, 0, "ping"]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "pong"], 6.seconds)
  end

  it "supports ping1" do
    arg = SecureRandom.hex
    @pipe.puts [[0, 1, "ping1", arg]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong1", arg], 6.seconds)
  end

  it "supports ping2" do
    arg1 = SecureRandom.hex
    arg2 = SecureRandom.hex
    @pipe.puts [[0, 2, "ping2", arg1, arg2]].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong2", arg1], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([2, "pong2", arg1, arg2], 6.seconds)
  end

  it "supports multi-ping" do
    @pipe.puts [[0, 0, "ping", 0, "ping"]].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "pong"], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([0, "pong"], 6.seconds)
  end

  it "supports multi-ping1" do
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [[0, 1, "ping1", secret1, 1, "ping1", secret2]].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong1", secret1], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong1", secret2], 6.seconds)
  end

  it "supports multi-ping2" do
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [[0, 2, "ping2", secret1, secret2, 2, "ping2", secret2, secret1]].to_json

    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong2", secret1], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([2, "pong2", secret1, secret2], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "pong2", secret2], 6.seconds)
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([2, "pong2", secret2, secret1], 6.seconds)
  end
end
