service("test") do
  on_init %{
    test_service_var = true;
  }

  on_request %{
    //Services should allow for info, ep, and name
    test_service_request = [info, ep, ename]
  }
end
