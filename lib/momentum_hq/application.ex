defmodule MomentumHqApplication do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

    children = [
      MomentumHqWeb.Telemetry,
      MomentumHq.Repo,
      {Oban, Application.fetch_env!(:momentum_hq, Oban)},
      {DNSCluster, query: Application.get_env(:momentum_hq, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: MomentumHqPubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: MomentumHqFinch},
      # Start a worker by calling: MomentumHqWorker.start_link(arg)
      # {MomentumHqWorker, arg},
      # Start to serve requests, typically the last entry
      MomentumHqWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MomentumHqSupervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MomentumHqWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
