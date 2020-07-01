# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

host =
  System.get_env("RENDER_EXTERNAL_HOSTNAME") ||
  raise """
  environment variable RENDER_EXTERNAL_HOSTNAME is missing.
  """

live_view_signing_salt =
  System.get_env("LV_SIGNING_SALT") || "LR5UWX99OFyExS57a29AoN1zYedVUCZK"


port =
  System.get_env("PORT") || 80


config :contexsample, ContexSampleWeb.Endpoint,
  http: [:inet6, port: port],
  url: [host: host, port: port],
  secret_key_base: secret_key_base,
  server: true,
  check_origin: ["https://contex-charts.org", "http://localhost:4000"],
  pubsub_server: Contexsample.PubSub,
  live_view: [signing_salt: live_view_signing_salt]
