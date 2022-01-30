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

  @items %{
    ##
    ## Generated items
    ##
    clay: %{
      generated: %{
        activity_label: "Dig clay",
        activity: "clay",
        seconds_per_item: 2
      }
    },
    wood: %{
      generated: %{
        activity_label: "Chop wood",
        activity: "wood",
        seconds_per_item: 1
      }
    },
    gold: %{
      generated: %{
        activity_label: "Mine gold",
        activity: "gold",
        seconds_per_item: 1
      }
    },

    ##
    ## Items for sale
    ##
    kiln: %{
      for_sale: %{
        label: "Kiln",
        cost: %{
          wood: 50,
          clay: 50
        }
      }
    },
    brick: %{
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
    soldier: %{
      for_sale: %{
        label: "Soldier",
        cost: %{
          gold: 10
        }
      }
    },
    house: %{
      for_sale: %{
        label: "House",
        cost: %{
          brick: 5,
          wood: 10
        }
      }
    }
  }

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
