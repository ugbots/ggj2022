defmodule Backend.Game do
  import Ecto.Query, warn: false

  alias Backend.Accounts
  alias Backend.Logs
  alias Backend.Repo
  alias Backend.Game.Inventory

  def create_inventory_for_user(user) do
    %Inventory{}
    |> Inventory.changeset(%{
      wood: 0,
      gold: 0,
      soldiers: 0,
      houses: 0,
      last_read: DateTime.utc_now,
      user_id: user.id
    })
    |> Repo.insert()
  end

  def buy_product_for_user(user, product_name) do
    product = String.to_atom(product_name)
    inventory = Repo.one(Ecto.assoc(user, :inventory))

    cost = case product do
      :soldiers -> %{ gold: -10 }
      :houses -> %{ wood: -100 }
    end
    delta = Map.put(cost, product, 1)

    case adjust(inventory, delta) do
      :ok -> Logs.create_user_log(user, "Bought " <> product_name <> ".")
      {:error, message} -> 
        Logs.create_user_log(
          user, 
          "Cannot buy " <> product_name <> ": " <> message <> ".")
    end
  end

  def donate_to_username_from_user(user, target_username, amount_str, product_name) do
    amount = elem(Integer.parse(amount_str), 0)
    inventory = Repo.one(Ecto.assoc(user, :inventory))
    delta = Map.put(%{}, String.to_atom(product_name), -amount)
    target_user = Accounts.get_by_username(target_username)

    cond do
      user.username == target_username ->
        Logs.create_user_log(user, "Cannot donate to yourself.")
      amount <= 0 ->
        Logs.create_user_log(user, "Donation amount must be positive.")
      not can_afford(inventory, delta) ->
        Logs.create_user_log(
          user, 
          "Cannot donate " <> 
          amount_str <> " " <> product_name <> 
          " to " <> target_username <>
          ": not enough resources.")
      target_user == nil ->
        Logs.create_user_log(
          user, 
          "Cannot donate " <> 
          amount_str <> " " <> product_name <> 
          " to " <> target_username <>
          ": user not found.")
      true ->
        target_inv = Repo.one(Ecto.assoc(target_user, :inventory))

        target_delta = Map.put(%{}, String.to_atom(product_name), amount)
        adjust(target_inv, target_delta)
        Logs.create_user_log(
          target_user, 
          "Received " <> 
          amount_str <> " " <> product_name <> 
          " from " <> user.username <> ".")

        adjust(inventory, delta)
        Logs.create_user_log(
          user, 
          "Donated " <> 
          amount_str <> " " <> product_name <> 
          " to " <> target_username <> ".")
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

  defp can_afford(inventory, delta) do
    Enum.all? delta, fn {item, amount} ->
      Map.get(inventory, item) + amount >= 0
    end
  end

  defp adjust(inventory, delta) do
    case can_afford(inventory, delta) do
      false ->  {:error, "insufficent funds"}
      true ->
        params = Map.merge Map.from_struct(inventory), delta, fn _k, inv, d ->
          inv + d
        end

        Repo.update(Inventory.changeset(inventory, params))
        :ok
    end
  end
end
