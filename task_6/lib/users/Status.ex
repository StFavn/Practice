defmodule Users.Status do
  use Ecto.Schema

  schema "statuses" do
    field(:status, :string)
    belongs_to(:user, Users.User)
  end
end
