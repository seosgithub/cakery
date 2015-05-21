controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      var payload = {secret: context.secret};
      Embed("my_sub_controller", "hello", payload);
    }

    on "raise_res", %{
      //Sets after on_entry of my_sub_controller
      raise_res_context = params;
    }
  end
end

controller :my_sub_controller do
  view :test_view2
  spots "hello", "world"

  action :my_action do
    on_entry %{
      context.hello = "world"

      //This sends context to 'my_controller'
      Raise("raise_res", context);
    }
  end
end
