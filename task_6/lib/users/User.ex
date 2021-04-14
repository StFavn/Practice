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

  def delete_user(login, password) do
    case Repo.get_by(User, login: login, password: password) do
      nil ->
        {:error, :login_error}

      user ->
        case Repo.delete(user) do
          {:ok, user} -> {:ok, user}
          {:error, _} -> {:error, :database_error}
        end
    end
  end

  def set_status(login, password, text) do
    user = Repo.get_by(User, login: login, password: password)

    case user do
      nil ->
        {:error, :login_error}

      user ->
        result =
          %Users.Status{}
          |> Users.Status.changeset(%{status: text})
          |> put_assoc(:user, user)
          |> Repo.insert()

        case result do
          {:ok, %Users.Status{}} ->
            {:ok, Repo.preload(user, :statuses)}

          {:error, _} ->
            {:error, :already_exist}
        end
    end
  end

  def set_post(login, password, title, text) do
    user = Repo.get_by(User, login: login, password: password)

    case user do
      nil ->
        {:error, :login_error}

      user ->
        result =
          %Users.Post{}
          |> Users.Post.changeset(%{title: title, text: text})
          |> put_assoc(:user, user)
          |> Repo.insert()

        case result do
          {:ok, %Users.Post{}} ->
            {:ok, Repo.preload(user, :posts)}

          {:error, _} = error ->
            error
        end
    end
  end

  def login(login, password) do
    case Repo.get_by(User, login: login, password: password) do
      nil -> {:error, :login_error}
      %User{} = user ->
        {
          :ok,
          user
          |> Users.Repo.preload(:statuses)
          |> Users.Repo.preload(:posts)
        }
    end
  end




end


# _________________________test_in_iex__________________________________________
# Users.User.create_user("login_1", "password_1")
# Users.User.login("login_1", "password_1")
# Users.User.delete_user("login_1", "password_1")
# Users.User.set_status("login_1", "password_2", "text_1")
# Users.User.set_post("login_1", "password_1", "title_1", "text_by_post_1")

# ___________________________other_______________________________________________
# Users.Repo.get_by(Users.User, login: "login_1", password: "password_1")
# Users.User |> Users.Repo.all
# Users.Repo.get_by(Users.User, login: "login_1", password: "password_1")
#  |> Ecto.build_assoc(:statuses, %{status: "text_1"}) |> Users.Repo.insert
# mix ecto.rollback
# Users.Repo.get_by(Users.User, login: "login_1") |> Users.Repo.preload(:statuses)
