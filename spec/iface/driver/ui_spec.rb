#UI module spec handlers
Dir.chdir File.join File.dirname(__FILE__), '../../../'
require './spec/env/iface.rb'
require './spec/lib/helpers.rb'
require './spec/lib/io_extensions.rb'
require './spec/lib/rspec_extensions.rb'

RSpec.describe "iface:driver:net" do
  module_dep "ui"
  include_context "iface:driver"

  before(:each) do
    #Initialize
    @pipe.puts [[0, 0, "if_ui_spec_init"]].to_json
  end

it "Can create and embed views into the root hierarchy" do
    #Create a new view 'spec'
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 333, ["main"]]].to_json

    #Attach that view to the root
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json

    #Request a listing of all the views on the root node
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 0]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 333], 6.seconds)
  end

  it "Con embed a view within an embedded view" do
    #Create two views, an outer view with a 'content' spot (333, and 334 for spot), and an inner blank view (335)
    @pipe.puts [[0, 4, "if_init_view", "spec_one_spot", {}, 333, ["main", "content"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 335, ["main"]]].to_json

    #Attach the container view to the root, and the blank to the spot
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 335, 334]].to_json

    #Request a listing of all the views on the root node
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 0]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 333], 6.seconds)

    #Request a listing of all the views inside the container's spot
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 334]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 335], 6.seconds)
  end

  it "Can have two views ontop of the root view" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 333, ["main"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 334, ["main"]]].to_json

    #Attach the container view to the root, and the blank to the spot
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 334, 0]].to_json

    #Request a listing of all the views on the root node
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 0]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([2, "spec", 333, 334], 6.seconds)
  end

 it "Supports a view with multiple spots" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_two_spot", {}, 333, ["main", "a", "b"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 336, ["main"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 337, ["main"]]].to_json

    #Attach the container view to the root, and the blank to the spot
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 336, 334]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 337, 335]].to_json

    #Request a listing of all the views on the root node
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 0]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 333], 6.seconds)
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 334]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 336], 6.seconds)
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 335]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 337], 6.seconds)
  end

 it "Supports a spot with multiple views" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_one_spot", {}, 333, ["main", "content"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 335, ["main"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 336, ["main"]]].to_json

    #Attach the container view to the root, and the blank to the spot
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 335, 334]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 336, 334]].to_json

    #Request a listing of all the views on the root node
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 0]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", 333], 6.seconds)
    @pipe.puts [[0, 1, "if_ui_spec_views_at_spot", 334]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([2, "spec", 335, 336], 6.seconds)
  end

   it "Does not show the view until the view is attached" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 333, ["main"]]].to_json

    #View should not be rendered
    @pipe.puts [[0, 1, "if_ui_spec_view_is_visible", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", false], 6.seconds)

    #Attach the container view to the root, and the blank to the spot
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json

    #View should be visible
    @pipe.puts [[0, 1, "if_ui_spec_view_is_visible", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", true], 6.seconds)
  end

  it "Can destroy a view" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 333, ["main"]]].to_json

    #View should exists
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", true], 6.seconds)

    #Destroy view
    @pipe.puts [[0, 1, "if_free_view", 333]].to_json

    #View should NOT exists
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", false], 6.seconds)
  end

  it "Can destroy a view, and properly destroys child views of the destroyed view" do
    #Create two views
    @pipe.puts [[0, 4, "if_init_view", "spec_one_spot", {}, 333, ["main", "content"]]].to_json
    @pipe.puts [[0, 4, "if_init_view", "spec_blank", {}, 335, ["main"]]].to_json

    #Attach the child to the parent view (it should be destoryed with the parent)
    @pipe.puts [[0, 2, "if_attach_view", 335, 333]].to_json
    @pipe.puts [[0, 2, "if_attach_view", 333, 0]].to_json

    #Views should exists
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", true], 6.seconds)
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 335]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", true], 6.seconds)

    #Destroy view
    @pipe.puts [[0, 1, "if_free_view", 333]].to_json

    #View should NOT exists
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 333]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", false], 6.seconds)

    #View should NOT exists
    @pipe.puts [[0, 1, "if_ui_spec_view_exists", 335]].to_json
    expect(@pipe).to readline_and_equal_json_x_within_y_seconds([1, "spec", false], 6.seconds)
  end
end
