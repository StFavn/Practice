defmodule Users.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Users.User
  alias Users.Repo

  schema "users" do
    field(:login, :string)
    field(:password, :string, virtual: true)
    field(:encrypted_password, :string)
    has_one(:statuses, Users.Status)
    has_many(:posts, Users.Post)
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:login, :password])
    |> validate_required([:login, :password])
    |> validate_length(:password, min: 8)
    |> encrypt_password()
  end

  # Шифрование пароля
  defp encrypt_password(%Ecto.Changeset{} = changeset) do
    case get_field(changeset, :password) do
      nil ->
        changeset

      password ->
        put_change(changeset, :encrypted_password, Base.encode64(password))
    end
  end

  @doc """
  Регистрация пользователя
  """
  def create_user(login, password) do
    case Repo.get_by(User, login: login) do
      nil ->
        result =
          %User{}
          |> changeset(%{login: login, password: password})
          |> Repo.insert() # возвращает {:ok, user}

        case result do
          {:ok, user} -> {:ok, user}
          {:error, _} -> {:error, :create_user_error}
        end


      _ ->
        {:error, :alrady_exist}
    end
  end

  @doc """
  Авторизация пользователя
  """
  def login(login, password) when is_binary(password) do
    case Repo.get_by(User, login: login, encrypted_password: Base.encode64(password)) do
      nil ->
        {:error, :login_error}

      %User{} = user ->
        {
          :ok,
          user
          |> Users.Repo.preload(:statuses)
          |> Users.Repo.preload(:posts)
        }
    end
  end

  @doc """
  Удаление пользователя вместе со статусом и постами
  """
  def delete_user(login, password) do
    # Проверка верности ввода логина и пароля
    case Repo.get_by(User, login: login, encrypted_password: Base.encode64(password)) do
      nil ->
        {:error, :login_error}

      user ->
        # Извлечение id пользователя
        [user_id] =
          from(i in Users.User, where: i.login == ^login, select: i.id)
          |> Users.Repo.all()

        # Удаление статуса
        result_status_del =
          # Проверка существования статуса
          case Repo.get_by(Users.Status, user_id: user_id) do
            nil ->
              :ok

            status ->
              case Repo.delete(status) do
                {:error, _} -> {:error, :database_error}
                {:ok, _} -> :ok
              end
          end

        # Удаление постов пользователя
        posts_id = from(i in Users.Post, where: i.user_id == ^user_id, select: i.id)
        result_posts_del =
          # Проверка наличия постов пользователя
          case posts_id |> Users.Repo.all() do
            [] ->
              :ok

            _ ->
              case posts_id |> Repo.delete_all() do
                {:error, _} -> {:error, :database_error}
                _ -> :ok
              end
          end

        # Удаление пользователя
        result_user_del =
          case Repo.delete(user) do
            {:error, _} -> {:error, :database_errror}
            {:ok, _} -> :ok
          end

        # Возвращение результата полного удаления
        result_del = [result_status_del, result_posts_del, result_user_del]

        case result_del do
          [:ok, :ok, :ok] -> {:ok, user}
          _ -> {:error, result_del}
        end
    end
  end

  @doc """
  Создание статуса
  """
  def set_status(login, password, text) do
    user = Repo.get_by(User, login: login, encrypted_password: Base.encode64(password))

    # Проверка существования пользователя
    case user do
      nil ->
        {:error, :login_error}

      user ->
        # Извлечение id пользователя для проверки существоания статуса
        [user_id] =
          from(i in Users.User, where: i.login == ^login, select: i.id)
          |> Users.Repo.all()

        # Проверка существования статуса и удаление существующего
        result_status_del =
          case Repo.get_by(Users.Status, user_id: user_id) do
            nil ->
              :ok

            status ->
              case Repo.delete(status) do
                {:error, _} -> {:error, :database_error}
                {:ok, _} -> :ok
              end
          end

        # Создание нового статуса в случае, когда поле статуса пустое
        case result_status_del do
          :ok ->
            result =
              %Users.Status{}
              |> Users.Status.changeset(%{status: text})
              |> put_assoc(:user, user)
              |> Repo.insert()

            case result do
              {:ok, %Users.Status{}} ->
                {:ok, Repo.preload(user, :statuses)}

              {:error, _} = error ->
                error
            end

          {:error, :database_error} ->
            {:error, :database_error}
        end
    end
  end

  @doc """
  Создание поста
  """
  def set_post(login, password, title, text) do
    user = Repo.get_by(User, login: login, encrypted_password: Base.encode64(password))

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
end

# _________________________test_in_iex__________________________________________
# Users.User.create_user("login_1", "password_1") - регестрирует пользователя
# Users.User.set_status("login_1", "password_1", "Status_1_1") - добавляет новый статус
# Users.User.set_status("login_1", "password_1", "Status_1_2") - заменяет существующий
# Users.User.set_post("login_1", "password_1", "title_1_1", "text_by_post_1_1") - создает пост 1
# Users.User.set_post("login_1", "password_1", "title_1_2", "text_by_post_1_2") - создает пост 2
# Users.User.login("login_1", "password_1") - показывает пользователя вместе со статусом и постами
# Users.User.delete_user("login_1", "password_1") - удаляет пользователя вместе со статусом и постами



# ___________________________other_______________________________________________
# Users.Repo.get_by(Users.User, login: "login_1") |> Users.Repo.preload(:statuses)
# Users.Repo.get_by(Users.User, login: "login_1")

# [user_id] = from(i in Users.User, where: i.login == "login_1", select: i.id) |> Users.Repo.all()
# posts_id = from(i in Users.Post, where: i.user_id == ^user_id, select: i.id) |> Users.Repo.all()
#
# _______________________________________________________________________________
# Удаление пользоваателя, которое не работает, если существует статус
#
# def delete_user(login, password) do
#   case Repo.get_by(User, login: login, encrypted_password: Base.encode64(password)) do
#     nil ->
#       {:error, :login_error}

#     user ->
#       case Repo.delete_all(user) do
#         {:ok, user} -> {:ok, user}
#         {:error, _} -> {:error, :database_error}
#       end
#   end
# end

# ______________________________________________________________________________
# Вариант с рекурсией также не работает, хотя казалось бы
# def set_status(login, password, text) do
#   user = Repo.get_by(User, login: login, encrypted_password: Base.encode64(password))
#   case user do
#     nil ->
#       {:error, :login_error}

#     user ->
#       result =
#         %Users.Status{}
#         |> Users.Status.changeset(%{status: text})
#         |> put_assoc(:user, user)
#         |> Repo.insert()

#       case result do
#         {:ok, %Users.Status{}} ->
#           {:ok, Repo.preload(user, :statuses)}

#         _ ->
#           case Repo.delete(%Users.Status{}) do
#             {:error, _} -> {:error, :database_error}
#             _ -> User.set_status(login, password, text)
#           end
#       end
#   end
# end
