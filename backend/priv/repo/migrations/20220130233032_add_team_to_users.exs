defmodule Backend.Repo.Migrations.AddTeamToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :team, :string
    end
  end
end
