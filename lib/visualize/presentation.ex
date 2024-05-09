defmodule Visualize.Presentation do
  @moduledoc """
  The Presentation context.
  """

  import Ecto.Query, warn: false
  alias Visualize.Repo

  alias Visualize.Presentation.Plot
  alias Visualize.Presentation.PlotUserShareEntry
  alias Visualize.Accounts.User

  @doc """
  Returns the list of plots.

  ## Examples

      iex> list_plots()
      [%Plot{}, ...]

  """
  def list_plots do
    Repo.all(Plot)
    |> Repo.preload([:plot_user_share_entries])
  end

  def list_user_created_plots(%User{} = user) do
    from(p in Plot,
      where: p.user_id == ^user.id
    )
    |> Repo.all()
    |> Repo.preload(:plot_user_share_entries)
  end

  def list_user_shared_plots(%User{} = user) do
    from(p in PlotUserShareEntry,
      where: p.user_id == ^user.id
    )
    |> Repo.all()
    |> Repo.preload(plot: [:plot_user_share_entries])
    |> Enum.map(fn x -> x.plot end)
  end

  @doc """
  Gets a single plot.

  Raises `Ecto.NoResultsError` if the Plot does not exist.

  ## Examples

      iex> get_plot!(123)
      %Plot{}

      iex> get_plot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plot!(id) do
    Repo.get!(Plot, id)
    |> Repo.preload([:plot_user_share_entries])
  end

  @doc """
  Creates a plot.

  ## Examples

      iex> create_plot(%{field: value})
      {:ok, %Plot{}}

      iex> create_plot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plot(attrs \\ %{}) do
    %Plot{}
    |> Plot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plot.

  ## Examples

      iex> update_plot(plot, %{field: new_value})
      {:ok, %Plot{}}

      iex> update_plot(plot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plot(%Plot{} = plot, attrs, %User{} = user) do
    plot
    |> change_plot(attrs, user)
    |> Repo.update()
  end

  @doc """
  Deletes a plot.

  ## Examples

      iex> delete_plot(plot)
      {:ok, %Plot{}}

      iex> delete_plot(plot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plot(%Plot{} = plot) do
    Repo.delete(plot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot changes.

  ## Examples

      iex> change_plot(plot)
      %Ecto.Changeset{data: %Plot{}}

  """
  def change_plot(%Plot{} = plot, attrs \\ %{}, %User{} = current_user) do
    if is_nil(plot.user_id) do
      Plot.changeset(plot, attrs)
    else
      if current_user.id != plot.user_id do
        Plot.changeset(plot, attrs)
        |> Ecto.Changeset.add_error(:general, "only creator can modify a plot")
      else
        Plot.changeset(plot, attrs)
      end
    end
  end

  alias Visualize.Presentation.PlotUserShareEntry

  @doc """
  Returns the list of plot_user_share_entries.

  ## Examples

      iex> list_plot_user_share_entries()
      [%PlotUserShareEntry{}, ...]

  """
  def list_plot_user_share_entries do
    Repo.all(PlotUserShareEntry)
  end

  @doc """
  Gets a single plot_user_share_entry.

  Raises `Ecto.NoResultsError` if the Plot user share entry does not exist.

  ## Examples

      iex> get_plot_user_share_entry!(123)
      %PlotUserShareEntry{}

      iex> get_plot_user_share_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_plot_user_share_entry!(id), do: Repo.get!(PlotUserShareEntry, id)

  @doc """
  Creates a plot_user_share_entry.

  ## Examples

      iex> create_plot_user_share_entry(%{field: value})
      {:ok, %PlotUserShareEntry{}}

      iex> create_plot_user_share_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_plot_user_share_entry(attrs \\ %{}) do
    %PlotUserShareEntry{}
    |> PlotUserShareEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a plot_user_share_entry.

  ## Examples

      iex> update_plot_user_share_entry(plot_user_share_entry, %{field: new_value})
      {:ok, %PlotUserShareEntry{}}

      iex> update_plot_user_share_entry(plot_user_share_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_plot_user_share_entry(%PlotUserShareEntry{} = plot_user_share_entry, attrs) do
    plot_user_share_entry
    |> PlotUserShareEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a plot_user_share_entry.

  ## Examples

      iex> delete_plot_user_share_entry(plot_user_share_entry)
      {:ok, %PlotUserShareEntry{}}

      iex> delete_plot_user_share_entry(plot_user_share_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_plot_user_share_entry(%PlotUserShareEntry{} = plot_user_share_entry) do
    Repo.delete(plot_user_share_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking plot_user_share_entry changes.

  ## Examples

      iex> change_plot_user_share_entry(plot_user_share_entry)
      %Ecto.Changeset{data: %PlotUserShareEntry{}}

  """
  def change_plot_user_share_entry(%PlotUserShareEntry{} = plot_user_share_entry, attrs \\ %{}) do
    PlotUserShareEntry.changeset(plot_user_share_entry, attrs)
  end
end
