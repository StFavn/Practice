defmodule Users.Status do
  use Ecto.Schema

  import Ecto.Changeset

  # alias Users.User
  # alias Users.Repo

  schema "statuses" do
    field(:status, :string)
    belongs_to(:user, Users.User)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:status])
    |> validate_required([:status])
  end
end
