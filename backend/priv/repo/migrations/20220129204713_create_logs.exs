defmodule Backend.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :message, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:logs, [:user_id])
  end
end
