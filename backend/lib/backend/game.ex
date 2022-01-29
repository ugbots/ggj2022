defmodule Backend.Game do
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Game.Inventory

  def create_inventory_for_user(user) do
    %Inventory{}
    |> Inventory.changeset(%{
      wood: 0,
      last_read: DateTime.utc_now,
      user_id: user.id
    })
    |> Repo.insert()
  end
end
