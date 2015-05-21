Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'

RSpec.describe "iface:driver:debug_spec" do
  include_context "iface:driver"
  module_dep "debug"

  it "supports if_debug_set_kv" do
    secret0 = SecureRandom.hex
    secret1 = SecureRandom.hex
    secret2 = SecureRandom.hex
    @pipe.puts [[0, 3, "if_debug_assoc", secret0, secret1, {"secret" => secret2}]].to_json
    @pipe.puts [[0, 2, "if_debug_spec_assoc", secret0, secret1]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", {"secret" => secret2}], 6.seconds)
  end

  it "supports if_debug_highlight_view" do
    @pipe.puts [[0, 0, "if_ui_spec_init"]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_one_spot", {}, 333, ["main", "content"]]].to_json

    @pipe.puts [[0, 2, "if_debug_highlight_view", 333, true]].to_json
    @pipe.puts [[0, 2, "if_debug_highlight_view", 333, false]].to_json

    #Wait for a response to make sure we didn't crash
    @pipe.puts [[0, 0, "ping"]].to_json; @pipe.readline_timeout
  end
end
