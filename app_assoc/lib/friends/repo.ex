defmodule Friends.Repo do
  use Ecto.Repo,
    otp_app: :app_assoc,
    adapter: Ecto.Adapters.Postgres
end
