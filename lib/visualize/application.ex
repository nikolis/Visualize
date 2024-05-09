defmodule Visualize.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      VisualizeWeb.Telemetry,
      Visualize.Repo,
      {DNSCluster, query: Application.get_env(:visualize, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Visualize.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Visualize.Finch},
      # Start a worker by calling: Visualize.Worker.start_link(arg)
      # {Visualize.Worker, arg},
      # Start to serve requests, typically the last entry
      VisualizeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Visualize.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    VisualizeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
