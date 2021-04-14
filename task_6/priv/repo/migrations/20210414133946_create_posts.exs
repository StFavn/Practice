defmodule Users.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add(:title, :string)
      add(:text, :string)
      add(:user_id, references(:users))
    end
  end
end
