Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './lib/flok'

#We are using the CHROME module as a test because it's fairly standardized

RSpec.describe "lib/platform" do
  it "can list drivers" do
    platforms = Flok.platforms
    expect(platforms.class).to eq(Array)
    expect(platforms.first.class).to eq(String)
    expect(platforms).to include("chrome")
  end

  it "can list platform specific config_yml" do
    debug_yml = Flok::Platform.config_yml("chrome", "DEBUG")
    release_yml = Flok::Platform.config_yml("chrome", "RELEASE")

    expect(debug_yml.keys).not_to eq(0)

    #Should not have same modules (at least for chrome)
    expect(release_yml["mods"].count).not_to eq(release_yml.keys.count)
  end

  it "can list modules specific to a platform and environment" do
    debug_mods = Flok::Platform.mods("chrome", "DEBUG")
    release_mods = Flok::Platform.mods("chrome", "RELEASE")

    expect(debug_mods.count).not_to eq(0)

    #Should not have same modules (at least for chrome) in debug and release
    expect(debug_mods.count).not_to eq(release_mods.count)
  end
end
