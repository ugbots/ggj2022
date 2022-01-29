defmodule Backend.Game do
  import Ecto.Query, warn: false

  alias Backend.Logs
  alias Backend.Repo
  alias Backend.Game.Inventory

  def create_inventory_for_user(user) do
    %Inventory{}
    |> Inventory.changeset(%{
      wood: 0,
      gold: 0,
      soldiers: 0,
      last_read: DateTime.utc_now,
      user_id: user.id
    })
    |> Repo.insert()
  end

  def buy_product_for_user(user, product_name) do
    inventory = Repo.one(Ecto.assoc(user, :inventory))
    cost = case product_name do
      "soldiers" -> %{ gold: 10 }
    end

    if can_afford(inventory, cost) do
      buy(inventory, product_name, cost)
      Logs.create_user_log(
        user, "Bought " <> product_name <> ".")
    else
      Logs.create_user_log(
        user, 
        "Cannot buy " <> product_name <> ": insufficient funds.")
    end
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

  defp can_afford(inventory, cost) do
    Enum.reduce cost, true, fn({item, amount}, acc) -> 
      if not acc do
        false
      else
        Map.get(inventory, item) >= amount
      end
    end
  end

  defp buy(inventory, product_name, cost) do
    product = String.to_atom(product_name)
    old_amount = Map.get(inventory, product)
    params = Map.put(
      spend(inventory, cost),
      product, 
      old_amount + 1)

    Inventory.changeset(inventory, params)
    |> Repo.update
  end

  defp spend(inventory, cost) do
    Enum.reduce cost, %{}, fn ({item, amount}, acc) ->
      Map.put(acc, item, Map.get(inventory, item) - amount)
    end
  end
end
