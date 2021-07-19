defmodule Contexsample.MixProject do
  use Mix.Project

  def project do
    [
      app: :contexsample,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ContexSample.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.3"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_html, "~> 2.13"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.13.1"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2.1"},
      {:plug_cowboy, "~> 2.3"},
      {:contex, path: "../contex"},
      # {:contex, git: "https://github.com/mindok/contex"},
      {:remote_ip, "~> 0.2"},
      {:makeup, "~> 1.0.3"},
      {:makeup_elixir, "~> 0.14.1"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    []
  end
end
