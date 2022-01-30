defmodule Backend.Items do
  @type generated :: %{
          activity_label: String.t(),
          activity: String.t(),
          seconds_per_item: integer
        }

  @items %{
    ##
    ## Generated items
    ##
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
    }
  }

  @doc """
  Filters @items down to entries that can be generated.
  """
  @spec generated_items :: %{atom() => generated()}
  def generated_items() do
    @items
    |> Enum.flat_map(fn {item, props} ->
      case Map.get(props, :generated, nil) do
        nil -> []
        gen -> [{item, gen}]
      end
    end)
    |> Map.new()
  end
end
