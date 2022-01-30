defmodule Backend.Repo.Migrations.MakeInventoryMap do
  use Ecto.Migration

  def change do
    alter table(:inventories) do
      remove :wood
      remove :gold
      remove :soldiers
      remove :houses

      add :items, :map
    end
  end
end
