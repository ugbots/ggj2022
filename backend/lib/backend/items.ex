defmodule Backend.Items do
  @type generated :: %{
          activity_label: String.t(),
          activity: String.t(),
          seconds_per_item: integer
        }

  @type for_sale :: %{
          requirements: nil | %{atom() => integer()},
          cost: %{atom() => integer()}
        }

  @type weapon :: %{
          damage: integer()
        }

  @type item :: %{
          damage_resistance: integer(),
          label: String.t(),
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
      label: "Clay",
      damage_resistance: 1,
      generated: %{
        activity_label: "Dig clay",
        activity: "clay",
        seconds_per_item: 2
      }
    },
    wood: %{
      label: "Wood",
      damage_resistance: 1,
      generated: %{
        activity_label: "Chop wood",
        activity: "wood",
        seconds_per_item: 1
      }
    },
    iron_ore: %{
      label: "Iron ore",
      damage_resistance: 1,
      generated: %{
        activity_label: "Mine iron ore",
        activity: "iron_ore",
        seconds_per_item: 2
      }
    },
    gold: %{
      label: "Gold",
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
      label: "Pointy stick",
      damage_resistance: 1,
      for_sale: %{
        cost: %{
          wood: 1
        }
      },
      weapon: %{
        damage: 1
      }
    },
    iron_sword: %{
      label: "Iron Sword",
      damage_resistance: 5,
      for_sale: %{
        cost: %{
          wood: 10,
          iron_ingot: 1
        }
      },
      weapon: %{
        damage: 3
      }
    },
    musket: %{
      label: "Musket",
      damage_resistance: 10,
      for_sale: %{
        cost: %{
          wood: 10,
          iron_ore: 10,
          gunpowder: 1
        }
      },
      weapon: %{
        damage: 10
      }
    },
    soldier: %{
      label: "Soldier",
      damage_resistance: 1,
      for_sale: %{
        cost: %{
          gold_ingot: 1,
          iron_ore: 5
        }
      },
      weapon: %{
        damage: 5
      }
    },
    bomb: %{
      label: "Bomb",
      damage_resistance: 10,
      for_sale: %{
        cost: %{
          alloy: 50,
          gunpowder: 50
        }
      },
      weapon: %{
        damage: 1000
      }
    },
    iron_ingot: %{
      label: "Iron ingot",
      damage_resistance: 5,
      for_sale: %{
        requirements: %{
          smelter: 1
        },
        cost: %{
          iron_ore: 5
        }
      }
    },
    gold_ingot: %{
      label: "Gold ingot",
      damage_resistance: 5,
      for_sale: %{
        requirements: %{
          smelter: 1
        },
        cost: %{
          gold: 5
        }
      }
    },
    kiln: %{
      label: "Kiln",
      damage_resistance: 10,
      for_sale: %{
        cost: %{
          wood: 50,
          clay: 50
        }
      }
    },
    brick: %{
      label: "Brick",
      damage_resistance: 10,
      for_sale: %{
        requirements: %{
          kiln: 1
        },
        cost: %{
          clay: 5
        }
      }
    },
    alloy: %{
      label: "Alloy",
      damage_resistance: 10,
      for_sale: %{
        requirements: %{
          smelter: 1
        },
        cost: %{
          iron_ingot: 1,
          gold_ingot: 1
        }
      }
    },
    gunpowder: %{
      label: "Gunpowder",
      damage_resistance: 5,
      for_sale: %{
        requirements: %{
          scientist: 1
        },
        cost: %{
          clay: 100,
          wood: 10
        }
      }
    },
    house: %{
      label: "House",
      damage_resistance: 20,
      victory_points: 1,
      for_sale: %{
        cost: %{
          brick: 5,
          wood: 10
        }
      }
    },
    stronghold: %{
      label: "Stronghold",
      damage_resistance: 50,
      victory_points: 3,
      for_sale: %{
        cost: %{
          brick: 10,
          alloy: 10
        }
      }
    },
    smelter: %{
      label: "Smelter",
      damage_resistance: 20,
      for_sale: %{
        cost: %{
          brick: 20
        }
      }
    },
    scientist: %{
      label: "Scientist",
      damage_resistance: 10,
      for_sale: %{
        cost: %{
          gold_ingot: 5,
          stronghold: 1
        }
      }
    }
  }

  def get_items() do
    @items
  end

  def get_item(item_atom) do
    Map.get(@items, item_atom)
  end

  ##
  ## Generated items
  ##

  @doc """
  Filters @items down to entries that can be generated.
  """
  @spec generated_items :: %{atom() => item()}
  def generated_items() do
    items_by_property(:generated)
  end

  @spec all_item_labels :: [String.t()]
  def all_item_labels() do
    @items
    |> Enum.map(fn {_, props} -> props.label end)
  end

  ##
  ## Items for sale
  ##

  @spec for_sale_items :: %{atom() => item()}
  def for_sale_items() do
    items_by_property(:for_sale)
  end

  @spec for_sale_cost_string(item()) :: String.t()
  def for_sale_cost_string(item) do
    requirements =
      case Map.get(item.for_sale, :requirements, nil) do
        nil ->
          ""

        reqs ->
          Enum.map(reqs, fn {k, amount} ->
            "#{amount} #{get_item(k).label}"
          end)
          |> Enum.join(", ")
          |> (fn x -> "(requires #{x})" end).()
      end

    cost =
      Enum.map(item.for_sale.cost, fn {k, amount} ->
        if get_item(k) == nil do
          raise k
        end
        "#{amount} #{get_item(k).label}"
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
        _ -> [{item, props}]
      end
    end)
    |> Map.new()
  end
end
