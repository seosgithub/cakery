controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      Embed("my_sub_controller", "hello", context);
    }

    on "hello", %{
      var x = 3;
    }
  end
end

controller :my_sub_controller do
  view :test_view2
  spots "hello", "world"

  action :my_action do
    on_entry %{
      embedded_context = context;
    }

    on "holah", %{
      var x = 3;
    }
  end
end
