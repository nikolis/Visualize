defmodule Visualize.Presentation.PlotUserShareEntry do
  use Ecto.Schema
  import Ecto.Changeset

  alias Visualize.Presentation.Plot
  alias Visualize.Accounts.User

  schema "plot_user_share_entries" do
    belongs_to :user, User
    belongs_to :plot, Plot

    field(:delete, :boolean, virtual: true)
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot_user_share_entry, attrs) do
    changeset =
      plot_user_share_entry
      |> cast(attrs, [:user_id, :plot_id, :delete])
      |> validate_required([:user_id])
      |> unique_constraint(:plot_id_user_id)

    if get_change(changeset, :delete) do
      %{changeset | action: :delete}
    else
      changeset
    end
  end
end
