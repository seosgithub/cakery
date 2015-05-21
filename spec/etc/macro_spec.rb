Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/etc.rb'


RSpec.describe "macro" do
  before(:each) do
    macro_file = './app/kern/macro.rb'
    load macro_file
  end

  it "Changes the text when SEND exists" do
    original = 'SEND("main", "if_net_req", url, params, tp)'
    text = macro_process original

    expect(original).not_to eq(text)
    expect(text.class).to eq(String)
    expect(text.length).not_to eq(0)
  end

  it "Has same # of lines with SEND" do
    original = 'SEND("main", "if_net_req", url, params, tp)'
    text = macro_process original

    expect(text.split("\n").length).to eq(original.split("\n").length)
  end

  it "encodes SEND correctly" do
    original = 'SEND("main", "if_net_req", url, params, tp)'
    text = macro_process original

    @arr = []
    expected_code = %{main_q.push([3, "if_net_req", url, params, tp])}
    expect(text.strip).to eq(expected_code)
  end
end
