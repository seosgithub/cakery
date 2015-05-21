controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
    }

    on "start_request", %{
      var payload = {
        ticks: 4
      };
      Request("timer", payload, "tick");
    }

    on "tick", %{
      did_tick = true;
    }
  end
end
