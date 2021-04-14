defmodule Friends.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:Status.id, references(:statuses))
    end
  end
end
