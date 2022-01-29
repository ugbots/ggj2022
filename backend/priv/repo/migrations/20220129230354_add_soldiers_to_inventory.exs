defmodule Backend.Repo.Migrations.AddSoldiersToInventory do
  use Ecto.Migration

  def change do
    alter table(:inventories) do
      add :soldiers, :integer
    end
  end
end
