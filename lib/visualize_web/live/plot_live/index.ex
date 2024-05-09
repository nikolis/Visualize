defmodule VisualizeWeb.PlotLive.Index do
  use VisualizeWeb, :live_view
  alias Visualize.Presentation
  alias Visualize.Presentation.Plot

  require Explorer.DataFrame

  defp mutate(dataframe, "+", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a + ^b)
  end

  defp mutate(dataframe, "-", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a - ^b)
  end

  defp mutate(dataframe, "*", a, b) do
    Explorer.DataFrame.mutate(dataframe, result: ^a * ^b)
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :plots, Presentation.list_user_created_plots(socket.assigns.current_user))
     |> assign(
       :plot_context,
       :not_ready
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Plot")
    |> assign(:plot, Presentation.get_plot!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Plot")
    |> assign(:plot, %Plot{user_id: socket.assigns.current_user.id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Plots")
    |> assign(:plot, nil)
  end

  @impl true
  def handle_info({VisualizeWeb.PlotLive.FormComponent, {:saved, plot}}, socket) do
    {:noreply, stream_insert(socket, :plots, plot)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    plot = Presentation.get_plot!(id)
    {:ok, _} = Presentation.delete_plot(plot)

    {:noreply, stream_delete(socket, :plots, plot)}
  end
end
