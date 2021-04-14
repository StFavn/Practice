defmodule Users.Post do
  use Ecto.Schema

  schema "posts" do
    field(:title, :string)
    field(:text, :string)
    belongs_to(:user, Users.User)
  end
end
