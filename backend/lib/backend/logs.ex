defmodule Backend.Logs do
  alias Backend.Repo
  alias Backend.Logs.Log

  import Ecto.Query, only: [from: 2]

  def create_user_log(user, message) do
    %Log{}
    |> Log.changeset(%{
      user_id: user.id,
      message: message
    })
    |> Repo.insert
  end

  def get_log_messages_for_user_id(user_id) do
    query = from log in "logs",
      where: log.user_id == ^user_id,
      select: log.message,
      order_by: [desc: log.inserted_at],
      limit: 10
    Repo.all(query)
  end
end
