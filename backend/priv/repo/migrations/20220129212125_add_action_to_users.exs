defmodule Backend.Repo.Migrations.AddActionToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :passive_activity, :string
    end
  end
end
