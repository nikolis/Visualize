defmodule Visualize.Repo do
  use Ecto.Repo,
    otp_app: :visualize,
    adapter: Ecto.Adapters.Postgres
end
