defmodule Backend.Game do
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Game.Inventory

  def create_inventory_for_user(user) do
    %Inventory{}
    |> Inventory.changeset(%{
      wood: 0,
      gold: 0,
      last_read: DateTime.utc_now,
      user_id: user.id
    })
    |> Repo.insert()
  end

  def reconcile_inventory_for_user(user) do
    Repo.one(Ecto.assoc(user, :inventory))
    |> reconcile(user.passive_activity)
    |> Repo.update
  end

  defp reconcile(inventory, activity) do
    now = DateTime.utc_now
    then = inventory.last_read
    seconds_between = DateTime.diff(now, then)

    seconds_per_tick = 1
    elapsed_ticks = trunc(seconds_between / seconds_per_tick)

    params = %{ last_read: now }

    params = case activity do
      "wood" -> Map.put(params, :wood, inventory.wood + elapsed_ticks)
      "gold" -> Map.put(params, :gold, inventory.gold + elapsed_ticks)
      "defend" -> params
    end

    Inventory.changeset(inventory, params)
  end
end
