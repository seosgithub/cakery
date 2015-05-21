Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './lib/flok'
require './spec/env/etc'

RSpec.describe "lib/project" do
  it "can list project_template files" do
    ls = Flok::Project.list
    #Subject to change but it's just a basic test
    expect(ls).to include("Gemfile")
    expect(ls).to include("app/controllers")
  end

  it "can create project_template files" do
    dir = new_temp_dir
    Dir.chdir dir do
      Flok::Project.create "test"
      Dir.chdir "test" do
        #This is subject to change, but it's just a basic test
        expect(dirs).to include("app")
        expect(dirs).to include("app/controllers")
        expect(files).to include("Gemfile")
      end
    end
  end
end
