controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
    }

    on "test_event", %{
      test_action_called_base = __base__;
      test_action_called_params = params;
    }
  end
end
