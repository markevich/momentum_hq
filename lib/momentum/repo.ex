defmodule Momentum.Repo do
  use Ecto.Repo,
    otp_app: :momentum,
    adapter: Ecto.Adapters.Postgres
end
