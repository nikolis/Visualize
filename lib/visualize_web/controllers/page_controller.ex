defmodule VisualizeWeb.PageController do
  use VisualizeWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    case is_nil(conn.assigns.current_user) do
      true ->
        render(conn, :home, layout: false)

      false ->
        redirect(conn, to: ~p"/created_plots")
    end
  end
end
