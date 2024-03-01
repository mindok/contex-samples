defmodule ContexSample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ContexSampleWeb.Telemetry,
      ContexSample.Repo,
      {DNSCluster, query: Application.get_env(:contex_sample, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ContexSample.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ContexSample.Finch},
      # Start a worker by calling: ContexSample.Worker.start_link(arg)
      # {ContexSample.Worker, arg},
      # Start to serve requests, typically the last entry
      ContexSampleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ContexSample.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ContexSampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
