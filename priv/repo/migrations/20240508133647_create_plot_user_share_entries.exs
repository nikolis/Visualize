defmodule Visualize.Repo.Migrations.CreatePlotUserShareEntries do
  use Ecto.Migration

  def change do
    create table(:plot_user_share_entries) do
      add :user_id, references(:users, on_delete: :nothing)
      add :plot_id, references(:plots, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:plot_user_share_entries, [:user_id])
    create index(:plot_user_share_entries, [:plot_id])
    create unique_index(:plot_user_share_entries, [:plot_id, :user_id])
  end
end
