defmodule Backend.Repo.Migrations.AddHousesToInventory do
  use Ecto.Migration

  def change do
    alter table(:inventories) do
      add :houses, :integer
    end
  end
end
