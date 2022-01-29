defmodule Backend.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :message, :string
    belongs_to :user, Backend.Game.User

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:message, :user_id])
    |> validate_required([:message, :user_id])
  end
end
