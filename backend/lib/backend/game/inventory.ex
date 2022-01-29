defmodule Backend.Game.Inventory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "inventories" do
    field :last_read, :utc_datetime
    field :wood, :integer
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(inventory, attrs) do
    inventory
    |> cast(attrs, [:wood, :last_read])
    |> validate_required([:wood, :last_read])
  end
end
