defimpl Plug.Exception, for: VisualizeWeb.SomethingNotFoundError do
  def status(_exception), do: 404
  def actions(_exception), do: []
end
