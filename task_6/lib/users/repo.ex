defmodule Users.Repo do
  use Ecto.Repo,
    otp_app: :task_6,
    adapter: Ecto.Adapters.Postgres
end
