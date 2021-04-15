defmodule Users.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:login, :string) #255
      add(:encrypted_password, :string) #255
    end
  end
end
