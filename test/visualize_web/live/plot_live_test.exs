defmodule VisualizeWeb.PlotLiveTest do
  use VisualizeWeb.ConnCase

  import Phoenix.LiveViewTest
  import Visualize.PresentationFixtures
  alias Visualize.Accounts.User

  @create_attrs %{
    dataset_name: "some dataset_name",
    expression: "some expression",
    name: "some name"
  }
  @update_attrs %{
    dataset_name: "some updated dataset_name",
    expression: "some updated expression",
    name: "some updated name"
  }
  @invalid_attrs %{dataset_name: "", expression: "", name: nil}

  defp create_plot(%User{} = user) do
    plot = plot_fixture(%{user_id: user.id})
    %{plot: plot}
  end

  describe "Index" do
    setup %{conn: conn} do
      %{user: user, conn: conn} = register_and_log_in_user(%{conn: conn})
      %{plot: plot} = create_plot(user)
      [plot: plot, user: user, conn: conn]
    end

    test "lists all plots", %{conn: conn, plot: plot, user: _user} do
      {:ok, _index_live, html} = live(conn, ~p"/created_plots")

      assert html =~ "Listing Plots"
      assert html =~ plot.dataset_name
    end

    test "saves new plot", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/created_plots")

      assert index_live |> element("a", "New Plot") |> render_click() =~
               "New Plot"

      assert_patch(index_live, ~p"/plots/new")

      assert index_live
             |> form("#plot-form", plot: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#plot-form", plot: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/created_plots")

      html = render(index_live)
      assert html =~ "Plot created successfully"
      assert html =~ "some dataset_name"
    end

    test "updates plot in listing", %{conn: conn, plot: plot} do
      {:ok, index_live, _html} = live(conn, ~p"/created_plots")

      assert index_live |> element("#plots-#{plot.id} a", "Edit") |> render_click() =~
               "Edit Plot"

      assert_patch(index_live, ~p"/plots/#{plot}/edit")

      assert index_live
             |> form("#plot-form", plot: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#plot-form", plot: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/created_plots")

      html = render(index_live)
      assert html =~ "Plot updated successfully"
      assert html =~ "some updated dataset_name"
    end

    test "deletes plot in listing", %{conn: conn, plot: plot} do
      {:ok, index_live, _html} = live(conn, ~p"/created_plots")

      assert index_live |> element("#plots-#{plot.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#plots-#{plot.id}")
    end
  end

  describe "Show" do
    setup %{conn: conn} do
      %{user: user, conn: conn} = register_and_log_in_user(%{conn: conn})
      %{plot: plot} = create_plot(user)
      [plot: plot, user: user, conn: conn]
    end

    test "displays plot", %{conn: conn, plot: plot} do
      {:ok, _show_live, html} = live(conn, ~p"/plots/#{plot}")

      # assert html =~ "Show Plot"
      assert html =~ plot.dataset_name
    end
  end
end
