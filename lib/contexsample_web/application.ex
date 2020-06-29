defmodule ContexSample.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      ContexSampleWeb.Endpoint,
      {Phoenix.PubSub, [name: Contexsample.PubSub, adapter: Phoenix.PubSub.PG2]}
    ]

    opts = [strategy: :one_for_one, name: Reaction.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ContexSampleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
