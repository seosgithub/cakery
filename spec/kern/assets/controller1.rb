controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
      Embed("my_sub_controller", "hello", {});
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
      on_entry_base_pointer = __base__;
    }

    on "hello", %{
      var x = 3;
    }
  end
end
