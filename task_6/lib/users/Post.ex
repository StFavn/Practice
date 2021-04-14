defmodule Users.Post do
  use Ecto.Schema

  import Ecto.Changeset

  # alias Users.User
  # alias Users.Repo

  schema "posts" do
    field(:title, :string)
    field(:text, :string)
    belongs_to(:user, Users.User)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:title, :text])
    |> validate_required([:title, :text])
  end
end
