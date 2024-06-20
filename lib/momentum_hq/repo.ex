defmodule MomentumHq.Repo do
  use Ecto.Repo,
    otp_app: :momentum_hq,
    adapter: Ecto.Adapters.Postgres
end
