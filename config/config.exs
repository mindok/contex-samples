# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :contex_sample,
  ecto_repos: [ContexSample.Repo],
  generators: [timestamp_type: :utc_datetime]

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    "NmtK9GGA7C88oSZdW8oW73MGNgzufNXSlTYig7krCriszdZBdJezs39ZjFbZ5QFW"

# Configures the endpoint
config :contex_sample, ContexSampleWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  secret_key_base: secret_key_base,
  render_errors: [
    formats: [html: ContexSampleWeb.ErrorHTML, json: ContexSampleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ContexSample.PubSub,
  live_view: [signing_salt: "am2/tatn8cjd6Q+A/yZqyA0naK/NVIRb"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :contex_sample, ContexSample.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  contex_sample: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  contex_sample: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
