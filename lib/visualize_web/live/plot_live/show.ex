defmodule VisualizeWeb.PlotLive.Show do
  use VisualizeWeb, :live_view

  alias Visualize.Presentation
  import VisualizeWeb.PlotLive.PlotUtils

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    plot = Presentation.get_plot!(id)

    plot_data =
      plot
      |> get_csv_data()
      |> calculate_plot_data()

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:plot, plot)
     |> maybe_assign_plot_context(plot_data)}
  end

  def maybe_assign_plot_context(socket, {:error, _}) do
    assign(socket, :plot_context, :not_ready)
  end

  def maybe_assign_plot_context(socket, {:ok, data}) do
    assign(socket, :plot_context, Poison.encode!(%{x: data, type: "histogram"}))
  end

  defp page_title(:show), do: "Show Beil test"
  defp page_title(:edit), do: "Edit Beil test"
end
