defmodule Visualize.PresentationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Visualize.Presentation` context.
  """
  alias Visualize.AccountsFixtures

  @doc """
  Generate a plot.
  """
  def plot_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, plot} =
      attrs
      |> Enum.into(%{
        dataset_name: "some dataset_name",
        expression: "some expression",
        name: "some name",
        user_id: user.id
      })
      |> Visualize.Presentation.create_plot()

    plot
  end

  @doc """
  Generate a plot_user_share_entry.
  """
  def plot_user_share_entry_fixture(attrs \\ %{}) do
    user = AccountsFixtures.user_fixture()

    {:ok, plot_user_share_entry} =
      attrs
      |> Enum.into(%{user_id: user.id})
      |> Visualize.Presentation.create_plot_user_share_entry()

    plot_user_share_entry
  end
end
