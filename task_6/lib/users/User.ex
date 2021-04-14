defmodule Users.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Users.User
  alias Users.Repo


  schema "users" do
    field(:login, :string)
    field(:password, :string)
    has_one(:statuses, Users.Status)
    has_many(:posts, Users.Post)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:login, :password])
    |> validate_required([:login, :password])
  end

  def create_user(login, password) do
    case Repo.get_by(User, login: login) do
      nil ->
        %User{login: login, password: password}
        |> changeset(%{})
        |> Repo.insert()

      _ ->
        {:error, :alrady_exist}
    end
  end

  def set_status(login, password, text) do
    Repo.get_by(User, login: login, password: password)
    |> Ecto.build_assoc(:statuses, %{status: text})
    |> Repo.insert
  end

  def set_post(login, password, title, text) do
    Repo.get_by(User, login: login, password: password)
    |> Ecto.build_assoc(:posts, %{title: title, text: text})
    |> Repo.insert
  end


end

# Users.User.create_user("login_1", "password_1")
# Users.User.login("login_1", "password_1")
# Users.User.delete_user("login_3", "password_3")
# Users.User.client_list()
# Users.User |> Users.Repo.all
# Users.User.set_status("login_1", "password_2", "text_1")
# Users.Repo.get_by(Users.User, login: "login_1", password: "password_1")
# Users.User.set_post("login_1", "password_1", "title_1", "text_by_post_1")


# Users.Repo.get_by(Users.User, login: "login_1", password: "password_1")
#  |> Ecto.build_assoc(:statuses, %{status: "text_1"}) |> Users.Repo.insert

# mix ecto.rollback
# Users.Repo.get_by(Users.User, login: "login_1") |> Users.Repo.preload(:statuses)
