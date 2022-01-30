defmodule Backend.Game do
  import Ecto.Query, warn: false

  alias Backend.Accounts
  alias Backend.Accounts.User
  alias Backend.Logs
  alias Backend.Repo
  alias Backend.Game.Inventory

  @spec create_inventory_for_user(%User{}) :: any
  def create_inventory_for_user(user) do
    %Inventory{}
    |> Inventory.changeset(%{
      last_read: DateTime.utc_now(),
      items: %{
        gold: 100
      },
      user_id: user.id
    })
    |> Repo.insert()
  end

  @spec buy_product_for_user(%User{}, binary()) :: any
  def buy_product_for_user(user, product_name) do
    product = String.to_atom(product_name)
    inventory = Repo.one(Ecto.assoc(user, :inventory))

    cost =
      case product do
        :soldiers -> %{gold: -10}
        :houses -> %{wood: -100}
      end

    delta = Map.put(cost, product, 1)

    case adjust(inventory, delta) do
      :ok ->
        Logs.create_user_log(user, "Bought #{product_name}.")

      {:error, message} ->
        Logs.create_user_log(
          user,
          "Cannot buy #{product_name}: #{message}."
        )
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
          "Cannot donate #{amount_str} #{product_name} " <>
            "to #{target_username}: not enough resources."
        )

      target_user == nil ->
        Logs.create_user_log(
          user,
          "Cannot donate #{amount_str} #{product_name} " <>
            "to #{target_username}: user not found."
        )

      true ->
        target_inv = Repo.one(Ecto.assoc(target_user, :inventory))

        target_delta = Map.put(%{}, String.to_atom(product_name), amount)
        adjust(target_inv, target_delta)

        Logs.create_user_log(
          target_user,
          "Received #{amount_str} #{product_name} from #{user.username}"
        )

        adjust(inventory, delta)

        Logs.create_user_log(
          user,
          "Donated #{amount_str} #{product_name} to #{target_username}"
        )
    end
  end

  def attack_username_from_user(user, target_username, amount_str, product_name) do
    amount = elem(Integer.parse(amount_str), 0)
    inventory = Repo.one(Ecto.assoc(user, :inventory))
    delta = Map.put(%{}, String.to_atom(product_name), -amount)
    target_user = Accounts.get_by_username(target_username)

    cond do
      user.username == target_username ->
        Logs.create_user_log(user, "Cannot attack yourself.")

      amount <= 0 ->
        Logs.create_user_log(user, "Attack size must be positive.")

      not can_afford(inventory, delta) ->
        Logs.create_user_log(
          user,
          "Cannot attack #{target_username} " <>
            "with #{amount_str} #{product_name}: not enough resources."
        )

      target_user == nil ->
        Logs.create_user_log(
          user,
          "Cannot attack #{target_username} " <>
            "with #{amount_str} #{product_name}: user not found"
        )

      true ->
        target_inv = Repo.one(Ecto.assoc(target_user, :inventory))

        target_delta = Map.put(%{}, :houses, -amount)
        adjust(target_inv, target_delta)

        Logs.create_user_log(
          target_user,
          "Attacked by #{user.username}! Lost #{amount_str} houses."
        )

        adjust(inventory, delta)

        Logs.create_user_log(
          user,
          "Attacked #{target_username} with #{amount_str} #{product_name}"
        )
    end
  end

  @spec reconcile_inventory_for_user(%User{}) :: any()
  def reconcile_inventory_for_user(user) do
    Accounts.get_inventory(user)
    |> reconcile(user.passive_activity)
    |> Repo.update()
  end

  @spec reconcile(%Inventory{}, String.t()) :: Ecto.Changeset.t()
  defp reconcile(inv, activity_str) do
    activity = String.to_existing_atom(activity_str)

    now = DateTime.utc_now()
    then = inv.last_read
    seconds_between = DateTime.diff(now, then)
    elapsed_seconds = trunc(seconds_between)

    items =
      case Map.get(Backend.Items.generated_items(), activity, nil) do
        nil ->
          inv.items

        gen ->
          old_amount = Map.get(inv.items, activity_str, 0)
          delta = trunc(elapsed_seconds / gen.seconds_per_item)
          Map.put(inv.items, activity_str, old_amount + delta)
      end

    params = %{
      last_read: now,
      items: items
    }

    Inventory.changeset(inv, params)
  end

  defp can_afford(inv, delta) do
    Enum.all?(delta, fn {item, amount} ->
      Map.get(inv.items, Atom.to_string(item), 0) + amount >= 0
    end)
  end

  defp adjust(inv, delta) do
    case can_afford(inv, delta) do
      false ->
        {:error, "insufficent funds"}

      true ->
        items =
          Enum.reduce(delta, inv.items, fn {item, amount}, acc ->
            key = Atom.to_string(item)
            Map.put(acc, key, Map.get(acc, key, 0) + amount)
          end)

        Repo.update(Inventory.changeset(inv, %{items: items}))
        :ok
    end
  end
end
