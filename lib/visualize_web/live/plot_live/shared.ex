defmodule VisualizeWeb.PlotLive.Shared do
  use VisualizeWeb, :live_view

  alias Visualize.Presentation

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns.current_user
    {:ok, stream(socket, :plots, Presentation.list_user_shared_plots(current_user))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plots")
    |> assign(:plot, nil)
  end

  defp page_title(:edit), do: "Edit Plot"
end
