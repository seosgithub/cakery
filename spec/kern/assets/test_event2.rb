controller :my_controller do
  view :test_view
  spots "content"

  action :my_action do
    on_entry %{
      Embed("my_controller2", "content", {})
    }

    on "test_event", %{
      test_action_called_base = __base__;
      test_action_called_params = params;
    }
  end
end

#This controller will receive test_event but should
#pass it up to 'my_controller'
controller :my_controller2 do
  view :test_view

  action :my_action do
    on_entry %{
    }
  end
end
