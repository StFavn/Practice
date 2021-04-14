defmodule Friends.User do
  use Ecto.Schema

  schema "users" do
    field(:name, :string)
    belongs_to(:status, Friends.Status)
  end
end
