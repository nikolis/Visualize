defmodule Visualize.PresentationTest do
  use Visualize.DataCase

  alias Visualize.Presentation
  alias Visualize.AccountsFixtures

  describe "plots" do
    alias Visualize.Presentation.Plot

    import Visualize.PresentationFixtures

    @invalid_attrs %{dataset_name: "", expression: "", name: ""}

    test "list_plots/0 returns all plots" do
      plot = plot_fixture()
      plot = Presentation.get_plot!(plot.id)
      assert Presentation.list_plots() == [plot]
    end

    test "get_plot!/1 returns the plot with given id" do
      plot = plot_fixture()
      plot = Presentation.get_plot!(plot.id)
      assert Presentation.get_plot!(plot.id) == plot
    end

    test "create_plot/1 with valid data creates a plot" do
      user = AccountsFixtures.user_fixture()

      valid_attrs = %{
        dataset_name: "some dataset_name",
        expression: "some expression",
        name: "some name",
        user_id: user.id
      }

      assert {:ok, %Plot{} = plot} = Presentation.create_plot(valid_attrs)
      assert plot.dataset_name == "some dataset_name"
      assert plot.expression == "some expression"
      assert plot.name == "some name"
    end

    test "create_plot/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Presentation.create_plot(@invalid_attrs)
    end

    test "update_plot/2 with valid data updates the plot" do
      plot = plot_fixture()

      update_attrs = %{
        dataset_name: "some updated dataset_name",
        expression: "some updated expression",
        name: "some updated name"
      }

      assert {:ok, %Plot{} = plot} = Presentation.update_plot(plot, update_attrs)
      assert plot.dataset_name == "some updated dataset_name"
      assert plot.expression == "some updated expression"
      assert plot.name == "some updated name"
    end

    test "update_plot/2 with invalid data returns error changeset" do
      plot = plot_fixture()
      plot = Presentation.get_plot!(plot.id)

      assert {:error, %Ecto.Changeset{}} = Presentation.update_plot(plot, @invalid_attrs)
      assert plot == Presentation.get_plot!(plot.id)
    end

    test "delete_plot/1 deletes the plot" do
      plot = plot_fixture()
      assert {:ok, %Plot{}} = Presentation.delete_plot(plot)
      assert_raise Ecto.NoResultsError, fn -> Presentation.get_plot!(plot.id) end
    end

    test "change_plot/1 returns a plot changeset" do
      plot = plot_fixture()
      assert %Ecto.Changeset{} = Presentation.change_plot(plot)
    end
  end

  describe "plot_user_share_entries" do
    alias Visualize.Presentation.PlotUserShareEntry

    import Visualize.PresentationFixtures

    @invalid_attrs %{user_id: ""}

    test "list_plot_user_share_entries/0 returns all plot_user_share_entries" do
      plot_user_share_entry = plot_user_share_entry_fixture()
      assert Presentation.list_plot_user_share_entries() == [plot_user_share_entry]
    end

    test "get_plot_user_share_entry!/1 returns the plot_user_share_entry with given id" do
      plot_user_share_entry = plot_user_share_entry_fixture()

      assert Presentation.get_plot_user_share_entry!(plot_user_share_entry.id) ==
               plot_user_share_entry
    end

    test "create_plot_user_share_entry/1 with valid data creates a plot_user_share_entry" do
      user = AccountsFixtures.user_fixture()
      valid_attrs = %{user_id: user.id}

      assert {:ok, %PlotUserShareEntry{} = plot_user_share_entry} =
               Presentation.create_plot_user_share_entry(valid_attrs)
    end

    test "create_plot_user_share_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Presentation.create_plot_user_share_entry(@invalid_attrs)
    end

    test "update_plot_user_share_entry/2 with valid data updates the plot_user_share_entry" do
      plot_user_share_entry = plot_user_share_entry_fixture()
      update_attrs = %{}

      assert {:ok, %PlotUserShareEntry{} = plot_user_share_entry} =
               Presentation.update_plot_user_share_entry(plot_user_share_entry, update_attrs)
    end

    test "update_plot_user_share_entry/2 with invalid data returns error changeset" do
      plot_user_share_entry = plot_user_share_entry_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Presentation.update_plot_user_share_entry(plot_user_share_entry, @invalid_attrs)

      assert plot_user_share_entry ==
               Presentation.get_plot_user_share_entry!(plot_user_share_entry.id)
    end

    test "delete_plot_user_share_entry/1 deletes the plot_user_share_entry" do
      plot_user_share_entry = plot_user_share_entry_fixture()

      assert {:ok, %PlotUserShareEntry{}} =
               Presentation.delete_plot_user_share_entry(plot_user_share_entry)

      assert_raise Ecto.NoResultsError, fn ->
        Presentation.get_plot_user_share_entry!(plot_user_share_entry.id)
      end
    end

    test "change_plot_user_share_entry/1 returns a plot_user_share_entry changeset" do
      plot_user_share_entry = plot_user_share_entry_fixture()
      assert %Ecto.Changeset{} = Presentation.change_plot_user_share_entry(plot_user_share_entry)
    end
  end
end
