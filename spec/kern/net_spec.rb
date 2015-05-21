#Anything and everything to do with networking above the driver level

Dir.chdir File.join File.dirname(__FILE__), '../../'
require './spec/env/kern.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "kern:net_spec" do
  include_context "kern"

  it "can call get_req() and returns to the correct callback" do
  end
end
