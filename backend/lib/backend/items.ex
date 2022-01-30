defmodule Backend.Items do
  @type generated :: %{
          activity_label: String.t(),
          activity: String.t(),
          seconds_per_item: integer
        }

  @type for_sale :: %{
          label: String.t(),
          requirements: nil | %{atom() => integer()},
          cost: %{atom() => integer()}
        }

  @type weapon :: %{
          damage: integer()
        }

  @type item :: %{
          damage_resistance: integer(),
          victory_points: nil | integer(),
          generated: nil | generated(),
          for_sale: nil | for_sale(),
          weapon: nil | weapon()
        }

  @items %{
    ##
    ## Generated items
    ##
    clay: %{
      damage_resistance: 1,
      generated: %{
        activity_label: "Dig clay",
        activity: "clay",
        seconds_per_item: 2
      }
    },
    wood: %{
      damage_resistance: 1,
      generated: %{
        activity_label: "Chop wood",
        activity: "wood",
        seconds_per_item: 1
      }
    },
    gold: %{
      damage_resistance: 2,
      generated: %{
        activity_label: "Mine gold",
        activity: "gold",
        seconds_per_item: 1
      }
    },

    ##
    ## Items for sale
    ##
    pointy_stick: %{
      damage_resistance: 1,
      for_sale: %{
        label: "Pointy stick",
        cost: %{
          wood: 1
        }
      },
      weapon: %{
        damage: 1
      }
    },
    kiln: %{
      damage_resistance: 10,
      for_sale: %{
        label: "Kiln",
        cost: %{
          wood: 50,
          clay: 50
        }
      }
    },
    brick: %{
      damage_resistance: 10,
      for_sale: %{
        label: "Brick",
        requirements: %{
          kiln: 1
        },
        cost: %{
          clay: 5
        }
      }
    },
    house: %{
      damage_resistance: 20,
      victory_points: 1,
      for_sale: %{
        label: "House",
        cost: %{
          brick: 5,
          wood: 10
        }
      }
    }
  }

  def get_item(item_atom) do
    Map.get(@items, item_atom)
  end

  ##
  ## Generated items
  ##

  @doc """
  Filters @items down to entries that can be generated.
  """
  @spec generated_items :: %{atom() => generated()}
  def generated_items() do
    items_by_property(:generated)
  end

  @spec all_item_keys :: [String.t()]
  def all_item_keys() do
    @items
    |> Enum.map(fn {k, _} -> Atom.to_string(k) end)
  end

  ##
  ## Items for sale
  ##

  @spec for_sale_items :: %{atom() => for_sale()}
  def for_sale_items() do
    items_by_property(:for_sale)
  end

  @spec for_sale_cost_string(for_sale()) :: String.t()
  def for_sale_cost_string(item) do
    requirements =
      case Map.get(item, :requirements, nil) do
        nil ->
          ""

        reqs ->
          Enum.map(reqs, fn {k, amount} ->
            "#{amount} #{k}"
          end)
          |> Enum.join(", ")
          |> (fn x -> "(requires #{x})" end).()
      end

    cost =
      Enum.map(item.cost, fn {k, amount} ->
        "#{amount} #{k}"
      end)
      |> Enum.join(", ")

    "#{item.label} #{requirements} (costs #{cost})"
  end

  @spec cost_delta_for_item(atom()) :: %{atom() => integer()}
  def cost_delta_for_item(item_key) do
    Map.get(@items, item_key).for_sale.cost
    |> Enum.map(fn {k, v} -> {k, -v} end)
    |> Map.new()
  end

  @spec requirements_for_item(atom()) :: %{atom() => integer()}
  def requirements_for_item(item_key) do
    Map.get(@items, item_key).for_sale
    |> Map.get(:requirements, %{})
  end

  ##
  ## Weapons
  ##

  @spec weapon_items() :: %{atom => weapon()}
  def weapon_items() do
    items_by_property(:weapon)
  end

  @spec weapon_keys() :: [String.t()]
  def weapon_keys() do
    weapon_items()
    |> Enum.map(fn {k, _} -> Atom.to_string(k) end)
  end

  @spec items_by_property(atom()) :: %{atom() => any()}
  def items_by_property(property) do
    @items
    |> Enum.flat_map(fn {item, props} ->
      case Map.get(props, property, nil) do
        nil -> []
        gen -> [{item, gen}]
      end
    end)
    |> Map.new()
  end
end
