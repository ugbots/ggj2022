defmodule Backend.Repo.Migrations.AddGoldToInventory do
  use Ecto.Migration

  def change do
    alter table(:inventories) do
      add :gold, :integer
    end
  end
end
