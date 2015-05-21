controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      Embed("my_sub_controller", "hello", context);
    }
  end
end

controller :my_sub_controller do
  view :test_view2
  spots "hello", "world"

  action :my_action do
    on_entry %{
      sub_event_gw = __info__.event_gw;
    }
  end
end
