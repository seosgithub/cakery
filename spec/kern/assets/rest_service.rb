controller :my_controller do
  view :test_view
  spots "hello", "world"

  action :my_action do
    on_entry %{
    }

    on "start_request", %{
      var payload = {
        url: "http://test.services.fittr.com/ping",
        params: {},
      };
      Request("rest", payload, "request_response");
    }

    on "request_response", %{
      response = params;
    }
  end
end
