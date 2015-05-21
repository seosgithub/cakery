controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      var payload = {secret: context.secret};
      Embed("my_sub_controller", "hello", payload);
    }

    on "test_event", %{
      //Forward params
      Lower("hello", "lower_request", params);
    }
  end
end

controller :my_sub_controller do
  view :test_view2
  spots "hello", "world"

  action :my_action do
    on_entry %{
    }

    on "lower_request", %{
      lower_request_called_with = params;
    }
  end
end
