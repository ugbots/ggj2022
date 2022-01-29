defmodule Backend.Game.Inventory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventories" do
    field :last_read, :utc_datetime
    field :wood, :integer
    field :gold, :integer
    field :soldiers, :integer
    belongs_to :user, Backend.Accounts.User 

    timestamps()
  end

  @doc false
  def changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:wood, :gold, :soldiers, :last_read, :user_id])
    |> validate_required([:wood, :gold, :soldiers, :last_read, :user_id])
  end
end
