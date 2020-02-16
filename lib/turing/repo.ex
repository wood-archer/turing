defmodule Turing.Repo do
  use Ecto.Repo,
    otp_app: :turing,
    adapter: Ecto.Adapters.Postgres
end
