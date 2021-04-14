defmodule Users.Repo.Migrations.CreateStatuses do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add(:status, :string)
      add(:user_id, references(:users))
    end

    create unique_index(:statuses, [:user_id])
  end
end
