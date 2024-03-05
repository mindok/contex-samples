defmodule ContexSample.Repo do
  use Ecto.Repo,
    otp_app: :contex_sample,
    adapter: Ecto.Adapters.Postgres
end
