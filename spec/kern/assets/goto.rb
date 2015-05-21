controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      Embed("my_controller2", "hello", {});
    }

    on "test_event", %{
      Goto("my_other_action")
    }
  end

  action :my_other_action do
    on_entry %{
      my_other_action_on_entry_called = true;
    }
  end
end

controller :my_controller2 do
  view :test_view2

  action :my_action do
    on_entry %{
    }
  end
end
