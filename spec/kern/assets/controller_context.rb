controller :my_controller do
  view "my_view"

  action :index do
    on_entry %{
      context.hello = 'world';
    }
  end
end
