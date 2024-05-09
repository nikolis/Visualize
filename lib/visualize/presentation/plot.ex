defmodule Visualize.Presentation.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  alias Visualize.Presentation.PlotUserShareEntry
  alias Visualize.Accounts.User

  schema "plots" do
    field :dataset_name, :string
    field :expression, :string
    field :name, :string

    field :csv_body, :string, virtual: true
    field :column_names, {:array, :string}, virtual: true

    belongs_to :user, User

    has_many :plot_user_share_entries, PlotUserShareEntry
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:name, :dataset_name, :expression, :user_id])
    |> validate_required([:name, :dataset_name, :expression, :user_id])
    |> cast_assoc(:plot_user_share_entries,
      with: &PlotUserShareEntry.changeset/2,
      required: false
    )
  end
end
