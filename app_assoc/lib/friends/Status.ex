defmodule Friends.Status do
  use Ecto.Schema

  schema "statuses" do
    field(:text, :string)
    has_many(:users, Friends.User)
  end
end
